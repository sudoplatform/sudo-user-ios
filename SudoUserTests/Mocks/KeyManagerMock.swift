//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager

class MockKeyManager: SudoKeyManager {
    var namespace: String = ""
    var encrypted: Data = Data()
    var decrypted: Data = Data()
    var keyId: String = ""
    var signature: Data = Data()
    var verified: Bool = true
    var key: Data = Data()

    var passwords: [String: Data] = [:]
    var privateKeys: [String: Data] = [:]
    var publicKeys: [String: Data] = [:]
    var symmetricKeys: [String: Data] = [:]

    func addPassword(_ password: Data, name: String) throws {
        self.passwords[name] = password
    }

    func addPassword(_ password: Data, name: String, isSynchronizable: Bool, isExportable: Bool) throws {
        self.passwords[name] = password
    }

    func getPassword(_ name: String) throws -> Data? {
        return self.passwords[name]
    }

    func deletePassword(_ name: String) throws {
        self.passwords.removeValue(forKey: name)
    }

    func updatePassword(_ password: Data, name: String) throws {
        self.passwords[name] = password
    }

    func getKeyAttributes(_ name: String, type: KeyType) throws -> KeyAttributeSet? {
        return nil
    }

    func updateKeyAttributes(_ attributes: KeyAttributeSet, name: String, type: KeyType) throws {
    }

    func generateSymmetricKey(_ name: String) throws {
    }

    func generateSymmetricKey(_ name: String, isExportable: Bool) throws {
    }

    func addSymmetricKey(_ key: Data, name: String) throws {
        self.symmetricKeys[name] = key
    }

    func addSymmetricKey(_ key: Data, name: String, isExportable: Bool) throws {
        self.symmetricKeys[name] = key
    }

    func getSymmetricKey(_ name: String) throws -> Data? {
        return self.symmetricKeys[name]
    }

    func deleteSymmetricKey(_ name: String) throws {
        self.symmetricKeys.removeValue(forKey: name)
    }

    func encryptWithSymmetricKey(_ name: String, data: Data) throws -> Data {
        return self.encrypted
    }

    func encryptWithSymmetricKey(_ name: String, data: Data, iv: Data) throws -> Data {
        return self.encrypted
    }

    func encryptWithSymmetricKey(_ key: Data, data: Data) throws -> Data {
        return self.encrypted
    }

    func encryptWithSymmetricKey(_ key: Data, data: Data, iv: Data) throws -> Data {
        return self.encrypted
    }

    func decryptWithSymmetricKey(_ name: String, data: Data) throws -> Data {
        return self.encrypted
    }

    func decryptWithSymmetricKey(_ name: String, data: Data, iv: Data) throws -> Data {
        return self.decrypted
    }

    func decryptWithSymmetricKey(_ key: Data, data: Data) throws -> Data {
        return self.decrypted
    }

    func decryptWithSymmetricKey(_ key: Data, data: Data, iv: Data) throws -> Data {
        return self.decrypted
    }

    func createSymmetricKeyFromPassword(_ password: String) throws -> (key: Data, salt: Data, rounds: UInt32) {
        return (Data(), Data(), 1)
    }

    func createSymmetricKeyFromPassword(_ password: String, salt: Data, rounds: UInt32) throws -> Data {
        return Data()
    }

    func createSymmetricKeyFromPassword(_ password: Data, salt: Data, rounds: UInt32) throws -> Data {
        return Data()
    }

    func generateHash(_ data: Data) throws -> Data {
        return Data()
    }

    func generateKeyPair(_ name: String) throws {
        self.privateKeys[name] = self.key
        self.publicKeys[name] = self.key
    }

    func generateKeyPair(_ name: String, isExportable: Bool) throws {
        self.privateKeys[name] = self.key
        self.publicKeys[name] = self.key
    }

    func generateKeyId() throws -> String {
        return self.keyId
    }

    func addPrivateKey(_ key: Data, name: String) throws {
        self.privateKeys[name] = key
    }

    func addPrivateKey(_ key: Data, name: String, isExportable: Bool) throws {
        self.privateKeys[name] = key
    }

    func getPrivateKey(_ name: String) throws -> Data? {
        return self.privateKeys[name]
    }

    func addPublicKey(_ key: Data, name: String) throws {
        self.publicKeys[name] = key
    }

    func addPublicKey(_ key: Data, name: String, isExportable: Bool) throws {
        self.publicKeys[name] = key
    }

    func getPublicKey(_ name: String) throws -> Data? {
        return self.publicKeys[name]
    }

    func deleteKeyPair(_ name: String) throws {
        self.privateKeys.removeValue(forKey: name)
        self.publicKeys.removeValue(forKey: name)
    }

    func generateSignatureWithPrivateKey(_ name: String, data: Data) throws -> Data {
        return self.signature
    }

    func verifySignatureWithPublicKey(_ name: String, data: Data, signature: Data) throws -> Bool {
        return self.verified
    }

    func createRandomData(_ size: Int) throws -> Data {
        return Data()
    }

    func removeAllKeys() throws {
        self.symmetricKeys.removeAll()
        self.privateKeys.removeAll()
        self.publicKeys.removeAll()
        self.passwords.removeAll()
    }

    func exportKeys() throws -> [[KeyAttributeName: AnyObject]] {
        return []
    }

    func importKeys(_ keys: [[KeyAttributeName: AnyObject]]) throws {
    }

    func getKeyId(_ name: String, type: KeyType) throws -> String {
        return self.keyId
    }

    func getAttributesForKeys(_ searchAttributes: KeyAttributeSet) throws -> [KeyAttributeSet] {
        return []
    }

    func createIV() throws -> Data {
        return Data()
    }

    func decryptWithPrivateKey(_ name: String, data: Data, algorithm: PublicKeyEncryptionAlgorithm) throws -> Data {
        return self.decrypted
    }

    func encryptWithPublicKey(_ name: String, data: Data, algorithm: PublicKeyEncryptionAlgorithm) throws -> Data {
        return self.encrypted
    }

    func encryptWithPublicKey(_ key: Data, data: Data, algorithm: PublicKeyEncryptionAlgorithm) throws -> Data {
        return self.encrypted
    }

    func deletePrivateKey(_ name: String) throws {
        self.privateKeys.removeValue(forKey: name)
    }

    func addPublicKeyFromPEM(_ key: String, name: String) throws {
        self.publicKeys[name] = Data(("PEM" + key).utf8)
    }

    func addPublicKeyFromPEM(_ key: String, name: String, isExportable: Bool) throws {
        self.publicKeys[name] = Data(("PEM" + key).utf8)
    }

    func getPublicKeyAsPEM(_ name: String) throws -> String? {
        guard let foundKey = self.publicKeys[name] else {
            return nil
        }
        let str = String(decoding: foundKey, as: UTF8.self)
        return String(str.dropFirst(3))
    }

    func deletePublicKey(_ name: String) throws {
        self.publicKeys .removeValue(forKey: name)
    }

}
