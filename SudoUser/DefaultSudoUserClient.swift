//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AuthenticationServices
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import Foundation
import SudoConfigManager
import SudoKeyManager
import SudoLogging

/// Default implementation for `SudoUserClient`.
public class DefaultSudoUserClient: SudoUserClient {

    // MARK: - Properties

    /// Contains the configuration properties for the client.
    let identityServiceConfig: IdentityServiceConfig

    /// Contains the configuration properties for federated sign in.
    let federatedSignInConfig: FederatedSignInConfig?

    /// Actor for synchronizing access to client state information.
    let clientStateActor: ClientStateActor

    /// Facilitates thread-safe access to subscribed `SignInStatusObserver` instances.
    let signInObserversActor: SignInObserversActor

    /// KeyManager instance used for cryptographic operations.
    let keyManager: SudoKeyManager

    /// Identity provider to use for registration and authentication. Mutable for unit testing purposes.
    var authenticationWorker: AuthenticationWorker

    /// Facilitates mutation requests to the identity service GraphQL endpoint. Mutable for unit testing purposes.
    var graphQLClient: GraphQLClient

    /// The lifetime of the private key signed token used in the challenge response during sign in. Mutable for unit testing purposes.
    var signInTokenLifetime: TimeInterval = Constants.Default.signInTokenLifetime

    /// Default logger for SudoUserClient.
    let logger: SudoLogging.Logger

    // MARK: - Lifecycle

    /// Intializes a new `DefaultSudoUserClient` instance. It uses configuration parameters defined in
    /// `sudoplatformconfig.json` file located in the app bundle.
    /// - Parameters:
    ///   - keyNamespace: Namespace to use for the keys and passwords. This has to be unique per client
    ///         per app to avoid different apps (with keychain sharing) or different clients creating conflicting
    ///         keys.
    ///   - logger: A logger to use for logging messages. If none provided then a default
    ///         internal logger will be used.
    convenience public init(keyNamespace: String, logger: SudoLogging.Logger? = nil) throws {
        let configManagerName = SudoConfigManagerFactory.Constants.defaultConfigManagerName
        guard
            let configManager = SudoConfigManagerFactory.instance.getConfigManager(name: configManagerName),
            let identityServiceConfig = configManager.getConfigSet(namespace: Constants.ConfigurationNamespace.identityService)
        else {
            throw SudoUserClientError.identityServiceConfigNotFound
        }
        var config: [String: Any] = [Constants.ConfigurationNamespace.identityService: identityServiceConfig]

        if let federatedSignInConfig = configManager.getConfigSet(namespace: Constants.ConfigurationNamespace.federatedSignIn) {
            config[Constants.ConfigurationNamespace.federatedSignIn] = federatedSignInConfig
        }
        try self.init(config: config, keyNamespace: keyNamespace, logger: logger)
    }

    /// Intializes a new `DefaultSudoUserClient` instance.
    /// - Parameters:
    ///   - config: Configuration parameters for the client.
    ///   - keyNamespace: Namespace to use for the keys and passwords.
    ///   - logger: A logger to use for logging messages. If none provided then a default internal logger will be used.
    public init(
        config: [String: Any],
        keyNamespace: String,
        logger: SudoLogging.Logger? = nil
    ) throws {
        let logger = logger ?? Logger.sudoUserLogger
        self.logger = logger
        self.logger.debug("Initializing with config: \(config), keyNamespace: \(keyNamespace)")
        keyManager = LegacySudoKeyManager(
            serviceName: Constants.KeyManager.defaultKeyManagerServiceName,
            keyTag: Constants.KeyManager.defaultKeyManagerKeyTag,
            namespace: keyNamespace
        )
        signInObserversActor = SignInObserversActor()
        clientStateActor = ClientStateActor(keyManager: keyManager)

        guard
            let identityServiceConfigDict = config[Constants.ConfigurationNamespace.identityService] as? [String: Any],
            let identityServiceConfig = identityServiceConfigDict.decoded(to: IdentityServiceConfig.self)
        else {
            throw SudoUserClientError.identityServiceConfigNotFound
        }
        self.identityServiceConfig = identityServiceConfig

        if let federatedSignInConfigDict = config[Constants.ConfigurationNamespace.federatedSignIn] as? [String: Any] {
            federatedSignInConfig = federatedSignInConfigDict.decoded(to: FederatedSignInConfig.self)
        } else {
            federatedSignInConfig = nil
        }

        let authConfiguration = ConfigurationTransformer.transform(
            identityServiceConfig: identityServiceConfig,
            federatedSignInConfig: federatedSignInConfig
        )
        let cognitoAuthPlugin = AWSCognitoAuthPlugin()
        try Amplify.add(plugin: cognitoAuthPlugin)
        try Amplify.configure(AmplifyConfiguration(auth: authConfiguration))

        authenticationWorker = DefaultAuthenticationWorker(
            keyManager: keyManager,
            authPlugin: cognitoAuthPlugin,
            logger: logger
        )
        do {
            try graphQLClient = DefaultGraphQLClient(
                apiName: Constants.ConfigurationNamespace.identityService,
                endpoint: identityServiceConfig.apiUrl,
                region: identityServiceConfig.region
            )
        } catch {
            throw SudoUserClientError.fatalError(description: "Failed to configure GraphQL client: \(error.localizedDescription)")
        }
    }

    // MARK: - Conformance: SudoUserClient

    public var version: String { SUDO_USER_VERSION }

    public func isRegistered() async throws -> Bool {
        return try await clientStateActor.isRegistered()
    }

    public func reset() async throws {
        logger.info("Resetting client.")
        try await clientStateActor.reset()
        try? await authenticationWorker.signOut()
    }

    public func registerWithDeviceCheck(
        token: Data,
        buildType: String,
        vendorId: UUID,
        registrationId: String?
    ) async throws -> String {
        let registrationId = registrationId ?? UUID().uuidString
        self.logger.info("Performing registration with DeviceCheck token: registrationId=\(registrationId)")

        guard !(try await clientStateActor.isRegistered()) else {
            throw SudoUserClientError.alreadyRegistered
        }

        // Clear out any partial registration data.
        try await reset()

        let publicKey = try await clientStateActor.generateRegistrationData()

        let challenge = RegistrationChallenge()
        challenge.type = .deviceCheck
        let answer = token.base64EncodedString()
        let buildType = buildType

        let uuid = UUID().uuidString
        var registrationParameters: [String: String] = [:]
        registrationParameters[Constants.RegistrationParameter.challengeType] = challenge.type.rawValue
        if answer.count > Constants.Limit.maxValidationDataSize {
            // If the answer exceeds the validation data size limit then divide up the answer to parts.
            let parts = answer.chunks(size: Constants.Limit.maxValidationDataSize)
            var parameters: [(String, String)] = []
            for (index, part) in parts.enumerated() {
                parameters.append(("\(Constants.RegistrationParameter.answer).\(index)", part))
            }

            registrationParameters.merge(parameters) {(_, new) in new}
            let answerMetadata: [String: Any] = ["parts": parameters.map { $0.0 }]
            guard let jsonData = answerMetadata.toJSONData() else {
                throw SudoUserClientError.fatalError(description: "Cannot serialize the answer metadata.")
            }
            registrationParameters[Constants.RegistrationParameter.answerMetadata] = String(data: jsonData, encoding: .utf8)
        } else {
            registrationParameters[Constants.RegistrationParameter.answer] = answer
        }
        registrationParameters[Constants.RegistrationParameter.registrationId] = registrationId

        let data = withUnsafePointer(to: vendorId.uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: vendorId.uuid))
        }
        registrationParameters[Constants.RegistrationParameter.deviceId] = data.base64EncodedString()
        registrationParameters[Constants.RegistrationParameter.buildType] = buildType

        guard let encodedKey = try String(data: publicKey.toData(), encoding: .utf8) else {
            throw SudoUserClientError.fatalError(description: "Cannot serialize the public key.")
        }

        registrationParameters[Constants.RegistrationParameter.publicKey] = encodedKey

        let uid = try await authenticationWorker.register(uid: uuid, parameters: registrationParameters)
        try await clientStateActor.setUserName(name: uid)

        logger.info("Registration with DeviceCheck token completed successfully.")
        return uid
    }

    public func registerWithAuthenticationProvider(
        authenticationProvider: AuthenticationProvider,
        registrationId: String?
    ) async throws -> String {
        let registrationId = registrationId ?? UUID().uuidString
        logger.info("Performing registration with authentication provider: registrationId=\(registrationId)")

        guard !(try await clientStateActor.isRegistered()) else {
            throw SudoUserClientError.alreadyRegistered
        }

        // Clear out any partial registration data.
        try await reset()

        var publicKey: PublicKey?
        if authenticationProvider is TESTAuthenticationProvider {
            publicKey = try await clientStateActor.generateRegistrationData()
        }

        var registrationParameters: [String: String] = [:]

        let authInfo = try await authenticationProvider.getAuthenticationInfo()
        let uuid = authInfo.getUsername()

        registrationParameters[Constants.RegistrationParameter.challengeType] = authInfo.type
        registrationParameters[Constants.RegistrationParameter.answer] = authInfo.toString()
        registrationParameters[Constants.RegistrationParameter.registrationId] = registrationId

        if let publicKey = publicKey {
            guard let encodedKey = try String(data: publicKey.toData(), encoding: .utf8) else {
                throw SudoUserClientError.fatalError(description: "Cannot serialize the public key.")
            }
            registrationParameters[Constants.RegistrationParameter.publicKey] = encodedKey
        }

        let uid = try await authenticationWorker.register(uid: uuid, parameters: registrationParameters)
        try await clientStateActor.setUserName(name: uid)

        logger.info("Registration with authentication provider completed successfully.")
        return uid
    }

    public func deregister() async throws {
        logger.info("Performing deregistration.")
        guard try await isRegistered() else {
            throw SudoUserClientError.notRegistered
        }
        do {
            _ = try await graphQLClient.mutate(DeregisterMutation())
        } catch {
            throw SudoUserClientError.graphQLError(cause: [error])
        }
        try await reset()
    }

    public func resetUserData() async throws {
        logger.info("Resetting user data.")

        guard try await isSignedIn() else {
            throw SudoUserClientError.notSignedIn
        }
        do {
            _ = try await graphQLClient.mutate(ResetMutation())
        } catch {
            throw SudoUserClientError.graphQLError(cause: [error])
        }
    }

    public func signInWithKey() async throws -> AuthenticationTokens {
        logger.info("Performing sign in with private key.")
        let uid = try await getUserName()
        guard
            let data = try keyManager.getPassword(Constants.KeyName.userKeyId),
            let keyId = String(data: data, encoding: .utf8)
        else {
            throw SudoUserClientError.notRegistered
        }
        let isSignedIn = try await authenticationWorker.getIsSignedIn()
        guard !isSignedIn else {
            throw SudoUserClientError.alreadySignedIn
        }
        await signInObserversActor.notifyObservers(status: .signingIn)

        let parameters: [String: Any] = [
            Constants.AuthenticationParameter.keyId: keyId,
            Constants.AuthenticationParameter.tokenLifetime: signInTokenLifetime
        ]
        do {
            var tokens = try await authenticationWorker.signIn(uid: uid, parameters: parameters)
            tokens = try await registerFederatedIdAndRefreshTokens(tokens: tokens)
            await signInObserversActor.notifyObservers(status: .signedIn)
            logger.info("Sign in with private key completed successfully.")
            return tokens
        } catch {
            await signInObserversActor.notifyObservers(status: .notSignedIn(cause: error))
            throw error
        }
    }

    public func signInWithAuthenticationProvider(authenticationProvider: AuthenticationProvider) async throws -> AuthenticationTokens {
        let isSignedIn = try await authenticationWorker.getIsSignedIn()
        guard !isSignedIn else {
            throw SudoUserClientError.alreadySignedIn
        }
        logger.info("Performing sign in with authentication provider.")
        await signInObserversActor.notifyObservers(status: .signingIn)

        let authInfo = try await authenticationProvider.getAuthenticationInfo()
        let uid = authInfo.getUsername()
        let parameters: [String: Any] = [
            Constants.AuthenticationParameter.challengeType: "FSSO",
            Constants.AuthenticationParameter.answer: authInfo.toString()
        ]
        do {
            var tokens = try await authenticationWorker.signIn(uid: uid, parameters: parameters)
            tokens = try await registerFederatedIdAndRefreshTokens(tokens: tokens)
            try await clientStateActor.setUserName(name: uid)
            await signInObserversActor.notifyObservers(status: .signedIn)
            logger.info("Sign in with authentication provider completed successfully.")
            return tokens
        } catch {
            await signInObserversActor.notifyObservers(status: .notSignedIn(cause: error))
            throw error
        }
    }

    public func presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor) async throws -> AuthenticationTokens {
        guard federatedSignInConfig != nil else {
            throw SudoUserClientError.invalidConfig
        }
        let isSignedIn = try await authenticationWorker.getIsSignedIn()
        guard !isSignedIn else {
            throw SudoUserClientError.alreadySignedIn
        }
        let tokens = try await authenticationWorker.presentFederatedSignInUI(presentationAnchor: presentationAnchor)
        let username = try await authenticationWorker.getUsername()
        try await clientStateActor.setUserName(name: username)
        return try await registerFederatedIdAndRefreshTokens(tokens: tokens)
    }

    public func presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor) async throws {
        guard federatedSignInConfig != nil else {
            throw SudoUserClientError.invalidConfig
        }
        try await authenticationWorker.presentFederatedSignOutUI(presentationAnchor: presentationAnchor)
    }

    public func refreshTokens() async throws -> AuthenticationTokens {
        logger.info("Refreshing authentication tokens.")
        await signInObserversActor.notifyObservers(status: .signingIn)
        do {
            let tokens = try await authenticationWorker.refreshTokens()
            await signInObserversActor.notifyObservers(status: .signedIn)

            logger.info("Authentication tokens refreshed successfully.")
            return tokens
        } catch {
            await signInObserversActor.notifyObservers(status: .notSignedIn(cause: error))
            throw error
        }
    }

    public func getUserName() async throws -> String {
        guard let username = try await clientStateActor.getUserName() else {
            throw SudoUserClientError.notRegistered
        }
        return username
    }

    public func getSubject() async throws -> String? {
        try await authenticationWorker.getUserId()
    }

    public func getIdToken() async throws -> String {
        let authTokens = try await authenticationWorker.getAuthTokens()
        return authTokens.idToken
    }

    public func getAccessToken() async throws -> String {
        let authTokens = try await authenticationWorker.getAuthTokens()
        return authTokens.accessToken
    }

    public func getRefreshToken() async throws -> String {
        let authTokens = try await authenticationWorker.getAuthTokens()
        return authTokens.refreshToken
    }

    public func clearAuthTokens() async throws {
        logger.info("Performing local sign out.")
        try await authenticationWorker.signOutLocally()
    }

    public func signOut() async throws {
        logger.info("Performing sign out.")
        try await authenticationWorker.signOut()
    }

    public func globalSignOut() async throws {
        logger.info("Performing global sign out.")
        do {
            _ = try await graphQLClient.mutate(GlobalSignOutMutation())
        } catch {
            throw SudoUserClientError.graphQLError(cause: [error])
        }
        try await authenticationWorker.signOutLocally()
    }

    public func getIdentityId() async throws -> String {
        try await authenticationWorker.getIdentityId()
    }

    public func getUserClaim(name: String) async throws -> Any? {
        let authTokens = try await authenticationWorker.getAuthTokens()
        let idToken = try JWT(string: authTokens.idToken, keyManager: nil)
        return idToken.payload[name]
    }

    public func isSignedIn() async throws -> Bool {
        try await authenticationWorker.getIsSignedIn()
    }

    public func registerSignInStatusObserver(id: String, observer: SignInStatusObserver) async {
        await signInObserversActor.registerSignInStatusObserver(id: id, observer: observer)
    }

    public func deregisterSignInStatusObserver(id: String) async {
        await signInObserversActor.deregisterSignInStatusObserver(id: id)
    }

    public func getSupportedRegistrationChallengeType() -> [ChallengeType] {
        identityServiceConfig.registrationMethods
    }

    // MARK: - Helpers

    /// Performs federated sign in and binds the resulting identity ID to the user. It also refreshes the authentication tokens so that
    ///  the ID token contains the identity ID as a claim.
    /// - Parameter tokens: The authentication tokens.
    /// - Returns: The updated authentication tokens.
    func registerFederatedIdAndRefreshTokens(tokens: AuthenticationTokens) async throws -> AuthenticationTokens {
        guard try await getUserClaim(name: "custom:identityId") == nil else {
            await signInObserversActor.notifyObservers(status: .signedIn)
            return tokens
        }
        logger.info("Registering federated identity.")
        do {
            let registerFederatedIdInput = RegisterFederatedIdInput(idToken: tokens.idToken)
            let registerFederatedIdMutation = RegisterFederatedIdMutation(input: registerFederatedIdInput)
            _ = try await graphQLClient.mutate(registerFederatedIdMutation)
            logger.info("Federated identity registered successfully.")
        } catch {
            throw SudoUserClientError.graphQLError(cause: [error])
        }
        // Refresh the ID token so it contains the registered identity ID as a claim.
        return try await refreshTokens()
    }
}
