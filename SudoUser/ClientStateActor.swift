//
// Copyright © 2022 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager

/// Actor to manage the internal state information of `DefaultSudoUserClient`
actor ClientStateActor {

    // MARK: - Properties

    private let keyManager: SudoKeyManager

    /// Intializes `ClientStateActor`.
    /// - Parameters:
    ///   - keyManager: `SudoKeyManager` instance used to store sensitive data.
    ///   - authUI: `AuthUI` instance used for FSSO.
    init(keyManager: SudoKeyManager) {
        self.keyManager = keyManager
    }

    /// Indicates whether or not this client is registered with Sudo Platform
    /// backend.
    /// - Returns: `true` if the client is registered.
    func isRegistered() async throws -> Bool {
        var username: String?
        username = try getUserName()
        return username != nil
    }
    
    /// Will return the username of the registered user from the keychain, or `nil` if none exists.
    func getUserName() throws -> String? {
        guard
            let data = try keyManager.getPassword(Constants.KeyName.userId),
            let username = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return username
    }

    /// Sets the user name associated with this client. Mainly used for testing.
    /// - Parameter name: user name.
    func setUserName(name: String) async throws {
        guard let data = name.data(using: .utf8) else {
            throw SudoUserClientError.fatalError(description: "Cannot serialize user name.")
        }
        // Delete the user name first so there won't be a conflict when adding the new one.
        try keyManager.deletePassword(Constants.KeyName.userId)
        try keyManager.addPassword(data, name: Constants.KeyName.userId)
    }

    /// Generates and stores registration data.
    ///
    /// - Returns: Public key of the signing key to register with the backend.
    func generateRegistrationData() async throws -> PublicKey {
        // Generate a public/private key pair for this identity.
        let keyId = try keyManager.generateKeyId()
        try keyManager.deleteKeyPair(keyId)
        try keyManager.generateKeyPair(keyId)

        guard let publicKeyData = try keyManager.getPublicKey(keyId) else {
            throw SudoUserClientError.fatalError(description: "Public key not found.")
        }

        // Make sure the key ID that we are trying to add don't exist.
        try keyManager.deletePassword(Constants.KeyName.userKeyId)

        // Store the key ID for user key in the keychain.
        guard let keyIdData = keyId.data(using: .utf8) else {
            throw SudoUserClientError.fatalError(description: "Cannot convert key ID to data.")
        }

        try keyManager.addPassword(keyIdData, name: Constants.KeyName.userKeyId)

        let publicKey = PublicKey(publicKey: publicKeyData, keyId: keyId)
        return publicKey
    }

    /// Removes all keys associated with this client and invalidates any
    /// cached authentication credentials.
    func reset() async throws {
        try keyManager.removeAllKeys()
    }
}
