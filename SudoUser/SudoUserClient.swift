//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit

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

    /// Returns the user name associated with this client. The username maybe needed to contact
    /// the support team when diagnosing an issue related to a specific user.
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

    /// Returns the list of supported registration challenge types supported by the configured backend.
    ///
    /// - Returns: List of supported registration challenge types.
    func getSupportedRegistrationChallengeType() -> [ChallengeType]

}
