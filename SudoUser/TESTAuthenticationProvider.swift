//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager

/// List of possible errors thrown by `TESTAuthenticationProvider`.
///
/// - invalidKey: Invalid signing key was provided.
public enum TESTAuthenticationProviderError: Error, Hashable {
    case invalidKey
}

/// Authentication info consisting of a JWT signed using the TEST registration key.
public class TESTAuthenticationInfo: AuthenticationInfo {

    private let jwt: String

    /// Initializes `TESTAuthenticationInfo` with a signed JWT.
    ///
    /// - Parameter jwt: signed JWT.
    public init(jwt: String) {
        self.jwt = jwt
    }

    public static var type: String = "TEST"

    public func isValid() -> Bool {
        return true
    }

    public func toString() -> String {
        return self.jwt
    }

}

/// Authentication provider for generating authentication info using a TEST registration key.
public class TESTAuthenticationProvider: AuthenticationProvider {

    public struct Constants {
        public static let testRegistrationKeyId = "register_key"
        public static let testRegistrationIssuer = "testRegisterIssuer"
        public static let testRegistrationAudience = "testRegisterAudience"
    }

    private let name: String

    private let keyId: String

    private let keyManager: SudoKeyManager

    /// Initializes a TEST authentication provider with a TEST key.
    ///
    /// - Parameters:
    ///   - name: Provider name. This name will be prepend to the generated UUID in JWT sub.
    ///   - key: PEM encoded RSA private key.
    ///   - keyMananger: `KeyManager` instance to use for signing authentication info.
    public init(name: String, key: String, keyId: String = Constants.testRegistrationKeyId, keyMananger: SudoKeyManager) throws {
        self.name = name
        self.keyId = keyId
        self.keyManager = keyMananger

        var key = key
        key = key.replacingOccurrences(of: "\n", with: "")
        key = key.replacingOccurrences(of: "-----BEGIN RSA PRIVATE KEY-----", with: "")
        key = key.replacingOccurrences(of: "-----END RSA PRIVATE KEY-----", with: "")

        guard let keyData = Data(base64Encoded: key) else {
            throw TESTAuthenticationProviderError.invalidKey
        }

        try self.keyManager.deleteKeyPair(self.keyId)
        try self.keyManager.addPrivateKey(keyData, name: self.keyId)
    }

    public func getAuthenticationInfo() throws -> AuthenticationInfo {
        let jwt = JWT(issuer: Constants.testRegistrationIssuer,
                      audience: Constants.testRegistrationAudience,
                      subject: "\(self.name)-\(UUID().uuidString)",
            id: UUID().uuidString)
        let encoded = try jwt.signAndEncode(keyManager: self.keyManager, keyId: self.keyId)
        return TESTAuthenticationInfo(jwt: encoded)
    }

    public func reset() {
        try? self.keyManager.deleteKeyPair(self.keyId)
    }

}
