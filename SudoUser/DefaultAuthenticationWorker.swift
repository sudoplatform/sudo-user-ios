//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import AuthenticationServices
import Foundation
import SudoKeyManager
import SudoLogging

/// The default `AuthenticationWorker` that performs authentication tasks using the AWS Cognito Auth plugin.
actor DefaultAuthenticationWorker: AuthenticationWorker {

    // MARK: - Supplementary

    enum ExclusiveOperation: Equatable {
        case refreshTokens
        case signIn
        case register
    }

    // MARK: - Properties

    /// The utility for making AWS Cognito requests.
    let authPlugin: AWSCognitoAuthPlugin

    /// `KeyManager` instance required for signing authentication token.
    let keyManager: SudoKeyManager

    /// Utility for generating a random password to satisfy a provided password policy.
    let passwordGenerator: PasswordGenerator

    /// A logging instance.
    let logger: SudoLogging.Logger

    /// Used to avoid duplicate operations that need to be run exclusively.
    var currentOperation: ExclusiveOperation?

    // MARK: - Lifecycle

    /// Initializes a `DefaultAuthenticationWorker`.
    /// - Parameters:
    ///   - keyManager: `KeyManager` instance required for signing authentication token.
    ///   - authPlugin: The utility for making AWS Cognito requests.
    ///   - passwordGenerator: Utility for generating a random password to satisfy a provided password policy. A default is provided.
    ///   - logger: A logging instance.
    init(
        keyManager: SudoKeyManager,
        authPlugin: AWSCognitoAuthPlugin,
        passwordGenerator: PasswordGenerator = DefaultPasswordGenerator(),
        logger: SudoLogging.Logger
    ) {
        self.authPlugin = authPlugin
        self.keyManager = keyManager
        self.passwordGenerator = passwordGenerator
        self.logger = logger
    }

    // MARK: - Conformance: IdentityProvider

    func getIsSignedIn() async throws -> Bool {
        do {
            _ = try await fetchAuthTokens()
            return true
        } catch SudoUserClientError.notSignedIn,  SudoUserClientError.notAuthorized {
            return false
        }
    }

    func getUsername() async throws -> String {
        do {
            let user = try await authPlugin.getCurrentUser()
            return user.username
        } catch {
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        }
    }

    func getUserId() async throws -> String {
        do {
            let user = try await authPlugin.getCurrentUser()
            return user.userId
        } catch {
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        }
    }

    func getAuthTokens() async throws -> AuthenticationTokens {
        try await fetchAuthTokens(forceRefresh: false)
    }

    func getIdentityId() async throws -> String {
        do {
            guard let authSession = try await authPlugin.fetchAuthSession(options: nil) as? AWSAuthCognitoSession else {
                throw SudoUserClientError.notSignedIn
            }
            let identityId = try authSession.identityIdResult.get()
            return identityId
        } catch {
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        }
    }

    func register(uid: String, parameters: [String: String]) async throws -> String {
        try checkOperationExclusivity()
        currentOperation = .register
        defer { currentOperation = nil }
        do {
            // Generate a random password that complies with default Cognito user pool password policy. This password is actually
            // not used since we use a custom authentication using a signing key but is required to create a user.
            let password = passwordGenerator.generatePassword(length: 50, upperCase: true, lowerCase: true, special: true, number: true)
            let pluginOptions = AWSAuthSignUpOptions(validationData: parameters)
            let options = AuthSignUpRequest.Options(pluginOptions: pluginOptions)
            let result = try await authPlugin.signUp(username: uid, password: password, options: options)
            guard result.isSignUpComplete else {
                throw SudoUserClientError.identityNotConfirmed
            }
            return uid
        } catch {
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        }
    }

    func signIn(uid: String, parameters: [String: Any]) async throws -> AuthenticationTokens {
        try checkOperationExclusivity()
        currentOperation = .signIn
        defer { currentOperation = nil }
        do {
            try await signOutLocally()
            let pluginOptions = AWSAuthSignInOptions(metadata: parameters as? [String: String], authFlowType: .customWithoutSRP)
            let options = AuthSignInRequest.Options(pluginOptions: pluginOptions)
            let signInResult = try await authPlugin.signIn(username: uid, password: nil, options: options)
            guard case .confirmSignInWithCustomChallenge(let info) = signInResult.nextStep, let info else {
                throw SudoUserClientError.fatalError(description: "Incorrect response received from sign in")
            }
            let challengeResponse = try transformToChallengeResponse(uid: uid, info: info, parameters: parameters)
            let challengeResult = try await authPlugin.confirmSignIn(challengeResponse: challengeResponse, options: nil)
            guard challengeResult.isSignedIn else {
                throw SudoUserClientError.fatalError(description: "Unexpected auth state after successful challenge response")
            }
            return try await fetchAuthTokens()
        } catch {
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        }
    }

    func refreshTokens() async throws -> AuthenticationTokens {
        try checkOperationExclusivity()
        currentOperation = .refreshTokens
        defer { currentOperation = nil }
        return try await fetchAuthTokens(forceRefresh: true)
    }

    func signOut() async throws {
        let signOutResult = await authPlugin.signOut()
        try processSignOutResult(signOutResult)
    }

    func signOutLocally() async throws {
        let signOutResult = await authPlugin.signOut()
        try processSignOutResult(signOutResult, localOnly: true)
    }

    func presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor) async throws -> AuthenticationTokens {
        try checkOperationExclusivity()
        currentOperation = .signIn
        defer { currentOperation = nil }
        do {
            try await signOutLocally()
            let result = try await authPlugin.signInWithWebUI(presentationAnchor: presentationAnchor, options: .preferPrivateSession())
            guard result.isSignedIn else {
                throw SudoUserClientError.fatalError(description: "Unexpected auth state after successful federated sign in")
            }
            let authSession = try await authPlugin.fetchAuthSession(options: nil)
            guard
                let cognitoAuthSession = authSession as? AWSAuthCognitoSession,
                let tokens = try? cognitoAuthSession.userPoolTokensResult.get()
            else {
                throw SudoUserClientError.authTokenMissing
            }
            return AuthenticationTokens(idToken: tokens.idToken, accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
        } catch {
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        }
    }

    func presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor) async throws {
        let options = AuthSignOutRequest.Options(presentationAnchor: presentationAnchor)
        let signOutResult = await authPlugin.signOut(options: options)
        try processSignOutResult(signOutResult)
    }

    // MARK: - Helpers

    func transformToChallengeResponse(uid: String, info: AdditionalInfo, parameters: [String: Any]) throws -> String {
        if let challengeType = parameters[Constants.AuthenticationParameter.challengeType] as? String, challengeType == "FSSO" {
            guard let answer = parameters[Constants.AuthenticationParameter.answer] as? String else {
                throw SudoUserClientError.fatalError(description: "Answer missing from FSSO authentication parameters.")
            }
            return answer
        }
        guard let keyId = parameters[Constants.AuthenticationParameter.keyId] as? String else {
            throw SudoUserClientError.fatalError(description: "Key ID not provided.")
        }
        guard let audience = info[Constants.CognitoChallengeParameter.audience] else {
            throw SudoUserClientError.fatalError(description: "Audience challenge parameter missing from signIn result.")
        }
        guard let nonce = info[Constants.CognitoChallengeParameter.nonce] else {
            throw SudoUserClientError.fatalError(description: "Nonce challenge parameter missing from signIn result.")
        }
        // Default token lifetime of private key signed token is 5 minutes unless specified otherwise.
        let tokenLifetime = parameters[
            Constants.AuthenticationParameter.tokenLifetime
        ] as? TimeInterval ?? Constants.Default.signInTokenLifetime

        // Challenge requires the private key signed JWT as the answer.
        let jwt = JWT(issuer: uid, audience: audience, subject: uid, id: nonce)
        jwt.expiry = Date(timeIntervalSinceNow: tokenLifetime)

        let encodedJWT = try jwt.signAndEncode(keyManager: keyManager, keyId: keyId)
        return encodedJWT
    }

    func fetchAuthTokens(forceRefresh: Bool = false) async throws -> AuthenticationTokens {
        do {
            let options = AuthFetchSessionRequest.Options(forceRefresh: forceRefresh)
            guard
                let authSession = try await authPlugin.fetchAuthSession(options: options) as? AWSAuthCognitoSession,
                authSession.isSignedIn
            else {
                throw SudoUserClientError.notSignedIn
            }
            guard let tokens = try? authSession.userPoolTokensResult.get() else {
                throw SudoUserClientError.notAuthorized
            }
            return AuthenticationTokens(idToken: tokens.idToken, accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
        } catch {
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        }
    }

    func processSignOutResult(_ result: AuthSignOutResult, localOnly: Bool = false) throws {
        guard let signOutResult = result as? AWSCognitoSignOutResult else {
            throw SudoUserClientError.fatalError(description: "Unexpected result type returned from sign out")
        }
        switch signOutResult {
        case .complete:
            return
        case .failed(let error):
            let transformedError = SudoUserClientErrorTransformer.transform(error)
            throw transformedError
        case .partial(let revokeTokenError, let globalSignOutError, let hostedUIError):
            if localOnly {
                // At this point the user is signed out locally, so tolerating
                // any errors thrown
                return
            }
            var authError: AuthError?
            if let revokeTokenError {
                authError = revokeTokenError.error
            }
            if let globalSignOutError {
                authError = globalSignOutError.error
            }
            if let hostedUIError {
                authError = hostedUIError.error
            }
            if let authError {
                let transformedError = SudoUserClientErrorTransformer.transform(authError)
                throw transformedError
            } else {
                throw SudoUserClientError.fatalError(description: "Unexpected error state returned from sign out")
            }
        }
    }

    func checkOperationExclusivity() throws {
        switch currentOperation {
        case .register:
            throw SudoUserClientError.registerOperationAlreadyInProgress
        case .refreshTokens:
            throw SudoUserClientError.refreshTokensOperationAlreadyInProgress
        case .signIn:
            throw SudoUserClientError.signInOperationAlreadyInProgress
        case .none:
            return
        }
    }
}
