//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import Foundation

protocol SudoUserClientErrorTransformer {
    func transform(_ error: Error) -> SudoUserClientError
}

/// Utility for transforming different error types to a `SudoUserClientError`.
class DefaultSudoUserClientErrorTransformer: SudoUserClientErrorTransformer {

    // MARK: - Supplementary

    enum ServiceError {
        static let message = "message"
        static let decodingError = "sudoplatform.DecodingError"
        static let validationFailedError = "sudoplatform.identity.UserValidationFailed"
        static let missingRequiredInputError = "sudoplatform.identity.MissingRequiredInputs"
        static let deviceCheckAlreadyRegisteredError = "sudoplatform.identity.DeviceCheckAlreadyRegistered"
        static let testRegCheckFailedError = "sudoplatform.identity.TestRegCheckFailed"
        static let challengeTypeNotSupportedError = "sudoplatform.identity.ChallengeTypeNotSupported"
        static let alreadyRegisteredError = "sudoplatform.identity.AlreadyRegistered"
        static let tokenValidationError = "sudoplatform.identity.TokenValidationError"
        static let serviceError = "sudoplatform.ServiceError"
    }

    // MARK: - Methods

    /// Will transform the provided error into the appropriate `SudoUserClientError`.
    /// - Parameter error: An error thrown while making a request to the identity service.
    /// - Returns: A `SudoUserClientError`.
    func transform(_ error: Error) -> SudoUserClientError {
        if let clientError = error as? SudoUserClientError {
            return clientError
        }
        guard let authError = error as? AuthError else {
            return SudoUserClientError.fatalError(description: error.localizedDescription)
        }
        switch authError {
        case .configuration:
            return .invalidConfig

        case .validation:
            return .invalidInput

        case .notAuthorized:
            return .notAuthorized

        case .signedOut, .sessionExpired:
            return .notSignedIn

        case .service:
            return transformCognitoAuthError(authError)

        case .unknown:
            return .fatalError(description: "Unknown error: \(error.localizedDescription)")

        case .invalidState(let description, _, _):
            return .fatalError(description: "Invalid internal state: \(description)")
        }
    }

    // MARK: - Helpers

    private func transformCognitoAuthError(_ authError: AuthError) -> SudoUserClientError {
        if let cognitoAuthError = authError.underlyingError as? AWSCognitoAuthError {
            switch cognitoAuthError {
            case .userNotFound:
                return SudoUserClientError.notRegistered

            case .userNotConfirmed:
                return SudoUserClientError.identityNotConfirmed

            case .invalidParameter, .invalidPassword:
                return SudoUserClientError.invalidInput

            case .userCancelled:
                return SudoUserClientError.signInCanceled

            case .webAuthnConfigurationMissing:
                return SudoUserClientError.invalidConfig

            case .lambda:
                if let clientError = transformLambdaError(authError: authError) {
                    return clientError
                }
            default:
                break
            }
        }
        // NEW: Map external SSO temporary auth session expiry indicating existing external SSO session.
        if authError.errorDescription.contains("temporarily_unavailable"),
           authError.errorDescription.contains("authentication_expired"),
           authError.recoverySuggestion == "Received an error message from the service" {
            return .externalSSOSessionExists
        }
        return .requestError(cause: authError)
    }

    private func transformLambdaError(authError: AuthError) -> SudoUserClientError? {
        let message = authError.errorDescription
        if message.contains(ServiceError.decodingError) {
            return SudoUserClientError.invalidInput

        } else if message.contains(ServiceError.missingRequiredInputError) {
            return SudoUserClientError.invalidInput

        } else if message.contains(ServiceError.validationFailedError) {
            return SudoUserClientError.notAuthorized

        } else if message.contains(ServiceError.deviceCheckAlreadyRegisteredError) {
            return SudoUserClientError.notAuthorized

        } else if message.contains(ServiceError.testRegCheckFailedError) {
            return SudoUserClientError.notAuthorized

        } else if message.contains(ServiceError.tokenValidationError) {
            return SudoUserClientError.notAuthorized

        } else if message.contains(ServiceError.challengeTypeNotSupportedError) {
            return SudoUserClientError.notAuthorized

        } else if message.contains(ServiceError.alreadyRegisteredError) {
            return SudoUserClientError.alreadyRegistered

        } else if message.contains(ServiceError.serviceError) {
            return SudoUserClientError.serviceError

        } else {
            return nil
        }
    }
}
