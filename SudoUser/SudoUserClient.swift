//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager
import SudoLogging
import AWSCognitoIdentityProvider
import AWSCore
import AWSMobileClient
import AWSS3
import AWSAppSync
import SudoConfigManager

/// List of possible errors thrown by `SudoUserClient` implementation.
///
/// - alreadyRegistered: Thrown when attempting to register but the client is already registered.
/// - registerOperationAlreadyInProgress: Thrown when duplicate register calls are made.
/// - refreshTokensOperationAlreadyInProgress: Thrown when duplicate refreshTokens calls are made.
/// - signInOperationAlreadyInProgress: Thrown when duplicate signIn calls are made.
/// - notRegistered: Indicates the client has not been registered to the
///     Sudo platform backend.
/// - notSignedIn: Indicates the API being called requires the client to sign in.
/// - keyNotFound: Required key was not found.
/// - invalidConfig: Indicates the configuration dictionary passed to initialize the client was not valid.
/// - authTokenMissing: Thrown when required authentication tokens were not return by identity service.
/// - notAuthorized: Indicates the authentication failed. Likely due to incorrect private key, the identity
///     being removed from the backend or significant clock skew between the client and the backend.
/// - invalidInput: Indicates the input to the API was invalid.
/// - fatalError: Indicates that a fatal error occurred. This could be due to
///     coding error, out-of-memory condition or other conditions that is
///     beyond control of `SudoUserClient` implementation.
public enum SudoUserClientError: Error {
    case alreadyRegistered
    case registerOperationAlreadyInProgress
    case refreshTokensOperationAlreadyInProgress
    case signInOperationAlreadyInProgress
    case invalidRegistrationChallengeType
    case keyNotFound(keyName: String)
    case notRegistered
    case notSignedIn
    case noAuthenticationProvider
    case invalidConfig
    case authTokenMissing
    case notAuthorized
    case invalidInput
    case fatalError(description: String)
}

/// Generic API result. The API can fail with an error or complete successfully.
public enum ApiResult {
    case success
    case failure(cause: Error)
}

/// Result returned by API for initiating a registration challenge. The API
/// can fail with an error or return a list of registration challenges.
public enum GetRegistrationChallengesResult {
    case success(challenges: [RegistrationChallenge])
    case failure(cause: Error)
}

/// List of supported symmetric key encryption algorithms.
public enum SymmetricKeyEncryptionAlgorithm: String {
    case aesCBCPKCS7Padding = "AES/CBC/PKCS7Padding"
}

/// Protocol encapsulating a library of functions for calling Sudo Platform
/// identity services, managing keys, performing cryptographic operations.
public protocol SudoUserClient: class {

    /// The release version of this instance of `SudoUserClient`.
    var version: String { get }

    /// Indicates whether or not this client is registered with Sudo Platform
    /// backend.
    ///
    /// - Returns: `true` if the client is registered.
    func isRegistered() -> Bool

    /// Get the Symmetric Key ID associated with this client. The Symmetric Key ID is generated during a register
    /// request and saved within the keychain for the current device.
    ///
    /// - Returns: Symmetric Key ID associated with the device.
    /// - Throws: `SudoUserClientError.fatalError`
    func getSymmetricKeyId() throws -> String

    /// Removes all keys associated with this client and invalidates any
    /// cached authentication credentials.
    ///
    /// - Throws: `SudoUserClientError.FatalError`
    func reset() throws

    /// Get an iOS DeviceCheck based challenge from the backend.
    ///
    /// - Parameters:
    ///   - deviceToken: DeviceCheck token for the current device.
    ///   - buildType: Build type, e.g. "debug" or "release".
    ///   - completion: The completion handler to invoke to pass the result.
    @available(*, deprecated, message: "Use registerWithDeviceCheck instead.")
    func getDeviceCheckChallenge(deviceToken: Data, buildType: String, completion: @escaping (GetRegistrationChallengesResult) -> Void) throws

    /// Registers this client against the backend with a registration challenge and validation data.
    ///
    /// - Parameters:
    ///   - challenge: The registration challenge that has the `answer` property set.
    ///   - vendorId: An alphanumeric string that uniquely identifies a device to the app’s vendor. Obtained via
    ///     `identifierForVendor` property of `UIDevice` class.
    ///   - registrationId: The registration ID  used for uniquely identifying the registration request in case it fails.
    ///   - completion: The completion handler to invoke to pass the registration result.
    func register(challenge: RegistrationChallenge,
                  vendorId: UUID?,
                  registrationId: String?,
                  completion: @escaping (RegisterResult) -> Void) throws

    /// Registers this client against the backend with a registration challenge and validation data.
    ///
    /// - Parameters:
    ///   - token: Apple DeviceCheck token..
    ///   - buildType: Build type of the App from which the DeviceCheck token was retrieved, e.g. "debug" or "release".
    ///   - vendorId: An alphanumeric string that uniquely identifies a device to the app’s vendor. Obtained via
    ///     `identifierForVendor` property of `UIDevice` class.
    ///   - registrationId: The registration ID  used for uniquely identifying the registration request in case it fails.
    ///   - completion: The completion handler to invoke to pass the registration result.
    func registerWithDeviceCheck(token: Data,
                                 buildType: String,
                                 vendorId: UUID?,
                                 registrationId: String?,
                                 completion: @escaping (RegisterResult) -> Void) throws

    /// Registers this client against the backend with an external authentication provider. Caller must
    /// implement `AuthenticationProvider` protocol to return appropriate authentication token required
    /// to authorize the registration request.
    ///
    /// - Parameters:
    ///   - authenticationProvider: Authentication provider that provides the authentication token.
    ///   - registrationId: The registrationId if known.
    ///   - completion: The completion handler to invoke to pass the registration result.
    func registerWithAuthenticationProvider(authenticationProvider: AuthenticationProvider,
                                            registrationId: String?,
                                            completion: @escaping (RegisterResult) -> Void) throws

    /// Deregisters this client from the backend and resets the keychain. Will throw an error if an error occurred
    /// while attempting to reset the keychain.
    ///
    /// - Parameter completion: The completion handler to invoke to pass the deregistration result.
    func deregister(completion: @escaping (DeregisterResult) -> Void) throws

    /// Sign into the backend using a private key. The client must have created a private/public key pair via
    /// `register` method.
    ///
    /// - Parameter completion: The completion handler to invoke to pass the sign in result.
    func signInWithKey(completion: @escaping (SignInResult) -> Void) throws

    /// Presents the sign in UI for federated sign in using an external identity provider.
    ///
    /// - Parameters:
    ///   - navigationController: The navigation controller which would act as the anchor for this UI.
    ///   - completion: The completion handler to invoke to pass the sign in result.
    func presentFederatedSignInUI(navigationController: UINavigationController,
                                  completion: @escaping(SignInResult) -> Void) throws

    /// Presents the sign out UI for federated sign in using an external identity provider.
    ///
    /// - Parameters:
    ///   - navigationController: The navigation controller which would act as the anchor for this UI.
    ///   - completion: The completion handler to invoke to pass the sign out result.
    func presentFederatedSignOutUI(navigationController: UINavigationController,
                                   completion: @escaping(ApiResult) -> Void) throws

    /// Refreshes the access and ID tokens using the refresh token. The refresh token expires after 30 days so
    /// sign in again to obtain a new refresh token before its expiry. The tokens will also be refreshed automatically
    /// when you call platform APIs requiring authentication but there will be added delay in the API response.
    /// For more consistent response time for each API call, call this API to proactively keep the tokens fresh.
    ///
    /// - Parameters:
    ///   - refreshToken: Refresh token.
    ///   - completion: The completion handler to invoke to pass the token refresh result.
    func refreshTokens(refreshToken: String, completion: @escaping (SignInResult) -> Void) throws

    /// Returns the user name associated with this client.
    /// Note: This is an internal method used by other Sudo platform SDKs.
    ///
    /// - Returns: User name.
    func getUserName() throws -> String?

    /// Returns the subject of the user associated with this client.
    /// Note: This is an internal method used by other Sudo platform SDKs.
    ///
    /// - Returns: Subject.
    func getSubject() throws -> String?

    /// Returns the ID token cached from the last sign-in.
    /// Note: This is an internal method used by other Sudo platform SDKs.
    ///
    /// - Returns: ID token.
    func getIdToken() throws -> String?

    /// Returns the access token cached from the last sign-in.
    /// Note: This is an internal method used by other Sudo platform SDKs.
    ///
    /// - Returns: Access token.
    func getAccessToken() throws -> String?

    /// Returns the refresh token cached from the last sign-in. Use for callling `refreshTokens` API
    /// to refresh the authentication tokens.
    ///
    /// - Returns: Refresh token.
    func getRefreshToken() throws -> String?

    /// Returns the ID and access token expiry cached from the last sign-in. The tokens should be
    /// refreshed before they expired otherwise the platform APIs requiring authentication may fail.
    ///
    /// - Returns: Token expiry.
    func getTokenExpiry() throws -> Date?

    /// Encrypts the given data using the specified key and encryption algorithm.
    ///
    /// - Parameters:
    ///   - keyId: ID of the encryption key to use.
    ///   - algorithm: Encryption algorithm to use.
    ///   - data: Data to encrypt.
    ///
    /// - Returns: Encrypted data.
    func encrypt(keyId: String, algorithm: SymmetricKeyEncryptionAlgorithm, data: Data) throws -> Data

    /// Encrypts the given data using the specified key and encryption algorithm.
    ///
    /// - Parameters:
    ///   - keyId: ID of the encryption key to use.
    ///   - algorithm: Encryption algorithm to use.
    ///   - data: Data to decrypt.
    ///
    /// - Returns: Decrypted data.
    func decrypt(keyId: String, algorithm: SymmetricKeyEncryptionAlgorithm, data: Data) throws -> Data

    /// Clears cached authentication tokens.
    func clearAuthTokens() throws

    /// Signs out the user from all devices.
    ///
    /// - Parameter completion: The completion handler to invoke to pass the sign out result.
    func globalSignOut(completion: @escaping(ApiResult) -> Void) throws

    /// Retrieves and returns the identity ID associated with the temporary credential used for
    /// accessing certain backend resources, e.g. large blobs stored in AWS S3.
    ///
    /// - Returns:Identity ID.
    func getIdentityId() -> String?

    /// Returns the specified claim associated with the user's identity.
    ///
    /// - Parameter name: Claim name.
    /// - Returns: The specified claim value. The value can be of any JSON supported types. Safe cast
    ///     it the expected Swift type before using it, e.g. `Dictionary`, `Array`, `String`, `Number`
    ///     or `Bool`.
    func getUserClaim(name: String) throws -> Any?

    /// Stores the authentication tokens to the client's cache.
    ///
    /// - Parameters:
    ///   - tokens: Authentication tokens to store.
    func storeTokens(tokens: AuthenticationTokens) throws

    /// Indicates whether or not the client is signed in. The client is considered signed in if it currently caches
    /// valid ID and access tokens.
    ///
    /// - Returns: `true` if the client is signed in.
    func isSignedIn() throws -> Bool

}

public class DefaultSudoUserClient: SudoUserClient {

    /// Configuration parameter names.
    public struct Config {

        // Configuration namespace.
        struct Namespace {
            // Identity service related configuration.
            static let identityService = "identityService"
            // Federated sign in related configuration
            static let federatedSignIn = "federatedSignIn"
        }

        struct IdentityService {
            // AWS region hosting the identity service.
            static let region = "region"
            // AWS Cognito user pool ID of the identity service.
            static let userPoolId = "poolId"
            // ID of the client configured to access the user pool.
            static let clientId = "clientId"
            // Lifetime of the private key based authentication token.
            static let tokenLifetime = "tokenLifetime"
            // AWS Cognito identity pool ID of the identity service.
            static let identityPoolId = "identityPoolId"
            // API URL.
            static let apiUrl = "apiUrl"
            // API key.
            static let apiKey = "apiKey"
        }

        struct PushChallenge {
            // AWS region hosting the push challenge service.
            static let region = "region"
            // API URL.
            static let apiUrl = "apiUrl"
            // API key.
            static let apiKey = "apiKey"
        }

        struct S3 {
            // Service client key for S3 client specific to Sudo platform.
            static let serviceClientKey = "com.sudoplatform.s3"
        }

    }

    private struct Constants {

        struct KeyName {
            static let symmetricKeyId = "symmetricKeyId"
            static let userId = "userId"
            static let userKeyId = "userKeyId"
            static let idToken = "idToken"
            static let accessToken = "accessToken"
            static let refreshToken = "refreshToken"
            static let tokenExpiry = "tokenExpiry"
            static let identityId = "identityId"
        }

        struct Encryption {
            static let algorithmRSA = "RSA"
            static let algorithmAES128 = "AES/128"
            static let algorithmAES256 = "AES/256"
            static let defaultSymmetricKeyName = "symmetrickey"
        }

        struct KeyManager {
            static let defaultKeyManagerServiceName = "com.sudoplatform.appservicename"
            static let defaultKeyManagerKeyTag = "com.sudoplatform"
        }

        struct Auth {
            static let authTokenDefaultExpiry = 7200.0
            static let authTokenExpiryClockSkewToleranceInSec = 600.0
        }

    }

    /// Default logger for SudoUserClient.
    private let logger: Logger

    /// KeyManager instance used for cryptographic operations.
    private var keyManager: SudoKeyManager

    /// GraphQL client used calling Identity Service API.
    private var apiClient: AWSAppSyncClient?

    public var version: String {
        return SUDO_USER_VERSION
    }

    /// A tuple encapsulating the authentication token and its expiry.
    private var authToken: (token: String, expiry: Date)?

    private let queue = DispatchQueue(label: "com.sudoplatform.sudouser")

    private var registerOperationQueue = UserOperationQueue()

    private var signInOperationQueue = UserOperationQueue()

    /// Identity provider to use for registration and authentication.
    private var identityProvider: IdentityProvider

    /// Lifetime of private key based token in seconds.
    private var tokenLifetime: Int = 300

    /// Federated authentication UI.
    private var authUI: AuthUI?

    /// Credentials provider required to access AWS resources such as S3.
    private lazy var credentialsProvider: CredentialsProvider = {
        return AWSCredentialsProvider(
            client: self,
            regionType: self.regionType,
            userPoolId: self.userPoolId,
            identityPoolId: self.identityPoolId
        )
    }()

    /// GraphQL authentication provider.
    private lazy var graphQLAuthProvider: GraphQLAuthProvider = {
        return GraphQLAuthProvider(client: self)
    }()

    /// AWS region hosting identity service as `String`.
    private let region: String

    /// AWS region hosting identity service as `AWSRegionType`. Some AWS APIs
    /// require this instead of `String` variant of it.
    private let regionType: AWSRegionType

    /// ID of AWS Cognito User Pool used by identity service.
    private let userPoolId: String

    /// ID of AWS Cognito Identity Pool used by identity service.
    private let identityPoolId: String

    /// Config provider used to initialize an `AWSAppSyncClient` that can talk to GraphQL endpoint of
    /// the identity service.
    private let configProvider: SudoUserClientConfigProvider

    /// Intializes a new `DefaultSudoUserClient` instance. It uses configuration parameters defined in
    /// `sudoplatformconfig.json` file located in the app bundle.
    ///
    /// - Parameters:
    ///   - keyNamespace: Namespace to use for the keys and passwords.
    ///   - logger: A logger to use for logging messages. If none provided then a default
    ///         internal logger will be used.
    convenience public init(keyNamespace: String, logger: Logger? = nil) throws {
        guard let configManager = DefaultSudoConfigManager(),
            let identityServiceConfig = DefaultSudoConfigManager()?.getConfigSet(namespace: Config.Namespace.identityService) else {
            throw SudoUserClientError.invalidConfig
        }

        var config: [String: Any] = [:]
        config[Config.Namespace.identityService] = identityServiceConfig

        if let federatedSignInConfig = configManager.getConfigSet(namespace: Config.Namespace.federatedSignIn) {
            config[Config.Namespace.federatedSignIn] = federatedSignInConfig
        }

        try self.init(config: config, keyNamespace: keyNamespace, logger: logger)
    }

    /// Intializes a new `DefaultSudoUserClient` instance.
    ///
    /// - Parameters:
    ///   - config: Configuration parameters for the client.
    ///   - keyNamespace: Namespace to use for the keys and passwords.
    ///   - credentialsProvider: Credentials provider to use for obtaining AWS credential. Mainly used for unit testing.
    ///   - identityProvider: Identity provider to use to user management. Mainly used for unit testing.
    ///   - registrationChallengeClient: GraphQL client to use for communicating with the challenge service.
    ///         Mainly used for unit testing.
    ///   - apiClient: GrpahQL client to use for Identity Service API. Mainly used for unit testing.
    ///   - authUI: AuthUI used for presenting federated sign in UI. Mainly used for unit testing.
    ///   - logger: A logger to use for logging messages. If none provided then a default
    ///         internal logger will be used.
    public init(config: [String: Any],
                keyNamespace: String,
                credentialsProvider: CredentialsProvider? = nil,
                identityProvider: IdentityProvider? = nil,
                registrationChallengeClient: GraphQLClient? = nil,
                apiClient: AWSAppSyncClient? = nil,
                authUI: AuthUI? = nil,
                logger: Logger? = nil) throws {
        let logger = logger ?? Logger.sudoUserLogger
        self.logger = logger

        self.logger.debug("Initializing with config: \(config), keyNamespace: \(keyNamespace)")

        let keyManager = SudoKeyManagerImpl(serviceName: Constants.KeyManager.defaultKeyManagerServiceName,
                                        keyTag: Constants.KeyManager.defaultKeyManagerKeyTag,
                                        namespace: keyNamespace)
        self.keyManager = keyManager

        guard let identityServiceConfig = config[Config.Namespace.identityService] as? [String: Any] else {
            throw SudoUserClientError.invalidConfig
        }

        try self.identityProvider = identityProvider ?? CognitoUserPoolIdentityProvider(config: identityServiceConfig, keyManager: keyManager, logger: logger)

        guard let region = identityServiceConfig[Config.IdentityService.region] as? String,
            let regionType = AWSEndpoint.regionTypeFrom(name: region),
            let userPoolId = identityServiceConfig[Config.IdentityService.userPoolId] as? String,
            let identityPoolId = identityServiceConfig[Config.IdentityService.identityPoolId] as? String else {
                throw SudoUserClientError.invalidConfig
        }

        self.region = region
        self.regionType = regionType
        self.userPoolId = userPoolId
        self.identityPoolId = identityPoolId

        if let tokenLifetime = config[Config.IdentityService.tokenLifetime] as? Int {
            self.tokenLifetime = tokenLifetime
        }

        guard let configProvider = SudoUserClientConfigProvider(config: identityServiceConfig) else {
            throw SudoUserClientError.invalidConfig
        }

        self.configProvider = configProvider

        if let federatedSignInConfig = config[Config.Namespace.federatedSignIn] as? [String: Any] {
            try self.authUI = authUI ?? CognitoAuthUI(config: federatedSignInConfig)
        }

        if let apiClient = apiClient {
            self.apiClient = apiClient
        } else {
            // Set up an `AWSAppSyncClient` to call GraphQL API that requires sign in.
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: configProvider,
                                                                  userPoolsAuthProvider: self.graphQLAuthProvider,
                                                                  urlSessionConfiguration: URLSessionConfiguration.default,
                                                                  cacheConfiguration: AWSAppSyncCacheConfiguration.inMemory,
                                                                  connectionStateChangeHandler: nil,
                                                                  s3ObjectManager: nil,
                                                                  presignedURLClient: nil,
                                                                  retryStrategy: .aggressive)
            self.apiClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            self.apiClient?.apolloClient?.cacheKeyForObject = { $0["id"] }
        }

        if let credentialsProvider = credentialsProvider {
            self.credentialsProvider = credentialsProvider
        }
    }

    public func isRegistered() -> Bool {
        var username: String?
        var privateKey: Data?
        do {
            username = try self.getUserName()

            if let keyId = try self.getPrivateKeyId() {
                privateKey = try self.keyManager.getPrivateKey(keyId)
            }
        } catch {
            self.logger.error("Failed to retrieve key from the keychain.")
        }

        return username != nil && privateKey != nil
    }

    public func getSymmetricKeyId() throws -> String {
        guard let symmKeyIdData = try self.keyManager.getPassword(Constants.KeyName.symmetricKeyId), let symmetricKeyId = String(data: symmKeyIdData, encoding: .utf8) else {
            throw SudoUserClientError.fatalError(description: "Symmetric key missing.")
        }

        return symmetricKeyId
    }

    public func reset() throws {
        self.logger.info("Resetting client.")

        do {
            try self.keyManager.removeAllKeys()
            self.credentialsProvider.reset()
        } catch let error {
            let message = "Unexpected error occurred while trying to remove all keys: \(error)."
            self.logger.error(message)
            throw SudoUserClientError.fatalError(description: message)
        }
    }

    public func getDeviceCheckChallenge(deviceToken: Data, buildType: String, completion: @escaping (GetRegistrationChallengesResult) -> Void) throws {
        completion(.failure(cause: SudoUserClientError.fatalError(description: "API no longer supported.")))
    }

    public func register(challenge: RegistrationChallenge,
                         vendorId: UUID? = nil,
                         registrationId: String? = nil,
                         completion: @escaping (RegisterResult) -> Void) throws {
        self.logger.info("Performing registration.")

        try self.queue.sync {
            guard !isRegistered() else {
                throw SudoUserClientError.alreadyRegistered
            }

            guard self.registerOperationQueue.operationCount == 0 else {
                throw SudoUserClientError.registerOperationAlreadyInProgress
            }

            // Clear out any partial registration data.
            try self.reset()

            let publicKey = try self.generateRegistrationData()

            let op = Register(challenge: challenge,
                                       vendorId: vendorId,
                                       registrationId: registrationId,
                                       publicKey: publicKey,
                                       identityProvider: self.identityProvider,
                                       logger: self.logger)
            op.completionBlock = {
                if let error = op.error {
                    completion(RegisterResult.failure(cause: error))
                } else {
                    guard let uid = op.uid else {
                        return completion(.failure(cause: SudoUserClientError.fatalError(description: "uid not found.")))
                    }

                    do {
                        try self.setUserName(name: uid)
                    } catch let error {
                        return completion(.failure(cause: SudoUserClientError.fatalError(description: "Failed to set user name: \(error)")))
                    }

                    self.logger.info("Registration completed successfully..")

                    completion(.success(uid: uid))
                }
            }

            self.registerOperationQueue.addOperation(op)
        }
    }

    public func registerWithDeviceCheck(token: Data,
                                        buildType: String,
                                        vendorId: UUID?,
                                        registrationId: String?,
                                        completion: @escaping (RegisterResult) -> Void) throws {
        self.logger.info("Performing registration.")

        try self.queue.sync {
            guard !isRegistered() else {
                throw SudoUserClientError.alreadyRegistered
            }

            guard self.registerOperationQueue.operationCount == 0 else {
                throw SudoUserClientError.registerOperationAlreadyInProgress
            }

            // Clear out any partial registration data.
            try self.reset()

            let publicKey = try self.generateRegistrationData()

            let challenge = RegistrationChallenge()
            challenge.type = .deviceCheck
            challenge.answer = token.base64EncodedString()
            challenge.buildType = buildType

            let op = Register(challenge: challenge,
                                       vendorId: vendorId,
                                       registrationId: registrationId,
                                       publicKey: publicKey,
                                       identityProvider: self.identityProvider,
                                       logger: self.logger)
            op.completionBlock = {
                if let error = op.error {
                    completion(RegisterResult.failure(cause: error))
                } else {
                    guard let uid = op.uid else {
                        return completion(.failure(cause: SudoUserClientError.fatalError(description: "uid not found.")))
                    }

                    do {
                        try self.setUserName(name: uid)
                    } catch let error {
                        return completion(.failure(cause: SudoUserClientError.fatalError(description: "Failed to set user name: \(error)")))
                    }

                    self.logger.info("Registration completed successfully..")

                    completion(.success(uid: uid))
                }
            }

            self.registerOperationQueue.addOperation(op)
        }
    }

    public func registerWithAuthenticationProvider(authenticationProvider: AuthenticationProvider,
                                                   registrationId: String?,
                                                   completion: @escaping (RegisterResult) -> Void) throws {
        self.logger.info("Performing registration with external authentication provider.")

        try self.queue.sync {
            guard !isRegistered() else {
                throw SudoUserClientError.alreadyRegistered
            }

            guard self.registerOperationQueue.operationCount == 0 else {
                throw SudoUserClientError.registerOperationAlreadyInProgress
            }

            // Clear out any partial registration data.
            try self.reset()

            let publicKey = try self.generateRegistrationData()

            let op = RegisterWithAuthenticationProvider(authenticationProvider: authenticationProvider,
                                                                 registrationId: registrationId,
                                                                 publicKey: publicKey,
                                                                 identityProvider: self.identityProvider,
                                                                 logger: self.logger)
            op.completionBlock = {
                if let error = op.error {
                    completion(RegisterResult.failure(cause: error))
                } else {
                    guard let uid = op.uid else {
                        return completion(RegisterResult.failure(cause: SudoUserClientError.fatalError(description: "uid not found.")))
                    }

                    do {
                        try self.setUserName(name: uid)
                    } catch let error {
                        return completion(RegisterResult.failure(cause: SudoUserClientError.fatalError(description: "Failed to set user name: \(error)")))
                    }

                    completion(.success(uid: uid))
                }
            }

            self.registerOperationQueue.addOperation(op)
        }
    }

    public func deregister(completion: @escaping (DeregisterResult) -> Void) throws {
        self.logger.info("Performing deregistration.")

        guard let uid = try self.getUserName() else {
            throw SudoUserClientError.notRegistered
        }

        guard let apiClient = self.apiClient else {
            throw SudoUserClientError.invalidConfig
        }

        apiClient.perform(mutation: DeregisterMutation(), queue: self.queue) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                completion(.failure(cause: GraphQLClientError.graphQLError(cause: [error])))
            } else {
                if let errors = result?.errors {
                    completion(.failure(cause: GraphQLClientError.graphQLError(cause: errors)))
                } else {
                    self.logger.info("User deregistered successfully..")

                    do {
                        try self.reset()
                        completion(.success(uid: uid))
                    } catch let error {
                        completion(.failure(cause: error))
                    }
                }
            }
        }
    }

    public func signInWithKey(completion: @escaping (SignInResult) -> Void) throws {
        self.logger.info("Performing sign in with private key.")

        try self.queue.sync {
            guard self.signInOperationQueue.operationCount == 0 else {
                throw SudoUserClientError.signInOperationAlreadyInProgress
            }

            guard let apiClient = self.apiClient else {
                throw SudoUserClientError.invalidConfig
            }

            // Retrieve the stored user name and private key ID from the keychain.
            guard let uid = try self.getUserName(),
                let data = try self.keyManager.getPassword(Constants.KeyName.userKeyId),
                let keyId = String(data: data, encoding: .utf8) else {
                    throw SudoUserClientError.notRegistered
            }

            let parameters: [String: Any] = [CognitoUserPoolIdentityProvider.AuthenticationParameter.keyId: keyId,
                                             CognitoUserPoolIdentityProvider.AuthenticationParameter.tokenLifetime: self.tokenLifetime]

            let op = SignInWithKey(identityProvider: self.identityProvider, sudoUserClient: self, uid: uid, parameters: parameters)
            op.completionBlock = {
                if let error = op.error {
                    completion(.failure(cause: error))
                } else {
                    if let tokens = op.tokens {
                        self.credentialsProvider.clearCredentials()
                        do {
                            try self.registerFederatedIdAndRefreshTokens(apiClient: apiClient, sudoUserClient: self, tokens: tokens, completion: completion)
                        } catch {
                            completion(.failure(cause: error))
                        }
                    } else {
                        completion(.failure(cause: SudoUserClientError.fatalError(description: "RefreshTokens operation completed successfully but tokens were missing.")))
                    }
                }
            }
            self.signInOperationQueue.addOperation(op)
        }
    }

    public func presentFederatedSignInUI(navigationController: UINavigationController,
                                         completion: @escaping(SignInResult) -> Void) throws {
        guard let authUI = self.authUI,
            let apiClient = self.apiClient else {
            throw SudoUserClientError.invalidConfig
        }

        try authUI.presentFederatedSignInUI(navigationController: navigationController) { (result) in
            do {
                switch result {
                case let .success(tokens, username):
                    self.logger.info("Sign in completed successfully.")

                    try self.setUserName(name: username)
                    try self.storeTokens(tokens: tokens)

                    // Generate the symmetric key if one does not exist already.
                    do {
                        _ = try self.getSymmetricKeyId()
                    } catch {
                        try self.generatedSymmetricKey()
                    }

                    self.credentialsProvider.clearCredentials()
                    try self.registerFederatedIdAndRefreshTokens(apiClient: apiClient, sudoUserClient: self, tokens: tokens, completion: completion)
                case let .failure(cause):
                    completion(SignInResult.failure(cause: cause))
                }
            } catch let error {
                completion(.failure(cause: error))
            }
        }
    }

    public func presentFederatedSignOutUI(navigationController: UINavigationController,
                                          completion: @escaping(ApiResult) -> Void) throws {
        guard let authUI = self.authUI else {
            throw SudoUserClientError.invalidConfig
        }

        try authUI.presentFederatedSignOutUI(navigationController: navigationController, completion: completion)
    }

    public func refreshTokens(refreshToken: String, completion: @escaping (SignInResult) -> Void) throws {
        self.logger.info("Refreshing authentication tokens.")

        try self.queue.sync {
            guard self.signInOperationQueue.operationCount == 0 else {
                throw SudoUserClientError.refreshTokensOperationAlreadyInProgress
            }

            let op = RefreshTokens(identityProvider: self.identityProvider, sudoUserClient: self, refreshToken: refreshToken)
            op.completionBlock = {
                if let error = op.error {
                    completion(.failure(cause: error))
                } else {
                    if let tokens = op.tokens {
                        self.credentialsProvider.clearCredentials()
                        completion(.success(tokens: tokens))
                    } else {
                        completion(.failure(cause: SudoUserClientError.fatalError(description: "RefreshTokens operation completed successfully but tokens were missing.")))
                    }
                }
            }
            self.signInOperationQueue.addOperation(op)
        }
    }

    public func getUserName() throws -> String? {
        guard let data = try self.keyManager.getPassword(Constants.KeyName.userId),
            let username = String(data: data, encoding: .utf8) else {
            return nil
        }

        return username
    }

    public func getSubject() throws -> String? {
        guard let idToken = try self.getIdToken() else {
            return nil
        }

        let jwt = try JWT(string: idToken, keyManager: nil)
        return jwt.subject
    }

    public func getIdToken() throws -> String? {
        guard let data = try self.keyManager.getPassword(Constants.KeyName.idToken),
            let idToken = String(data: data, encoding: .utf8) else {
                return nil
        }

        return idToken
    }

    public func getAccessToken() throws -> String? {
        guard let data = try self.keyManager.getPassword(Constants.KeyName.accessToken),
            let accessToken = String(data: data, encoding: .utf8) else {
                return nil
        }

        return accessToken
    }

    public func getTokenExpiry() throws -> Date? {
        guard let data = try self.keyManager.getPassword(Constants.KeyName.tokenExpiry),
            let string = String(data: data, encoding: .utf8),
            let tokenExpiry = Double(string) else {
                return nil
        }

        return Date(timeIntervalSince1970: tokenExpiry)
    }

    public func getRefreshToken() throws -> String? {
        guard let data = try self.keyManager.getPassword(Constants.KeyName.refreshToken),
            let refreshToken = String(data: data, encoding: .utf8) else {
                return nil
        }

        return refreshToken
    }

    public func encrypt(keyId: String, algorithm: SymmetricKeyEncryptionAlgorithm, data: Data) throws -> Data {
        let iv = try self.keyManager.createIV()
        let encryptedData = try self.keyManager.encryptWithSymmetricKey(keyId, data: data, iv: iv)
        return encryptedData + iv
    }

    public func decrypt(keyId: String, algorithm: SymmetricKeyEncryptionAlgorithm, data: Data) throws -> Data {
        guard data.count > SudoKeyManagerImpl.Constants.defaultBlockSizeAES else {
            throw SudoUserClientError.invalidInput
        }

        let encryptedData = data[0..<data.count - 16]
        let iv = data[data.count - 16..<data.count]
        return try self.keyManager.decryptWithSymmetricKey(keyId, data: encryptedData, iv: iv)
    }

    public func clearAuthTokens() throws {
        try self.keyManager.deletePassword(Constants.KeyName.idToken)
        try self.keyManager.deletePassword(Constants.KeyName.accessToken)
        try self.keyManager.deletePassword(Constants.KeyName.refreshToken)
        try self.keyManager.deletePassword(Constants.KeyName.tokenExpiry)

        if let authUI = self.authUI {
            authUI.reset()
        }
    }

    public func globalSignOut(completion: @escaping(ApiResult) -> Void) throws {
        guard let accessToken = try self.getAccessToken() else {
            throw SudoUserClientError.notSignedIn
        }

        try self.identityProvider.globalSignOut(accessToken: accessToken, completion: completion)
        try self.clearAuthTokens()
    }

    public func getIdentityId() -> String? {
        return self.credentialsProvider.getCachedIdentityId()
    }

    public func getUserClaim(name: String) throws -> Any? {
        guard let idToken = try self.getIdToken() else {
            return nil
        }

        let jwt = try JWT(string: idToken, keyManager: nil)
        return jwt.payload[name]
    }

    public func isSignedIn() throws -> Bool {
        guard try self.getIdToken() != nil,
            try self.getAccessToken() != nil,
            let expiry = try self.getTokenExpiry() else {
                return false
        }

        return expiry > Date()
    }

    public func storeTokens(tokens: AuthenticationTokens) throws {
        guard let idTokenData = tokens.idToken.data(using: .utf8),
            let accessTokenData = tokens.accessToken.data(using: .utf8),
            let refreshTokenData = tokens.refreshToken.data(using: .utf8),
            let tokenExpiryData = "\(Date().timeIntervalSince1970 + Double(tokens.lifetime))".data(using: .utf8) else {
                throw SudoUserClientError.fatalError(description: "Tokens cannot be serialized.")
        }

        // Cache the tokens and token lifetime in the keychain.
        try self.keyManager.deletePassword(Constants.KeyName.idToken)
        try self.keyManager.addPassword(idTokenData, name: Constants.KeyName.idToken)

        try self.keyManager.deletePassword(Constants.KeyName.accessToken)
        try self.keyManager.addPassword(accessTokenData, name: Constants.KeyName.accessToken)

        try self.keyManager.deletePassword(Constants.KeyName.refreshToken)
        try self.keyManager.addPassword(refreshTokenData, name: Constants.KeyName.refreshToken)

        try self.keyManager.deletePassword(Constants.KeyName.tokenExpiry)
        try self.keyManager.addPassword(tokenExpiryData, name: Constants.KeyName.tokenExpiry)
    }

    private func getPrivateKeyId() throws -> String? {
        do {
            guard let data = try self.keyManager.getPassword(Constants.KeyName.userKeyId),
                let keyId = String(data: data, encoding: .utf8) else {
                    return nil
            }

            return keyId
        } catch {
            throw SudoUserClientError.fatalError(description: "Unexpected error occurred while retrieving private key ID.")
        }
    }

    private func setUserName(name: String) throws {
        guard let data = name.data(using: .utf8) else {
            throw SudoUserClientError.fatalError(description: "Cannot serialize user name.")
        }

        // Delete the user name first so there won't be a conflict when adding the new one.
        try self.keyManager.deletePassword(Constants.KeyName.userId)

        try self.keyManager.addPassword(data, name: Constants.KeyName.userId)
    }

    private func generateRegistrationData() throws -> PublicKey {
        // Generate a public/private key pair for this identity.
        let keyId = try self.keyManager.generateKeyId()
        try self.keyManager.deleteKeyPair(keyId)
        try self.keyManager.generateKeyPair(keyId)

        guard let publicKeyData = try self.keyManager.getPublicKey(keyId) else {
            throw SudoUserClientError.fatalError(description: "Public key not found.")
        }

        // Make sure the key ID that we are trying to add don't exist.
        try self.keyManager.deletePassword(Constants.KeyName.userKeyId)

        // Store the key ID for user key in the keychain.
        guard let keyIdData = keyId.data(using: .utf8) else {
            throw SudoUserClientError.fatalError(description: "Cannot convert key ID to data.")
        }

        try self.keyManager.addPassword(keyIdData, name: Constants.KeyName.userKeyId)

        try self.generatedSymmetricKey()

        let publicKey = PublicKey(publicKey: publicKeyData, keyId: keyId)

        return publicKey
    }

    private func generatedSymmetricKey() throws {
        // Generate symmetric key and store it under a unique key ID.
        let symmetricKeyId = try self.keyManager.generateKeyId()

        // Make sure symmetric key does not exists.
        try self.keyManager.deletePassword(Constants.KeyName.symmetricKeyId)
        try self.keyManager.deletePassword(symmetricKeyId)

        try self.keyManager.generateSymmetricKey(symmetricKeyId)

        guard let symmetricKeyIdData = symmetricKeyId.data(using: .utf8) else {
            throw SudoUserClientError.fatalError(description: "Cannot convert key ID to data.")
        }

        try self.keyManager.addPassword(symmetricKeyIdData, name: Constants.KeyName.symmetricKeyId)
    }

    /// Performs federated sign in and binds the resulting identity ID to the user. It also refreshes the authentication tokens so that
    ///  the ID token contains the identity ID as a claim.
    ///
    /// - Parameters:
    ///   - apiClient: GraphQL client used calling Identity Service API.
    ///   - sudoUserClient: `SudoUserClient` to store the authentication tokens.
    ///   - idToken: ID token to use for federated sign in.
    ///   - refreshToken: Refresh token to use for refreshing authentication tokens.
    ///   - completion: completion handler to pass the resulting tokens or error.
    private func registerFederatedIdAndRefreshTokens(apiClient: AWSAppSyncClient,
                                                     sudoUserClient: SudoUserClient,
                                                     tokens: AuthenticationTokens,
                                                     completion: @escaping (SignInResult) -> Void) throws {
        guard try self.getUserClaim(name: "custom:identityId") == nil else {
            return completion(.success(tokens: tokens))
        }

        self.logger.info("Registering federated identity.")

        let registerFederatedIdOp = RegisterFederatedId(apiClient: apiClient, idToken: tokens.idToken)
        let getIdentityIdOp = GetIdentityId(credentialsProvider: self.credentialsProvider)
        let refreshTokensOp = RefreshTokens(identityProvider: self.identityProvider, sudoUserClient: self, refreshToken: tokens.refreshToken)
        let operations: [UserOperation] = [registerFederatedIdOp, getIdentityIdOp, refreshTokensOp]

        getIdentityIdOp.addDependency(registerFederatedIdOp)
        refreshTokensOp.addDependency(getIdentityIdOp)

        refreshTokensOp.completionBlock = {
            let errors = operations.compactMap { $0.error }
            if let error = errors.first {
                completion(SignInResult.failure(cause: error))
            } else {
                if let tokens = refreshTokensOp.tokens {
                    completion(.success(tokens: tokens))
                } else {
                    completion(.failure(cause: SudoUserClientError.fatalError(description: "RefreshTokens operation completed successfully but tokens were missing.")))
                }
            }
        }

        self.signInOperationQueue.addOperations(operations, waitUntilFinished: false)
    }

}
