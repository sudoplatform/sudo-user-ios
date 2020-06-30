//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoLogging
import AWSMobileClient

/// List of possible errors thrown by `AuthUI` implementation.
///
/// - invalidInput: Indicates the input to the API was invalid.
/// - invalidConfig: Indicates the configuration dictionary passed to initialize the client was not valid.
/// - fatalError: Indicates that a fatal error occurred. This could be due to
///     coding error, out-of-memory condition or other conditions that is
///     beyond control of `AuthUI` implementation.
public enum AuthUIError: Error {
    case invalidInput
    case invalidConfig
    case fatalError(description: String)
}

/// Result of federated sign in API. The API can fail with an error or return a set of
/// authentication tokens and ID, access token lifetime in seconds and username.
public enum FederatedSignInResult {
    case success(tokens: AuthenticationTokens, username: String)
    case failure(cause: Error)
}

/// Responsible for managing the authentication flow for browser based federated sign in.
public protocol AuthUI: class {

    /// Presents the sign in UI for federated sign in using an external identity provider.
    ///
    /// - Parameters:
    ///   - navigationController: The navigation controller which would act as the anchor for this UI.
    ///   - completion: The completion handler to invoke to pass the sign in result.
    func presentFederatedSignInUI(navigationController: UINavigationController,
                                  completion: @escaping(FederatedSignInResult) -> Void) throws

    /// Presents the sign out UI for federated sign in using an external identity provider.
    ///
    /// - Parameters:
    ///   - navigationController: The navigation controller which would act as the anchor for this UI.
    ///   - completion: The completion handler to invoke to pass the sign out result.
    func presentFederatedSignOutUI(navigationController: UINavigationController,
                                   completion: @escaping(ApiResult) -> Void) throws

    /// Resets any internal state.
    func reset()

}

/// AuthUI implemented that uses Cognito Auth UI.
public class CognitoAuthUI: AuthUI {

    /// Configuration parameter names.
    public struct Config {

        struct FederatedSignIn {
            // ID of the app client configured for federated sign in in Cognito user pool.
            static let appClientId = "appClientId"
            // Web domain configured for the hosted UI in Cognito user pool.
            static let webDomain = "webDomain"
            // URL to redirect to after sign in.
            static let signInRedirectUri = "signInRedirectUri"
            // URL to redirect to after sign ou.
            static let signOutRedirectUri = "signOutRedirectUri"
        }

    }

    private struct Constants {

        struct Auth {
            static let cognitoAuthKey = "com.sudoplatform.id.cognito.auth"
        }

    }

    /// Default logger for SudoUserClient.
    private let logger: Logger

    /// Cognito Hosted UI authentication.
    private var cognitoAuth: AWSCognitoAuth

    /// Intializes a new `CognitoAuthUI` instance.
    ///
    /// - Parameters:
    ///   - config: Configuration parameters.
    ///   - logger: A logger to use for logging messages. If none provided then use a default logger.
    ///
    /// - Returns: A new initialized `CognitoAuthUI` instance.
    public init(config: [String: Any], logger: Logger? = nil) throws {
        guard let appClientId = config[Config.FederatedSignIn.appClientId] as? String,
            let webDomain = config[Config.FederatedSignIn.webDomain] as? String,
            let signInRedirectUri = config[Config.FederatedSignIn.signInRedirectUri] as? String,
            let signOutRedirectUri = config[Config.FederatedSignIn.signOutRedirectUri] as? String else {
                throw SudoUserClientError.invalidConfig
        }

        let logger = logger ?? Logger.sudoUserLogger
        self.logger = logger

        let cognitoAuthConfig = AWSCognitoAuthConfiguration.init(appClientId: appClientId,
                                                                 appClientSecret: nil,
                                                                 scopes: ["openid", "aws.cognito.signin.user.admin"],
                                                                 signInRedirectUri: signInRedirectUri,
                                                                 signOutRedirectUri: signOutRedirectUri,
                                                                 webDomain: "https://\(webDomain)")
        AWSCognitoAuth.registerCognitoAuth(with: cognitoAuthConfig, forKey: Constants.Auth.cognitoAuthKey)

        self.cognitoAuth = AWSCognitoAuth(forKey: Constants.Auth.cognitoAuthKey)
    }

    public func presentFederatedSignInUI(navigationController: UINavigationController,
                                         completion: @escaping(FederatedSignInResult) -> Void) throws {
        guard let viewController = navigationController.viewControllers.first else {
            self.logger.error("Input navigation controller does not have any view controllers.")
            throw AuthUIError.invalidInput
        }

        self.cognitoAuth.getSession(viewController) { (session, error) in
            if let error = error {
                return completion(.failure(cause: error))
            }

            guard let session = session,
                let username = session.username,
                let idToken = session.idToken?.tokenString,
                let accessToken = session.accessToken?.tokenString,
                let refreshToken = session.refreshToken?.tokenString,
                let expirationTime = session.expirationTime else {
                    return completion(.failure(cause: SudoUserClientError.fatalError(description: "Required tokens not found.")))
            }

            let lifetime = Int(expirationTime.timeIntervalSince1970 - Date().timeIntervalSince1970)

            completion(.success(tokens: AuthenticationTokens(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken, lifetime: lifetime), username: username))
        }
    }

    public func presentFederatedSignOutUI(navigationController: UINavigationController,
                                          completion: @escaping(ApiResult) -> Void) throws {
        guard let viewController = navigationController.viewControllers.first else {
            self.logger.error("Input navigation controller does not have any view controllers.")
            throw AuthUIError.invalidInput
        }

        self.cognitoAuth.signOut(viewController) { (error) in
            if let error = error {
                completion(.failure(cause: error))
            } else {
                completion(.success)
            }
        }
    }

    public func reset() {
        self.cognitoAuth.signOutLocallyAndClearLastKnownUser()
    }

}
