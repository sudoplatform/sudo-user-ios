//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoLogging
import SudoKeyManager
import AWSCognitoIdentityProvider

/// Identity provider that uses Cognito user pool.
public class CognitoUserPoolIdentityProvider: IdentityProvider {

    /// Configuration parameter names.
    public struct Config {
        // AWS region hosting the identity service.
        static let region = "region"
        // AWS Cognito user pool ID of the identity service.
        static let poolId = "poolId"
        // ID of the client configured to access the user pool.
        static let clientId = "clientId"
    }

    private struct Constants {

        static let identityServiceName = "com.sudoplatform.identityservice"

        struct PasswordCharSet {
            static let allChars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?;,&%$@#^*~")
            static let upperCaseChars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            static let lowerCaseChars = Array("abcdefghijklmnopqrstuvwxyz")
            static let numberChars = Array("0123456789")
            static let specialChars = Array(".!?;,&%$@#^*~")
        }

        struct CognitoChallengeParameter {
            static let audience = "audience"
            static let nonce = "nonce"
        }

        struct CognitoAuthenticationParameter {
            static let userName = "USERNAME"
            static let answer = "ANSWER"
            static let refreshToken = "REFRESH_TOKEN"
        }

        struct ServiceError {
            static let message = "message"
            static let decodingError = "sudoplatform.DecodingError"
            static let validationFailedError = "sudoplatform.identity.UserValidationFailed"
            static let missingRequiredInputError = "sudoplatform.identity.MissingRequiredInputs"
            static let deviceCheckAlreadyRegisteredError = "sudoplatform.identity.DeviceCheckAlreadyRegistered"
            static let testRegCheckFailedError = "sudoplatform.identity.TestRegCheckFailed"
            static let challengeTypeNotSupportedError = "sudoplatform.identity.ChallengeTypeNotSupported"
            static let serviceError = "sudoplatform.ServiceError"
        }

    }

    struct RegistrationParameter {
        static let challengeType = "challengeType"
        static let answer = "answer"
        static let answerMetadata = "answerMetadata"
        static let buildType = "buildType"
        static let deviceId = "deviceId"
        static let publicKey = "publicKey"
        static let registrationId = "registrationId"
    }

    struct AuthenticationParameter {
        static let keyId = "keyId"
        static let tokenLifetime = "tokenLifetime"
    }

    private var userPool: AWSCognitoIdentityUserPool

    private var serviceConfig: AWSServiceConfiguration

    private var keyManager: SudoKeyManager

    private unowned var logger: Logger

    /// Initializes and returns a `CognitoUserPoolIdentityProvider` object.
    ///
    /// - Parameters:
    ///   - config: Configuration parameters for this identity provider.
    ///   - keyManager: `KeyManager` instance required for signing authentication token.
    ///   - logger: Logger used for logging.
    init(config: [String: Any],
         keyManager: SudoKeyManager,
         logger: Logger = Logger.sudoUserLogger) throws {
        self.logger = logger
        self.keyManager = keyManager

        self.logger.debug("Initializing with config: \(config)")

        // Validate the config.
        guard let region = config[Config.region] as? String,
            let poolId = config[Config.poolId] as? String,
            let clientId = config[Config.clientId] as? String else {
                throw IdentityProviderError.invalidConfig
        }

        guard let regionType = AWSEndpoint.regionTypeFrom(name: region) else {
            throw IdentityProviderError.invalidConfig
        }

        // Initialize the user pool instance.
        guard let serviceConfig = AWSServiceConfiguration(region: regionType, credentialsProvider: nil) else {
            throw IdentityProviderError.fatalError(description: "Failed to initialize AWS service configuration.")
        }

        self.serviceConfig = serviceConfig

        AWSCognitoIdentityProvider.register(with: self.serviceConfig, forKey: Constants.identityServiceName)

        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: clientId, clientSecret: nil, poolId: poolId)
        AWSCognitoIdentityUserPool.register(with: serviceConfig, userPoolConfiguration: poolConfiguration, forKey: Constants.identityServiceName)
        self.userPool = AWSCognitoIdentityUserPool(forKey: Constants.identityServiceName)
    }

    public func register(uid: String, parameters: [String: String], completion: @escaping (RegisterResult) -> Void) throws {
        let validationData: [AWSCognitoIdentityUserAttributeType] = parameters.map { AWSCognitoIdentityUserAttributeType(name: $0.key, value: $0.value) }

        // Generate a random password that complies with default Cognito user pool password policy. This password is actually not used since
        // we use a custom authentication using a signing key but is required to create a user.
        let password = self.generatePassword(length: 50, upperCase: true, lowerCase: true, special: true, number: true)

        self.logger.debug("Performing sign-up with uid: \(uid), validationData: \(validationData)")

        self.userPool.signUp(uid, password: password, userAttributes: nil, validationData: validationData).continueWith {(task) -> Any? in
            if let error = task.error as NSError? {
                if let message = error.userInfo[Constants.ServiceError.message] as? String {
                    if message.contains(Constants.ServiceError.decodingError) {
                        completion(.failure(cause: IdentityProviderError.invalidInput))
                    } else if message.contains(Constants.ServiceError.missingRequiredInputError) {
                        completion(.failure(cause: IdentityProviderError.invalidInput))
                    } else if message.contains(Constants.ServiceError.validationFailedError) {
                        completion(.failure(cause: IdentityProviderError.notAuthorized))
                    } else if message.contains(Constants.ServiceError.deviceCheckAlreadyRegisteredError) {
                        completion(.failure(cause: IdentityProviderError.notAuthorized))
                    } else if message.contains(Constants.ServiceError.testRegCheckFailedError) {
                        completion(.failure(cause: IdentityProviderError.notAuthorized))
                    } else if message.contains(Constants.ServiceError.challengeTypeNotSupportedError) {
                        completion(.failure(cause: IdentityProviderError.notAuthorized))
                    } else if message.contains(Constants.ServiceError.serviceError) {
                        completion(.failure(cause: IdentityProviderError.serviceError))
                    } else {
                        completion(.failure(cause: error))
                    }
                } else {
                    completion(.failure(cause: error))
                }
            } else if let result = task.result, let userConfirmed = result.userConfirmed {
                if userConfirmed.boolValue {
                    completion(.success(uid: uid))
                } else {
                    completion(.failure(cause: IdentityProviderError.identityNotConfirmed))
                }
            } else {
                completion(RegisterResult.failure(cause: IdentityProviderError.fatalError(description: "signUp result did not contain user confirmation status.")))
            }

            return nil
        }
    }

    public func deregister(uid: String, accessToken: String, completion: @escaping (DeregisterResult) -> Void) throws {
        let provider = AWSCognitoIdentityProvider(forKey: Constants.identityServiceName)
        guard let deleteUserRequest = AWSCognitoIdentityProviderDeleteUserRequest() else {
            throw IdentityProviderError.fatalError(description: "Failed to create a delete user request.")
        }

        deleteUserRequest.accessToken = accessToken
        provider.deleteUser(deleteUserRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                completion(.failure(cause: error))
                return nil
            }

            completion(.success(uid: uid))
            return nil
        }
    }

    public func signIn(uid: String, parameters: [String: Any], completion: @escaping (SignInResult) -> Void) throws {
        guard let keyId = parameters[AuthenticationParameter.keyId] as? String else {
            throw IdentityProviderError.fatalError(description: "Key ID not provided.")
        }

        // Default token lifetime of private key signed token is 5 minutes unless specified otherwise.
        let tokenLifetime = parameters[AuthenticationParameter.tokenLifetime] as? Int ?? 300

        guard let request = AWSCognitoIdentityProviderInitiateAuthRequest() else {
            throw IdentityProviderError.fatalError(description: "Failed to create Cognito authentication request.")
        }

        // Set up the request to use custom authentication.
        request.authFlow = .customAuth
        request.clientId = self.userPool.userPoolConfiguration.clientId
        request.authParameters = [Constants.CognitoAuthenticationParameter.userName: uid]

        self.logger.debug("Initiating auth with request: \(request)")
        let provider = AWSCognitoIdentityProvider(forKey: Constants.identityServiceName)
        provider.initiateAuth(request).continueWith { response in
            if let error = response.error as NSError? {
                if let message = error.userInfo[Constants.ServiceError.message] as? String {
                    if message.contains(Constants.ServiceError.decodingError) {
                        completion(SignInResult.failure(cause: IdentityProviderError.invalidInput))
                    } else if message.contains(Constants.ServiceError.missingRequiredInputError) {
                        completion(SignInResult.failure(cause: IdentityProviderError.invalidInput))
                    } else if message.contains(Constants.ServiceError.validationFailedError) {
                        completion(SignInResult.failure(cause: IdentityProviderError.notAuthorized))
                    } else if message.contains(Constants.ServiceError.serviceError) {
                        completion(SignInResult.failure(cause: IdentityProviderError.serviceError))
                    } else {
                        completion(SignInResult.failure(cause: error))
                    }
                } else {
                    completion(SignInResult.failure(cause: error))
                }
                return nil
            }

            guard let challengeName = response.result?.challengeName else {
                completion(SignInResult.failure(cause: IdentityProviderError.fatalError(description: "Challenge name missing from initiateAuth result.")))
                return nil
            }

            guard let session = response.result?.session else {
                completion(SignInResult.failure(cause: IdentityProviderError.fatalError(description: "Session missing from initiateAuth result.")))
                return nil
            }

            guard let audience = response.result?.challengeParameters?[Constants.CognitoChallengeParameter.audience] else {
                completion(SignInResult.failure(cause: IdentityProviderError.fatalError(description: "Audience challenge parameter missing from initiateAuth result.")))
                return nil
            }

            guard let nonce = response.result?.challengeParameters?[Constants.CognitoChallengeParameter.nonce] else {
                completion(SignInResult.failure(cause: IdentityProviderError.fatalError(description: "Audience challenge parameter missing from initiateAuth result.")))
                return nil
            }

            guard let respondToAuthChallengeRequest = AWSCognitoIdentityProviderRespondToAuthChallengeRequest() else {
                completion(SignInResult.failure(cause: IdentityProviderError.fatalError(description: "Failed to create Cognito challenge response request.")))
                return nil
            }

            respondToAuthChallengeRequest.clientId = self.userPool.userPoolConfiguration.clientId
            respondToAuthChallengeRequest.challengeName = challengeName
            respondToAuthChallengeRequest.session = session

            // Challenge requires the private key signed JWT as the answer.
            let jwt = JWT(issuer: uid, audience: audience, subject: uid, id: nonce)
            jwt.expiry = Date(timeIntervalSinceNow: Double(tokenLifetime))

            let encodedJWT: String
            do {
                encodedJWT = try jwt.signAndEncode(keyManager: self.keyManager, keyId: keyId)
            } catch let error {
                completion(SignInResult.failure(cause: error))
                return nil
            }

            respondToAuthChallengeRequest.challengeResponses = [Constants.CognitoAuthenticationParameter.userName: uid, Constants.CognitoAuthenticationParameter.answer: encodedJWT]

            // Respond to challenge.
            self.logger.debug("Responding to auth challenge with request: \(respondToAuthChallengeRequest)")
            provider.respond(toAuthChallenge: respondToAuthChallengeRequest, completionHandler: { (response, error) in
                if let error = error {
                    guard let errorType = AWSCognitoIdentityProviderErrorType(rawValue: error._code) else {
                        return completion(.failure(cause: error))
                    }

                    switch errorType {
                    case AWSCognitoIdentityProviderErrorType.notAuthorized:
                        return completion(SignInResult.failure(cause: IdentityProviderError.notAuthorized))
                    default:
                        return completion(.failure(cause: error))
                    }
                } else {
                    guard let idToken = response?.authenticationResult?.idToken,
                        let accessToken = response?.authenticationResult?.accessToken,
                        let refreshToken = response?.authenticationResult?.refreshToken,
                        let lifetime = response?.authenticationResult?.expiresIn?.intValue else {
                            return completion(.failure(cause: IdentityProviderError.authTokenMissing))
                    }

                    completion(.success(tokens: AuthenticationTokens(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken, lifetime: lifetime)))
                }
            })

            return nil
        }
    }

    /// Generate a random password with specified password policy.
    ///
    /// - Parameters:
    ///   - length: Password length.
    ///   - upperCase: Requires 1 uppercase character.
    ///   - lowerCase: Requires 1 lowercase character.
    ///   - special: Requires 1 special character.
    ///   - number: Requires 1 numeric character.
    ///
    /// - Returns: Generated password.
    func generatePassword(length: UInt, upperCase: Bool, lowerCase: Bool, special: Bool, number: Bool) -> String {

        var password: [Character] = []

        if upperCase {
            let index = Int(arc4random()) % (Constants.PasswordCharSet.upperCaseChars.count - 1)
            password.append(Constants.PasswordCharSet.upperCaseChars[index])
        }

        if lowerCase {
            let index = Int(arc4random()) % (Constants.PasswordCharSet.lowerCaseChars.count - 1)
            password.append(Constants.PasswordCharSet.lowerCaseChars[index])
        }

        if special {
            let index = Int(arc4random()) % (Constants.PasswordCharSet.specialChars.count - 1)
            password.append(Constants.PasswordCharSet.specialChars[index])
        }

        if number {
            let index = Int(arc4random()) % (Constants.PasswordCharSet.numberChars.count - 1)
            password.append(Constants.PasswordCharSet.numberChars[index])
        }

        while password.count < length {
            let index = Int(arc4random()) % (Constants.PasswordCharSet.allChars.count - 1)
            password.append(Constants.PasswordCharSet.allChars[index])
        }

        return String(password.shuffled())
    }

    public func refreshTokens(refreshToken: String, completion: @escaping (SignInResult) -> Void) throws {
        guard let request = AWSCognitoIdentityProviderInitiateAuthRequest() else {
            throw SudoUserClientError.fatalError(description: "Failed to create Cognito authentication request.")
        }

        // Set up the request to use refresh token to authenticate.
        request.authFlow = .refreshTokenAuth
        request.clientId = self.userPool.userPoolConfiguration.clientId
        request.authParameters = [Constants.CognitoAuthenticationParameter.refreshToken: refreshToken]

        let provider = AWSCognitoIdentityProvider(forKey: Constants.identityServiceName)
        provider.initiateAuth(request).continueWith { response in
            if let error = response.error {
                guard let errorType = AWSCognitoIdentityProviderErrorType(rawValue: error._code) else {
                    return completion(.failure(cause: error))
                }

                switch errorType {
                case AWSCognitoIdentityProviderErrorType.notAuthorized:
                    completion(.failure(cause: IdentityProviderError.notAuthorized))
                default:
                    completion(.failure(cause: error))
                }

                return nil
            }

            guard let idToken = response.result?.authenticationResult?.idToken,
                let accessToken = response.result?.authenticationResult?.accessToken,
                let lifetime = response.result?.authenticationResult?.expiresIn?.intValue else {
                    completion(.failure(cause: SudoUserClientError.authTokenMissing))
                    return nil
            }

            completion(.success(tokens: AuthenticationTokens(idToken: idToken, accessToken: accessToken, refreshToken: refreshToken, lifetime: lifetime)))
            return nil
        }
    }

    public func globalSignOut(accessToken: String, completion: @escaping(ApiResult) -> Void) throws {
        guard let request = AWSCognitoIdentityProviderGlobalSignOutRequest() else {
            throw SudoUserClientError.fatalError(description: "Failed to create Cognito global sign ou request.")
        }

        request.accessToken = accessToken

        let provider = AWSCognitoIdentityProvider(forKey: Constants.identityServiceName)
        provider.globalSignOut(request).continueWith { response in
            if let error = response.error {
                guard let errorType = AWSCognitoIdentityProviderErrorType(rawValue: error._code) else {
                    return completion(.failure(cause: error))
                }

                switch errorType {
                case AWSCognitoIdentityProviderErrorType.notAuthorized:
                    completion(.failure(cause: IdentityProviderError.notAuthorized))
                default:
                    completion(.failure(cause: error))
                }

                return nil
            }

            completion(.success)
            return nil
        }
    }

}
