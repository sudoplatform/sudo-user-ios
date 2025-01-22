//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import SudoKeyManager
import AWSCognitoIdentityProvider
import AWSAppSync
import AuthenticationServices
import SudoLogging
@testable import SudoUser

class MySignInStatusObserver: SignInStatusObserver {

    let signingInExpectation: XCTestExpectation = XCTestExpectation()
    let signedInExpectation: XCTestExpectation = XCTestExpectation()

    func signInStatusChanged(status: SignInStatus) {
        switch  status {
        case .signedIn:
            self.signedInExpectation.fulfill()
        case .signingIn:
            self.signingInExpectation.fulfill()
        default:
            break
        }
    }

}

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

class MockCredentialsProvider: CredentialsProvider {

    var identityId: String? = "dummy_id"

    func getIdentityId() async throws -> String {
        return "dummy_id"
    }

    func getCachedIdentityId() -> String? {
        return identityId
    }

    func reset() {
    }

    func clearCredentials() {
    }

}

class MyCancellable: Cancellable {

    func cancel() {}

}

class MyNetworkTransport: AWSNetworkTransport {

    var data = Data()
    var jsonObject: JSONObject?
    var error: Error?
    var responseBody: [JSONObject] = []
    var variables: [GraphQLMap] = []

    func send(data: Data, completionHandler: ((JSONObject?, Error?) -> Void)?) {
        self.data = data
        completionHandler?(self.jsonObject, self.error)
    }

    func sendSubscriptionRequest<Operation>(operation: Operation, completionHandler: @escaping (JSONObject?, Error?) -> Void) throws -> Cancellable where Operation: GraphQLOperation {
        completionHandler(self.jsonObject, self.error)
        return MyCancellable()
    }

    func send<Operation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable where Operation: GraphQLOperation {
        if let variables = operation.variables {
            self.variables.append(variables)
        }

        let response = GraphQLResponse(operation: operation, body: self.responseBody.removeFirst())
        completionHandler(response, self.error)

        return MyCancellable()
    }

}

class MockIdentityProvider: IdentityProvider {

    var registrationParameters: [String: Any] = [:]

    var signInParameters: [String: Any] = [:]

    var refreshToken: String = ""

    var registerResult: String = ""

    var deregisterResult: String = ""

    var signInResult: AuthenticationTokens = AuthenticationTokens(idToken: "", accessToken: "", refreshToken: "", lifetime: 0, username: "")

    var refreshTokensResult: AuthenticationTokens = AuthenticationTokens(idToken: "", accessToken: "", refreshToken: "", lifetime: 0, username: "")

    var signOutCalled: Bool = false

    var globalSignOutCalled: Bool = false

    var uid = ""

    var error: Error?

    var accessToken: String?

    func register(uid: String, parameters: [String: String]) async throws -> String {
        self.uid = uid
        self.registrationParameters = parameters
        return self.registerResult
    }

    func deregister(uid: String, accessToken: String) async throws -> String {
        self.uid = uid
        self.accessToken = accessToken
        return self.deregisterResult
    }

    func signIn(uid: String, parameters: [String: Any]) async throws -> AuthenticationTokens {
        self.uid = uid
        self.signInParameters = parameters
        return self.signInResult
    }

    func refreshTokens(refreshToken: String) async throws -> AuthenticationTokens {
        self.refreshToken = refreshToken
        return self.refreshTokensResult
    }

    func signOut(refreshToken: String) async throws {
        self.refreshToken = refreshToken
        self.globalSignOutCalled = true
    }

    func globalSignOut(accessToken: String) async throws {
        self.globalSignOutCalled = true
    }

}

class MockAuthUI: AuthUI {

    var federatedSignInResult: AuthenticationTokens = AuthenticationTokens(idToken: "", accessToken: "", refreshToken: "", lifetime: 0, username: "")

    var resetCalled = false

    var url: URL?

    func presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor) async throws -> AuthenticationTokens {
        return federatedSignInResult
    }

    func presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor) async throws {
    }

    func reset() {
        self.resetCalled = true
    }

    func processFederatedSignInTokens(url: URL) -> Bool {
        self.url = url
        return true
    }

}

class SudoUserClientTests: XCTestCase {

    var client: SudoUserClient!

    var keyManager: SudoKeyManager!

    var identityProvider: MockIdentityProvider!

    var credentialsProvider: MockCredentialsProvider!

    var authUI: MockAuthUI!

    var transport: MyNetworkTransport!

    let config = ["identityService": [ "region": "us-east-1",
                                       "poolId": "us-east-1_mhy3BrqZd",
                                       "poolName": "IdentityUserPool",
                                       "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                       "refreshTokenLifetime": 10,
                                       "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                       "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                       "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4",
                                       "registrationMethods": ["TEST", "DEVICE_CHECK", "SAFETY_NET"]],
                  "sudoService": [ "region": "us-west-2",
                                        "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                        "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                  "federatedSignIn": [ "appClientId": "2hrq71fef6fu4bcgnme4qp9qqg",
                                       "signInRedirectUri": "com.anonyome.mysudo-dev://",
                                       "signOutRedirectUri": "com.anonyome.mysudo-dev://",
                                       "refreshTokenLifetime": 20,
                                       "webDomain": "ssotest008.auth.us-west-2.amazoncognito.com"]]

    override func setUp() async throws {
        try await super.tearDown()

        self.keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")

        do {
            self.identityProvider = MockIdentityProvider()
            self.authUI = MockAuthUI()
            self.credentialsProvider = MockCredentialsProvider()

            guard let identityServiceConfig = self.config["identityService"],
                let configProvider = SudoUserClientConfigProvider(config: identityServiceConfig) else {
                    return XCTFail("Failed to create config provider.")
            }

            self.transport = MyNetworkTransport()
            let appSyncConfig = AWSAppSyncClientConfiguration(appSyncServiceConfig: configProvider, networkTransport: self.transport)
            let apiClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            apiClient.apolloClient?.cacheKeyForObject = { $0["id"] }

            self.client = try DefaultSudoUserClient(config: self.config,
                                                 keyNamespace: "ids",
                                                 credentialsProvider: self.credentialsProvider,
                                                 identityProvider: self.identityProvider,
                                                 apiClient: apiClient,
                                                 authUI: self.authUI)
        } catch {
            XCTFail("Failed to initialize the client: \(error)")
        }

        do {
            try await self.client.reset()
        } catch {
            XCTFail("Failed to reset client: \(error)")
        }
    }

    override func tearDown() async throws {
        try await super.tearDown()

        do {
            try await self.client.reset()
        } catch {
            XCTFail("Failed to reset client: \(error)")
        }
    }

    func testSerializableObject() {
        let so = JSONSerializableObject()

        so.setProperty("Int", value: 1)
        so.setProperty("Bool", value: true)
        so.setProperty("String", value: "string")
        so.setProperty("Date", value: Date(timeIntervalSince1970: 1))
        so.setProperty("[Int]", value: [1, 2])
        so.setProperty("[Bool]", value: [true, false])
        so.setProperty("[String]", value: ["string1", "string2"])
        so.setProperty("[Date]", value: [Date(timeIntervalSince1970: 1), Date(timeIntervalSince1970: 2)])
        so.setProperty("[SerializableObject]", value: [
            JSONSerializableObject(properties: ["String": "string1" as NSString,
                                                "Int": 1 as NSNumber ])!,
            JSONSerializableObject(properties: ["String": "string2" as NSString,
                                                "Int": 2 as NSNumber ])!
        ])

        guard let data = try? so.toData() else {
            XCTFail("Failed to serialize the object.")
            return
        }

        guard let newSo = JSONSerializableObject(data: data) else {
            XCTFail("Failed to deserialize the object.")
            return
        }

        XCTAssertEqual(1, newSo.getPropertyAsInt("Int"))
        XCTAssertEqual(true, newSo.getPropertyAsBool("Bool"))
        XCTAssertEqual("string", newSo.getPropertyAsString("String"))
        guard let date = newSo.getPropertyAsDate("Date") else {
            XCTFail("Not date property found.")
            return
        }
        XCTAssertTrue(Date(timeIntervalSince1970: 1).compare(date) == .orderedSame)

        // Compiler does not seem to like using `==` with optionals. Rather than force unwrapping which causes runtime exception
        // for the test, just defaulting to empty array if nil to cause the assertion to fail.
        XCTAssertTrue([1, 2] == newSo.getPropertyAsIntArray("[Int]") ?? [])
        XCTAssertTrue([true, false] == newSo.getPropertyAsBoolArray("[Bool]") ?? [])
        XCTAssertTrue(["string1", "string2"] == newSo.getPropertyAsStringArray("[String]") ?? [])
        XCTAssertTrue([Date(timeIntervalSince1970: 1), Date(timeIntervalSince1970: 2)] == newSo.getPropertyAsDateArray("[Date]") ?? [])
        XCTAssertTrue([
            JSONSerializableObject(properties: ["String": "string1" as NSString,
                                                "Int": 1 as NSNumber])!,
            JSONSerializableObject(properties: ["String": "string2" as NSString,
                                                "Int": 2 as NSNumber])!] as [JSONSerializableObject]
            == newSo.getPropertyAsSerializableObjectArray("[SerializableObject]") ?? [])
    }

    func testReset() async {

        do {
            try self.keyManager.generateSymmetricKey("symmetrickey")
        } catch {
            XCTFail("Failed to generate symmetric key: \(error)")
        }

        do {
            try self.keyManager.generateKeyPair("userKeyId")
        } catch {
            XCTFail("Failed to generate user key pair: \(error)")
        }

        do {
            try self.keyManager.generateKeyPair("accountKeyId")
        } catch {
            XCTFail("Failed to generate account key pair: \(error)")
        }

        do {
            try self.keyManager.generateKeyPair("deviceCollectionKeyId")
        } catch {
            XCTFail("Failed to generate device collection key pair: \(error)")
        }

        do {
            try self.keyManager.addPassword("userKeyId".data(using: String.Encoding.utf8)!, name: "userKeyId")
        } catch {
            XCTFail("Failed to add user key id: \(error)")
        }

        do {
            try self.keyManager.addPassword("accountKeyId".data(using: String.Encoding.utf8)!, name: "accountKeyId")
        } catch {
            XCTFail("Failed to add account key id: \(error)")
        }

        do {
            try self.keyManager.addPassword("deviceCollectionKeyId".data(using: String.Encoding.utf8)!, name: "deviceCollectionKeyId")
        } catch {
            XCTFail("Failed to add device collection key id: \(error)")
        }

        do {
            try self.keyManager.addPassword("uid".data(using: String.Encoding.utf8)!, name: "uid")
        } catch {
            XCTFail("Failed to add user ID: \(error)")
        }

        do {
            try self.keyManager.addPassword("accountId".data(using: String.Encoding.utf8)!, name: "accountId")
        } catch {
            XCTFail("Failed to add account ID: \(error)")
        }

        do {
            try self.keyManager.addPassword("deviceCollectionId".data(using: String.Encoding.utf8)!, name: "deviceCollectionId")
        } catch {
            XCTFail("Failed to add device collection ID: \(error)")
        }

        do {
            try await self.client.reset()
        } catch {
            XCTFail("Failed to reset client: \(error)")
        }

        do {
            let privateKey = try self.keyManager.getPrivateKey("userKeyId")
            let publicKey = try self.keyManager.getPublicKey("userKeyId")
            XCTAssertNil(privateKey)
            XCTAssertNil(publicKey)
        } catch {
            XCTFail("Error occurred while attempting to retrieve user key: \(error)")
        }

        do {
            let privateKey = try self.keyManager.getPrivateKey("accountKeyId")
            let publicKey = try self.keyManager.getPublicKey("accountKeyId")
            XCTAssertNil(privateKey)
            XCTAssertNil(publicKey)
        } catch {
            XCTFail("Error occurred while attempting to retrieve account key: \(error)")
        }

        do {
            let privateKey = try self.keyManager.getPrivateKey("deviceCollectionKeyId")
            let publicKey = try self.keyManager.getPublicKey("deviceCollectionKeyId")
            XCTAssertNil(privateKey)
            XCTAssertNil(publicKey)
        } catch {
            XCTFail("Error occurred while attempting to retrieve device collection key: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("userKeyId")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to retrieve user key ID: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("accountKeyId")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to retrieve account key ID: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("deviceCollectionKeyId")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to retrieve device collection key ID: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("uid")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to retrieve uid: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("accountId")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to retrieve account ID: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("deviceCollectionId")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to retrieve device collection ID: \(error)")
        }

        do {
            let symmetricKey = try self.keyManager.getSymmetricKey("symmetrickey")
            XCTAssertNil(symmetricKey)
        } catch {
            XCTFail("Error occurred while attempting to retrieve symmetric key: \(error)")
        }
    }

    func testGeneratePassword() {
        let upperCaseChars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let lowerCaseChars = Array("abcdefghijklmnopqrstuvwxyz")
        let numberChars = Array("0123456789")
        let specialChars = Array(".!?;,&%$@#^*~")

        let idp: CognitoUserPoolIdentityProvider
        do {
            let config = ["region": "us-east-1",
                          "poolId": "us-east-1_mhy3BrqZd",
                          "poolName": "IdentityUserPool",
                          "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                          "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313"]
            idp = try CognitoUserPoolIdentityProvider(config: config, keyManager: MockKeyManager())
        } catch {
            return XCTFail("Failed to initialize Cognito identity provider: \(error)")
        }

        let password = idp.generatePassword(length: 50, upperCase: true, lowerCase: true, special: true, number: true)

        var lowerFound = false
        var upperFound = false
        var numberFound = false
        var specialFound = false
        for char in password {
            if lowerCaseChars.contains(char) {
                lowerFound = true
            } else if upperCaseChars.contains(char) {
                upperFound = true
            } else if numberChars.contains(char) {
                numberFound = true
            } else if specialChars.contains(char) {
                specialFound = true
            }
        }

        NSLog("password: \(password)")
        XCTAssertTrue(lowerFound)
        XCTAssertTrue(upperFound)
        XCTAssertTrue(numberFound)
        XCTAssertTrue(specialFound)
        XCTAssertEqual(50, password.count)
    }

    func testSupportedRegion() {
        do {
            // Initialize the client with valid AWS region names.
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "us-east-1",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                      "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                      "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "us-east-2",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "challengeService": [ "region": "us-west-2",
                                                                   "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                   "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                      "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                      "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "us-west-2",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "challengeService": [ "region": "us-west-2",
                                                                   "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                   "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                      "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                      "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "eu-central-1",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "challengeService": [ "region": "us-west-2",
                                                                   "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                   "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                      "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                      "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "eu-west-1",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "challengeService": [ "region": "us-west-2",
                                                                   "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                   "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                      "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                      "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "eu-west-2",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "challengeService": [ "region": "us-west-2",
                                                                   "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                   "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                      "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                      "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "ap-southeast-2",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "challengeService": [ "region": "us-west-2",
                                                                   "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                   "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                      "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                      "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
        } catch {
            XCTFail("Failed to initialize the client: \(error)")
        }

        do {
            // Initialize the client with unsupported AWS region name.
            _ = try DefaultSudoUserClient(config: ["identityService": [ "region": "us-west-1",
                                                                     "poolId": "us-east-1_mhy3BrqZd",
                                                                     "poolName": "IdentityUserPool",
                                                                     "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                                                                     "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                                                                     "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                     "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"],
                                                "sudoDirectory": [ "region": "us-west-2",
                                                                   "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                                                                   "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"]],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.invalidConfig {
            // Expected error caught.
        } catch {
            XCTFail("Unexpected error caught.")
        }
    }

    func testMissingIdentityServiceConfig() {
        do {
            _ = try DefaultSudoUserClient(config: [:],
                                       keyNamespace: "ids",
                                       identityProvider: nil)
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.identityServiceConfigNotFound {
            // Expected error caught.
        } catch {
            XCTFail("Unexpected error caught.")
        }
    }

    func testJWT() {
        let keyManager: SudoKeyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "sudo")
        let jwt = JWT(issuer: "dummy_issuer", audience: "dummy_audience", subject: "dummy_subject", id: "dummy_id")
        do {
            try keyManager.generateKeyPair("dummy_key_id")
            guard let publicKey = try keyManager.getPublicKey("dummy_key_id") else {
                return XCTFail("Failed to retrieve public key.")
            }
            NSLog("publicKey: \(publicKey.base64EncodedString())")
        } catch {
            XCTFail("Failed generate key pair: \(error)")
        }

        do {
            let token = try jwt.signAndEncode(keyManager: keyManager, keyId: "dummy_key_id")

            let jwt = try JWT(string: token, keyManager: keyManager)

            XCTAssertEqual("dummy_issuer", jwt.issuer)
            XCTAssertEqual("dummy_audience", jwt.audience)
            XCTAssertEqual("dummy_subject", jwt.subject)
            XCTAssertEqual("dummy_id", jwt.id)
        } catch {
            XCTFail("Failed to sign and encode JWTr: \(error)")
        }
    }

    func testRegister() async throws {
        let challenge = RegistrationChallenge()
        challenge.type = .deviceCheck
        challenge.answer = "dummy_nonce"
        challenge.expiry = Date(timeIntervalSinceNow: 3600)
        let vendorId = UUID()

        do {
            self.identityProvider.registerResult = "dummy_uid"
            _ = try await self.client.registerWithDeviceCheck(token: "dummy_token".data(using: .utf8)!, buildType: "debug", vendorId: vendorId, registrationId: "dummy_rid")
            let status = try await self.client.isRegistered()
            XCTAssertTrue(status)
            XCTAssertEqual("dummy_uid", ((try? self.client.getUserName()) as String??))
        } catch {
            XCTFail("Failed to register: \(error)")
        }

        XCTAssertEqual("DEVICE_CHECK", self.identityProvider.registrationParameters["challengeType"] as? String)
        XCTAssertEqual("dummy_token".data(using: .utf8)!.base64EncodedString(), self.identityProvider.registrationParameters["answer"] as? String)
        XCTAssertEqual("dummy_rid", self.identityProvider.registrationParameters["registrationId"] as? String)

        let data = withUnsafePointer(to: vendorId.uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: vendorId.uuid))
        }

        XCTAssertEqual(data.base64EncodedString(), self.identityProvider.registrationParameters["deviceId"] as? String)
    }

    func testDeregister() async throws {
        self.transport.responseBody.append([
            "data": [
                "deregister": [
                    "__typename": "Deregister",
                    "success": true
                ]
            ]
        ])

        do {
            try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")

            self.identityProvider.deregisterResult = "dummy_uid"
            _ = try await self.client.deregister()
            let status = try await self.client.isRegistered()
            XCTAssertFalse(status)
        } catch {
            XCTFail("Failed to deregister: \(error)")
        }
    }

    func testSignIn() async throws {
        let observer = MySignInStatusObserver()
        await self.client.registerSignInStatusObserver(id: "dummy_id", observer: observer)

        self.transport.responseBody.append([
            "data": [
                "registerFederatedId": [
                    "__typename": "FederatedId",
                    "identityId": "dummy_id"
                ]
            ]
        ])

        self.credentialsProvider.identityId = nil

        do {
            try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")

            let keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
            let userKeyId = "dummy_key_id"
            try keyManager.generateKeyPair(userKeyId)
            try keyManager.addPassword(userKeyId.data(using: .utf8)!, name: "userKeyId")

            self.identityProvider.signInResult = AuthenticationTokens(
                idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjVEODQ2MTBFLUYzQ0ItNDU0Mi1BQjBDLUZGQzhGODZDMEU5OSJ9.eyJqdGkiOiIxNmE0ZjhkZS1hN2M3LTQ4ZDYtYmMwZS1jMDc2NWZhMTc2NmIiLCJpc3MiOiIyMTVBMzQzOC1ENjdBLTRGMDItQjc2My0wMzA0Q0E2NDlGMTEiLCJhdWQiOiJhdWRpZW5jZSIsInN1YiI6IjIxNUEzNDM4LUQ2N0EtNEYwMi1CNzYzLTAzMDRDQTY0OUYxMSIsImlhdCI6MTU3NzkzNTA2NCwiZXhwIjoxNTc3OTM1MzY0fQ.izTHh9B8j1vQXKRVGbdMAN7zo6VA_ivLUPF7Tto-74F0teGMNRBtqSMavBTnQlC5ZdxqzsgkiptxSoVqJngPfYXof42VkRpAgbMbbdUeTBx0s_8z6GSbIQgl-WDw07hM1pDrG2I5MtRcAkNBpUX1kKkAUJX-8cric_L31KIxSGCzBbePBr2TYLqglXo9hGWG5yFDrWw9H2gsJ6_O-mkgjN4l_4yoS2VaG-dMC96oxAm37VI6-zmYF5FKHjrDpi7gNsUoUzQebC46RTNXlvlEOYyHFFqXabP1AL_KQl_uQL_rot_wGr4o0kxgH7Ycz0zPZQ7NWY5zi7VvOMb8j2ds8w",
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                lifetime: 3600,
                username: "dummy_uid"
            )

            self.identityProvider.refreshTokensResult = AuthenticationTokens(
                idToken: "dummy_id_token",
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                lifetime: 3600,
                username: "dummy_uid"
            )

            let tokens = try await self.client.signInWithKey()
            guard let variables = self.transport.variables.first else {
                return XCTFail("Expected request not found.")
            }

            do {
                let data = try JSONSerializationFormat.serialize(value: variables)

                guard let jsonObject = data.toJSONObject() as? [String: Any],
                      let input = jsonObject["input"] as? [String: Any],
                      let idToken = input["idToken"] as? String else {
                          return XCTFail("Expected input not found.")
                      }

                XCTAssertEqual("eyJhbGciOiJSUzI1NiIsImtpZCI6IjVEODQ2MTBFLUYzQ0ItNDU0Mi1BQjBDLUZGQzhGODZDMEU5OSJ9.eyJqdGkiOiIxNmE0ZjhkZS1hN2M3LTQ4ZDYtYmMwZS1jMDc2NWZhMTc2NmIiLCJpc3MiOiIyMTVBMzQzOC1ENjdBLTRGMDItQjc2My0wMzA0Q0E2NDlGMTEiLCJhdWQiOiJhdWRpZW5jZSIsInN1YiI6IjIxNUEzNDM4LUQ2N0EtNEYwMi1CNzYzLTAzMDRDQTY0OUYxMSIsImlhdCI6MTU3NzkzNTA2NCwiZXhwIjoxNTc3OTM1MzY0fQ.izTHh9B8j1vQXKRVGbdMAN7zo6VA_ivLUPF7Tto-74F0teGMNRBtqSMavBTnQlC5ZdxqzsgkiptxSoVqJngPfYXof42VkRpAgbMbbdUeTBx0s_8z6GSbIQgl-WDw07hM1pDrG2I5MtRcAkNBpUX1kKkAUJX-8cric_L31KIxSGCzBbePBr2TYLqglXo9hGWG5yFDrWw9H2gsJ6_O-mkgjN4l_4yoS2VaG-dMC96oxAm37VI6-zmYF5FKHjrDpi7gNsUoUzQebC46RTNXlvlEOYyHFFqXabP1AL_KQl_uQL_rot_wGr4o0kxgH7Ycz0zPZQ7NWY5zi7VvOMb8j2ds8w", idToken)
            } catch {
                return XCTFail("Failed to parse operation variables: \(error)")
            }

            XCTAssertEqual("dummy_id_token", tokens.idToken)
            XCTAssertEqual("dummy_access_token", tokens.accessToken)
            XCTAssertEqual("dummy_refresh_token", tokens.refreshToken)
            XCTAssertEqual(3600, tokens.lifetime)

            do {
                guard let storedIdToken = try self.client.getIdToken(),
                      let storedAccessToken = try self.client.getAccessToken(),
                      let storedRefreshToken = try self.client.getRefreshToken(),
                      let storedTokenExpiry = try self.client.getTokenExpiry(),
                      let storedRefreshTokenExpiry = try self.client.getRefreshTokenExpiry() else {
                          return XCTFail("Tokens not found.")
                      }

                XCTAssertEqual(tokens.idToken, storedIdToken)
                XCTAssertEqual(tokens.accessToken, storedAccessToken)
                XCTAssertEqual(tokens.refreshToken, storedRefreshToken)
                XCTAssertTrue(storedTokenExpiry < Date(timeIntervalSinceNow: 3600 + 10))
                XCTAssertTrue(storedTokenExpiry > Date(timeIntervalSinceNow: 3600 - 10))

                XCTAssertTrue(Date(timeIntervalSinceNow: 60 * 60 * 24 * 20 - 10) < storedRefreshTokenExpiry)
                XCTAssertTrue(Date(timeIntervalSinceNow: 60 * 60 * 24 * 20 + 10) > storedRefreshTokenExpiry)
            } catch {
                XCTFail("Failed to validate the result: \(error)")
            }
        } catch {
            XCTFail("Failed to register: \(error)")
        }

        self.wait(for: [observer.signedInExpectation, observer.signingInExpectation], timeout: 10)
    }

    func testDuplicateSignIn() async throws {

        // Mock Identity Provider that never completes sign in.
        class MyMockIdentityProvider: MockIdentityProvider {

            override func signIn(uid: String, parameters: [String: Any]) async throws -> AuthenticationTokens {
                return try await withCheckedThrowingContinuation({ (_: CheckedContinuation<AuthenticationTokens, Error>) in
                })
            }

        }

        try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")

        let keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
        let userKeyId = "dummy_key_id"
        try keyManager.generateKeyPair(userKeyId)
        try keyManager.addPassword(userKeyId.data(using: .utf8)!, name: "userKeyId")

        self.identityProvider = MyMockIdentityProvider()
        self.authUI = MockAuthUI()
        self.credentialsProvider = MockCredentialsProvider()

        guard let identityServiceConfig = self.config["identityService"],
              let configProvider = SudoUserClientConfigProvider(config: identityServiceConfig) else {
                  return XCTFail("Failed to create config provider.")
              }

        self.transport = MyNetworkTransport()
        let appSyncConfig = AWSAppSyncClientConfiguration(appSyncServiceConfig: configProvider, networkTransport: self.transport)
        let apiClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
        apiClient.apolloClient?.cacheKeyForObject = { $0["id"] }

        self.client = try DefaultSudoUserClient(config: self.config,
                                                keyNamespace: "ids",
                                                credentialsProvider: self.credentialsProvider,
                                                identityProvider: self.identityProvider,
                                                apiClient: apiClient,
                                                authUI: self.authUI)
        Task.detached {
            try await self.client.signInWithKey()
        }

        Task.detached {
            do {
                // This duplicate call should throw an error.
                _ = try await self.client.signInWithKey()
                XCTFail("Expected error not thrown.")
            } catch SudoUserClientError.signInOperationAlreadyInProgress {
                // Expected error thrown.
            } catch {
                XCTFail("Unexpected error returned by signIn API: \(error)")
            }
        }
    }

    func testRefreshTokens() async throws {
        let observer = MySignInStatusObserver()
        await self.client.registerSignInStatusObserver(id: "dummy_id", observer: observer)

        do {
            self.identityProvider.refreshTokensResult = AuthenticationTokens(
                idToken: "dummy_id_token",
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                lifetime: 3600,
                username: "dummy_uid"
            )
            try self.keyManager.addPassword("dummy_refresh_token".data(using: .utf8)!, name: "refreshToken")
            let tokens = try await self.client.refreshTokens()
            XCTAssertEqual("dummy_id_token", tokens.idToken)
            XCTAssertEqual("dummy_access_token", tokens.accessToken)
            XCTAssertEqual("dummy_refresh_token", tokens.refreshToken)
            XCTAssertEqual(3600, tokens.lifetime)

            do {
                guard let storedIdToken = try self.client.getIdToken(),
                      let storedAccessToken = try self.client.getAccessToken(),
                      let storedRefreshToken = try self.client.getRefreshToken(),
                      let storedTokenExpiry = try self.client.getTokenExpiry() else {
                          return XCTFail("Tokens not found.")
                      }

                XCTAssertEqual(tokens.idToken, storedIdToken)
                XCTAssertEqual(tokens.accessToken, storedAccessToken)
                XCTAssertEqual(tokens.refreshToken, storedRefreshToken)
                XCTAssertTrue(storedTokenExpiry < Date(timeIntervalSinceNow: 3600 + 10))
                XCTAssertTrue(storedTokenExpiry > Date(timeIntervalSinceNow: 3600 - 10))
            } catch {
                XCTFail("Failed to validate the result: \(error)")
            }
        } catch {
            XCTFail("Failed to refresh tokens: \(error)")
        }

        self.wait(for: [observer.signingInExpectation, observer.signedInExpectation], timeout: 10)
    }

    func testDuplicateRefreshTokens() async throws {

        // Mock Identity Provider that never completes token refresh.
        class MyMockIdentityProvider: MockIdentityProvider {

            override func refreshTokens(refreshToken: String) async throws -> AuthenticationTokens {
                return try await withCheckedThrowingContinuation({ (_: CheckedContinuation<AuthenticationTokens, Error>) in
                })
            }

        }

        try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")

        let keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
        let userKeyId = "dummy_key_id"
        try keyManager.generateKeyPair(userKeyId)
        try keyManager.addPassword(userKeyId.data(using: .utf8)!, name: "userKeyId")

        self.identityProvider = MyMockIdentityProvider()
        self.authUI = MockAuthUI()
        self.credentialsProvider = MockCredentialsProvider()

        guard let identityServiceConfig = self.config["identityService"],
              let configProvider = SudoUserClientConfigProvider(config: identityServiceConfig) else {
                  return XCTFail("Failed to create config provider.")
              }

        self.transport = MyNetworkTransport()
        let appSyncConfig = AWSAppSyncClientConfiguration(appSyncServiceConfig: configProvider, networkTransport: self.transport)
        let apiClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
        apiClient.apolloClient?.cacheKeyForObject = { $0["id"] }

        self.client = try DefaultSudoUserClient(config: self.config,
                                                keyNamespace: "ids",
                                                credentialsProvider: self.credentialsProvider,
                                                identityProvider: self.identityProvider,
                                                apiClient: apiClient,
                                                authUI: self.authUI)

        Task.detached {
            try await self.client.refreshTokens(refreshToken: "dummy_refresh_token")
        }

        Task.detached {
            do {
                // This duplicate call should throw an error.
                _ = try await self.client.refreshTokens(refreshToken: "dummy_refresh_token")
                XCTFail("Expected error not thrown.")
            } catch SudoUserClientError.refreshTokensOperationAlreadyInProgress {
                // Expected error thrown.
            } catch {
                XCTFail("Unexpected error returned by signIn API: \(error)")
            }
        }
    }

    func testGraphQLAuthProvider() async throws {
        let client = MockSudoUserClient()
        client.getIdTokenReturn = "dummy_id_token"
        client.getRefreshTokenReturn = "dummy_refresh_token"
        client.getTokenExpiryReturn = Date(timeIntervalSinceNow: 3600)

        var authProvider = GraphQLAuthProvider(client: client)
        var expectation = self.expectation(description: "")

        authProvider.getLatestAuthToken { (token, error) in
            XCTAssertEqual("dummy_id_token", token)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)

        XCTAssertTrue(client.getIdTokenCalled)
        XCTAssertTrue(client.getRefreshTokenCalled)
        XCTAssertTrue(client.getTokenExpiryCalled)
        XCTAssertFalse(client.refreshTokensCalled)

        // Test the token refresh. Expiry 50 secs from now should trigger a refresh since the token is
        // refreshed 1 min prior to expiry.
        client.getTokenExpiryReturn = Date(timeIntervalSinceNow: 50)

        client.getIdTokenCalled = false
        client.getRefreshTokenCalled = false
        client.getTokenExpiryCalled = false
        client.refreshTokensResult = AuthenticationTokens(idToken: "dummy_id_token_new",
                                                          accessToken: "dummy_access_token",
                                                          refreshToken: "dummy_refresh_token",
                                                          lifetime: 3600,
                                                          username: "dummy_uid"
        )

        expectation = self.expectation(description: "")

        authProvider.getLatestAuthToken { (token, error) in
            XCTAssertEqual("dummy_id_token_new", token)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)

        XCTAssertTrue(client.getIdTokenCalled)
        XCTAssertTrue(client.getRefreshTokenCalled)
        XCTAssertTrue(client.getTokenExpiryCalled)
        XCTAssertTrue(client.refreshTokensCalled)

        client.refreshTokensError = SudoUserClientError.notAuthorized
        expectation = self.expectation(description: "")

        authProvider.getLatestAuthToken { (token, error) in
            XCTAssertNil(token)
            switch error {
            case GraphQLAuthProviderError.notAuthorized?:
                break
            default:
                XCTFail("Expected error not return.")
            }
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)

        client.refreshTokensError = SudoUserClientError.notAuthorized

        expectation = self.expectation(description: "")

        authProvider.getLatestAuthToken { (token, error) in
            XCTAssertNil(token)
            switch error {
            case GraphQLAuthProviderError.notAuthorized?:
                break
            default:
                XCTFail("Expected error not return.")
            }
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)

        client.refreshTokensError = SudoUserClientError.notSignedIn
        expectation = self.expectation(description: "")

        authProvider.getLatestAuthToken { (token, error) in
            XCTAssertNil(token)
            switch error {
            case GraphQLAuthProviderError.notSignedIn?:
                break
            default:
                XCTFail("Expected error not return.")
            }
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)

        // When auto refresh is turned off the auth provider should throw an error.
        authProvider = GraphQLAuthProvider(client: client, autoRefreshTokens: false)
        expectation = self.expectation(description: "")

        authProvider.getLatestAuthToken { (token, error) in
            XCTAssertNil(token)
            switch error {
            case GraphQLAuthProviderError.notAuthorized?:
                break
            default:
                XCTFail("Expected error not return.")
            }
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 10)
    }

    func testMockClient() async throws {

        enum MyError: Error {
            case myError
        }

        class MyAuthenticationInfo: AuthenticationInfo {

            func getUsername() -> String {
                return ""
            }

            let type: String = "myauth"

            func isValid() -> Bool {
                return true
            }

            func toString() -> String {
                return "dummy_token"
            }

        }

        class MyAuthenticationProvider: AuthenticationProvider {

            func getAuthenticationInfo() async throws -> AuthenticationInfo {
                return MyAuthenticationInfo()
            }

            func reset() {
            }

        }

        let client = MockSudoUserClient()

        client.isRegisteredReturn = true
        let status = client.isRegistered()
        XCTAssertTrue(client.isRegisteredCalled)
        XCTAssertTrue(status)

        try client.reset()
        XCTAssertTrue(client.resetCalled)

        do {
            client.resetError = MyError.myError
            try client.reset()
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        client.registerWithAuthenticationProviderResult = "dummy_uid"
        let uid = try await client.registerWithAuthenticationProvider(authenticationProvider: MyAuthenticationProvider(), registrationId: "dummy_rid")
        XCTAssertEqual("dummy_uid", uid)

        XCTAssertTrue(client.registerWithAuthenticationProviderCalled)
        XCTAssertEqual("dummy_rid", client.registerWithAuthenticationProviderParamRegistrationId)

        let authInfo = try await client.registerWithAuthenticationProviderParamAuthenticationProvider?.getAuthenticationInfo()
        XCTAssertEqual("dummy_token", authInfo?.toString())

        do {
            client.registerWithAuthenticationProviderError = MyError.myError
            _ = try await client.registerWithAuthenticationProvider(authenticationProvider: MyAuthenticationProvider(), registrationId: "dummy_rid")
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        client.deregisterResult = "dummy_uid"
        _ = try await client.deregister()
        XCTAssertEqual("dummy_uid", uid)

        XCTAssertTrue(client.deregisterCalled)

        client.signInWithKeyResult = AuthenticationTokens(
            idToken: "dummy_id_token",
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token",
            lifetime: 3600,
            username: "dummy_uid")
        var tokens = try await client.signInWithKey()
        XCTAssertEqual("dummy_id_token", tokens.idToken)
        XCTAssertEqual("dummy_access_token", tokens.accessToken)
        XCTAssertEqual("dummy_refresh_token", tokens.refreshToken)
        XCTAssertEqual(3600, tokens.lifetime)

        XCTAssertTrue(client.signInWithKeyCalled)

        do {
            client.signInWithKeyError = MyError.myError
            _ = try await client.signInWithKey()
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        client.refreshTokensResult = AuthenticationTokens(
            idToken: "dummy_id_token",
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token",
            lifetime: 3600,
            username: "dummy_uid"
        )

        tokens = try await client.refreshTokens(refreshToken: "dummy_refresh_token")
        XCTAssertEqual("dummy_id_token", tokens.idToken)
        XCTAssertEqual("dummy_access_token", tokens.accessToken)
        XCTAssertEqual("dummy_refresh_token", tokens.refreshToken)
        XCTAssertEqual(3600, tokens.lifetime)

        XCTAssertEqual("dummy_refresh_token", client.refreshTokensParamRefreshToken)

        XCTAssertTrue(client.signInWithKeyCalled)

        do {
            client.refreshTokensError = MyError.myError
            _ = try await client.refreshTokens(refreshToken: "dummy_refresh_token")
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        client.getUserNameReturn = "dummy_uid"
        XCTAssertEqual("dummy_uid", try client.getUserName())
        XCTAssertTrue(client.getUserNameCalled)

        do {
            client.getUserNameError = MyError.myError
            _ = try client.getUserName()
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        client.getIdTokenReturn = "dummy_id_token"
        XCTAssertEqual("dummy_id_token", try client.getIdToken())
        XCTAssertTrue(client.getIdTokenCalled)

        do {
            client.getIdTokenError = MyError.myError
            _ = try client.getIdToken()
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        client.getAccessTokenReturn = "dummy_access_token"
        XCTAssertEqual("dummy_access_token", try client.getAccessToken())
        XCTAssertTrue(client.getAccessTokenCalled)

        do {
            client.getAccessTokenError = MyError.myError
            _ = try client.getAccessToken()
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        client.getRefreshTokenReturn = "dummy_refresh_token"
        XCTAssertEqual("dummy_refresh_token", try client.getRefreshToken())
        XCTAssertTrue(client.getRefreshTokenCalled)

        do {
            client.getRefreshTokenError = MyError.myError
            _ = try client.getRefreshToken()
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let date = Date(timeIntervalSince1970: 3600)
        client.getTokenExpiryReturn = date
        XCTAssertEqual(date, try client.getTokenExpiry())
        XCTAssertTrue(client.getTokenExpiryCalled)

        do {
            client.getTokenExpiryError = MyError.myError
            _ = try client.getTokenExpiry()
        } catch MyError.myError {
            // Expected error.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testClearAuthTokens() async {
        do {
            try self.keyManager.addPassword("accessToken".data(using: String.Encoding.utf8)!, name: "accessToken")
        } catch {
            XCTFail("Failed to add accessToken: \(error)")
        }

        do {
            try self.keyManager.addPassword("idToken".data(using: String.Encoding.utf8)!, name: "idToken")
        } catch {
            XCTFail("Failed to add idToken: \(error)")
        }

        do {
            try self.keyManager.addPassword("refreshToken".data(using: String.Encoding.utf8)!, name: "refreshToken")
        } catch {
            XCTFail("Failed to add accessToken: \(error)")
        }

        do {
            try self.keyManager.addPassword("tokenExpiry".data(using: String.Encoding.utf8)!, name: "tokenExpiry")
        } catch {
            XCTFail("Failed to add tokenExpiry: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("accessToken")
            XCTAssertNotNil(password)
        } catch {
            XCTFail("Error occurred while attempting to accessToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("idToken")
            XCTAssertNotNil(password)
        } catch {
            XCTFail("Error occurred while attempting to idToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("refreshToken")
            XCTAssertNotNil(password)
        } catch {
            XCTFail("Error occurred while attempting to refreshToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("tokenExpiry")
            XCTAssertNotNil(password)
        } catch {
            XCTFail("Error occurred while attempting to tokenExpiry: \(error)")
        }

        do {
            try await self.client.clearAuthTokens()
        } catch {
            XCTFail("Error occurred while attempting to clear authentication tokens: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("accessToken")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to accessToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("idToken")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to idToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("refreshToken")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to refreshToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("tokenExpiry")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to tokenExpiry: \(error)")
        }
    }

    func testSignOut() async throws {
        do {
            try self.keyManager.addPassword("dummy_refresh_token".data(using: .utf8)!, name: "refreshToken")
            try await self.client.signOut()
            XCTAssertEqual("dummy_refresh_token", self.identityProvider.refreshToken)
            do {
                let idToken = try self.client.getIdToken()
                let accessToken = try self.client.getAccessToken()
                let refreshToken = try self.client.getRefreshToken()
                let tokenExpiry = try self.client.getTokenExpiry()
                XCTAssertNil(idToken)
                XCTAssertNil(accessToken)
                XCTAssertNil(refreshToken)
                XCTAssertNil(tokenExpiry)
            } catch {
                XCTFail("Failed to retrieve tokens: \(error)")
            }
        } catch {
            XCTFail("Failed to refresh tokens: \(error)")
        }
    }

    func testGlobalSignOut() async throws {
        do {
            try self.keyManager.addPassword("accessToken".data(using: String.Encoding.utf8)!, name: "accessToken")
        } catch {
            XCTFail("Failed to add accessToken: \(error)")
        }

        do {
            try self.keyManager.addPassword("idToken".data(using: String.Encoding.utf8)!, name: "idToken")
        } catch {
            XCTFail("Failed to add idToken: \(error)")
        }

        do {
            try self.keyManager.addPassword("refreshToken".data(using: String.Encoding.utf8)!, name: "refreshToken")
        } catch {
            XCTFail("Failed to add accessToken: \(error)")
        }

        do {
            try self.keyManager.addPassword("tokenExpiry".data(using: String.Encoding.utf8)!, name: "tokenExpiry")
        } catch {
            XCTFail("Failed to add tokenExpiry: \(error)")
        }

        self.transport.responseBody.append([
            "data": [
                "globalSignOut": [
                    "__typename": "GlobalSignOut",
                    "success": true
                ]
            ]
        ])

        try await client.globalSignOut()

        do {
            let password = try self.keyManager.getPassword("accessToken")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to accessToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("idToken")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to idToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("refreshToken")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to refreshToken: \(error)")
        }

        do {
            let password = try self.keyManager.getPassword("tokenExpiry")
            XCTAssertNil(password)
        } catch {
            XCTFail("Error occurred while attempting to tokenExpiry: \(error)")
        }
    }

    @MainActor
    func testFederatedSignIn() async throws {
        self.transport.responseBody.append([
            "data": [
                "registerFederatedId": [
                    "__typename": "FederatedId",
                    "identityId": "dummy_id"
                ]
            ]
        ])

        self.authUI.federatedSignInResult = AuthenticationTokens(
            idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjVEODQ2MTBFLUYzQ0ItNDU0Mi1BQjBDLUZGQzhGODZDMEU5OSJ9.eyJqdGkiOiIxNmE0ZjhkZS1hN2M3LTQ4ZDYtYmMwZS1jMDc2NWZhMTc2NmIiLCJpc3MiOiIyMTVBMzQzOC1ENjdBLTRGMDItQjc2My0wMzA0Q0E2NDlGMTEiLCJhdWQiOiJhdWRpZW5jZSIsInN1YiI6IjIxNUEzNDM4LUQ2N0EtNEYwMi1CNzYzLTAzMDRDQTY0OUYxMSIsImlhdCI6MTU3NzkzNTA2NCwiZXhwIjoxNTc3OTM1MzY0fQ.izTHh9B8j1vQXKRVGbdMAN7zo6VA_ivLUPF7Tto-74F0teGMNRBtqSMavBTnQlC5ZdxqzsgkiptxSoVqJngPfYXof42VkRpAgbMbbdUeTBx0s_8z6GSbIQgl-WDw07hM1pDrG2I5MtRcAkNBpUX1kKkAUJX-8cric_L31KIxSGCzBbePBr2TYLqglXo9hGWG5yFDrWw9H2gsJ6_O-mkgjN4l_4yoS2VaG-dMC96oxAm37VI6-zmYF5FKHjrDpi7gNsUoUzQebC46RTNXlvlEOYyHFFqXabP1AL_KQl_uQL_rot_wGr4o0kxgH7Ycz0zPZQ7NWY5zi7VvOMb8j2ds8w",
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token",
            lifetime: 3600,
            username: "dummy_username"
        )

        self.identityProvider.refreshTokensResult = AuthenticationTokens(
            idToken: "dummy_id_token",
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token",
            lifetime: 3600,
            username: "dummy_username"
        )

        self.credentialsProvider.identityId = nil

        let tokens = try await self.client.presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor())
        guard let variables = self.transport.variables.first else {
            return XCTFail("Expected request not found.")
        }

        do {
            let data = try JSONSerializationFormat.serialize(value: variables)

            guard let jsonObject = data.toJSONObject() as? [String: Any],
                  let input = jsonObject["input"] as? [String: Any],
                  let idToken = input["idToken"] as? String else {
                      return XCTFail("Expected input not found.")
                  }

            XCTAssertEqual("eyJhbGciOiJSUzI1NiIsImtpZCI6IjVEODQ2MTBFLUYzQ0ItNDU0Mi1BQjBDLUZGQzhGODZDMEU5OSJ9.eyJqdGkiOiIxNmE0ZjhkZS1hN2M3LTQ4ZDYtYmMwZS1jMDc2NWZhMTc2NmIiLCJpc3MiOiIyMTVBMzQzOC1ENjdBLTRGMDItQjc2My0wMzA0Q0E2NDlGMTEiLCJhdWQiOiJhdWRpZW5jZSIsInN1YiI6IjIxNUEzNDM4LUQ2N0EtNEYwMi1CNzYzLTAzMDRDQTY0OUYxMSIsImlhdCI6MTU3NzkzNTA2NCwiZXhwIjoxNTc3OTM1MzY0fQ.izTHh9B8j1vQXKRVGbdMAN7zo6VA_ivLUPF7Tto-74F0teGMNRBtqSMavBTnQlC5ZdxqzsgkiptxSoVqJngPfYXof42VkRpAgbMbbdUeTBx0s_8z6GSbIQgl-WDw07hM1pDrG2I5MtRcAkNBpUX1kKkAUJX-8cric_L31KIxSGCzBbePBr2TYLqglXo9hGWG5yFDrWw9H2gsJ6_O-mkgjN4l_4yoS2VaG-dMC96oxAm37VI6-zmYF5FKHjrDpi7gNsUoUzQebC46RTNXlvlEOYyHFFqXabP1AL_KQl_uQL_rot_wGr4o0kxgH7Ycz0zPZQ7NWY5zi7VvOMb8j2ds8w", idToken)
        } catch {
            return XCTFail("Failed to parse operation variables: \(error)")
        }

        XCTAssertEqual("dummy_id_token", tokens.idToken)
        XCTAssertEqual("dummy_access_token", tokens.accessToken)
        XCTAssertEqual("dummy_refresh_token", tokens.refreshToken)
        XCTAssertEqual(3600, tokens.lifetime)

        XCTAssertEqual("dummy_id_token".data(using: .utf8), ((try? self.keyManager.getPassword("idToken")) as Data??))
        XCTAssertEqual("dummy_access_token".data(using: .utf8), ((try? self.keyManager.getPassword("accessToken")) as Data??))
        XCTAssertEqual("dummy_refresh_token".data(using: .utf8), ((try? self.keyManager.getPassword("refreshToken")) as Data??))
        XCTAssertEqual("dummy_username".data(using: .utf8), ((try? self.keyManager.getPassword("userId")) as Data??))
    }

    @MainActor
    func testFederatedSignOut() async throws {
        do {
            try await self.client.presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor())
        } catch {
            XCTFail("Failed to sign in: \(error)")
        }
    }

    func testGetUserClaim() {
        let idToken = "eyJraWQiOiJYOUhRWUFhQnhmNzY1Q0RKWlgrUjh6Vnd0SnFiNDdcL2JSK0M4UWZzK0RaQT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIyYjQ0ZTJhMy00MTI1LTQ1ZTUtOTYwMi02MmIxYzI5ZTNjMTMiLCJhdWQiOiIzdWw0Z3Q1aWxkNTA4c29lZjdodnJmdDl2ZyIsImV2ZW50X2lkIjoiNjZjZGNhNGEtZTE2ZC00N2M5LWE0OTctZmI5NjJiOGJiMzg1IiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE1NzU1MDI1NTYsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy13ZXN0LTIuYW1hem9uYXdzLmNvbVwvdXMtd2VzdC0yX24xRXp4ZzVWaiIsImNvZ25pdG86dXNlcm5hbWUiOiIxRTcyRUEwMS04MEI2LTQ1MEQtOTkzNS0wNEU2RDJBQ0E0OTYiLCJleHAiOjE1NzU1MDYxNTYsImlhdCI6MTU3NTUwMjU1Nn0.k1K5uAy5_toVahHHfM3bZnRtYK7IEwyGHyIcRfvav82dsEn_e4brM0u3O78OvHrdIleHuNZzcEf2FYyi9u0Kq3b4Eo8EZEdTEkKUiVT_RDUgPG-WYn5ZWNt3k1iYd6bEKy9Pt4Gpm2JhQnlhV_VAc1RY41G7Rfc4gGXWkU8dU62wqYFB1ZWI7WKP97dZ4Fcz5MAA_Nig0jDhkSB0nFX95srnvqWbp9p6mbo-Z-Zw44wADYT6suijofE_uSacuiLtzPoBkbW3sZah_1vSOJCLA1qU45wsZskeGIHb_DgOzvrePM-famPXi9D_p8UxRLQaewhK-ZZInE0CTan4_Zh2Hw"

        do {
            try self.keyManager.addPassword(idToken.data(using: .utf8)!, name: "idToken")
            XCTAssertEqual("1E72EA01-80B6-450D-9935-04E6D2ACA496", try self.client.getUserClaim(name: "cognito:username") as? String)
        } catch {
            XCTFail("Failed to retrieve the user claim: \(error)")
        }
    }

    func testDefaultInit() {
        do {
            _ = try DefaultSudoUserClient(keyNamespace: "ids", logger: nil)
        } catch {
            XCTFail("Failed to initialized client: \(error)")
        }
    }

    func testIsSignedIn() async throws {
        do {
            try self.keyManager.addPassword("dummy_id_token".data(using: .utf8)!, name: "idToken")
            try self.keyManager.addPassword("dummy_access_token".data(using: .utf8)!, name: "accessToken")
            try self.keyManager.addPassword("\(Date().addingTimeInterval(3605).timeIntervalSince1970)".data(using: .utf8)!, name: "refreshTokenExpiry")
        } catch {
            XCTFail("Failed to create keychain items: \(error)")
        }

        var status = try await self.client.isSignedIn()
        XCTAssertTrue(status)

        // Try expired token.
        do {
            try self.keyManager.deletePassword("refreshTokenExpiry")
            try self.keyManager.addPassword("\(Date().addingTimeInterval(3595).timeIntervalSince1970)".data(using: .utf8)!, name: "refreshTokenExpiry")
        } catch {
            XCTFail("Failed to create keychain items: \(error)")
        }

        status = try await self.client.isSignedIn()
        XCTAssertFalse(status)

        // No stored tokens.
        do {
            try self.keyManager.deletePassword("idToken")
            try self.keyManager.deletePassword("accessToken")
            try self.keyManager.deletePassword("refreshTokenExpiry")
        } catch {
            XCTFail("Failed to delete keychain items: \(error)")
        }

        status = try await self.client.isSignedIn()
        XCTAssertFalse(status)
    }

    func testGetSupportedRegistrationChallengeTypes() {
        let challengeTypes = self.client.getSupportedRegistrationChallengeType()
        XCTAssertTrue(challengeTypes.contains(.deviceCheck))
        XCTAssertTrue(challengeTypes.contains(.test))
    }

    func testSignInWithAuthenticationProvider() async throws {

        class MyAuthenticationInfo: AuthenticationInfo {

            let type = "FSSO"

            func isValid() -> Bool {
                return true
            }

            func toString() -> String {
                return "dummy_token"
            }

            func getUsername() -> String {
                return "dummy_uid"
            }

        }

        class MyAuthenticationProvider: AuthenticationProvider {

            func getAuthenticationInfo() async throws -> AuthenticationInfo {
                return MyAuthenticationInfo()
            }

            func reset() {
            }

        }

        let observer = MySignInStatusObserver()
        await self.client.registerSignInStatusObserver(id: "dummy_id", observer: observer)

        self.transport.responseBody.append([
            "data": [
                "registerFederatedId": [
                    "__typename": "FederatedId",
                    "identityId": "dummy_id"
                ]
            ]
        ])

        self.credentialsProvider.identityId = nil

        do {
            try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")

            self.identityProvider.signInResult = AuthenticationTokens(
                idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjVEODQ2MTBFLUYzQ0ItNDU0Mi1BQjBDLUZGQzhGODZDMEU5OSJ9.eyJqdGkiOiIxNmE0ZjhkZS1hN2M3LTQ4ZDYtYmMwZS1jMDc2NWZhMTc2NmIiLCJpc3MiOiIyMTVBMzQzOC1ENjdBLTRGMDItQjc2My0wMzA0Q0E2NDlGMTEiLCJhdWQiOiJhdWRpZW5jZSIsInN1YiI6IjIxNUEzNDM4LUQ2N0EtNEYwMi1CNzYzLTAzMDRDQTY0OUYxMSIsImlhdCI6MTU3NzkzNTA2NCwiZXhwIjoxNTc3OTM1MzY0fQ.izTHh9B8j1vQXKRVGbdMAN7zo6VA_ivLUPF7Tto-74F0teGMNRBtqSMavBTnQlC5ZdxqzsgkiptxSoVqJngPfYXof42VkRpAgbMbbdUeTBx0s_8z6GSbIQgl-WDw07hM1pDrG2I5MtRcAkNBpUX1kKkAUJX-8cric_L31KIxSGCzBbePBr2TYLqglXo9hGWG5yFDrWw9H2gsJ6_O-mkgjN4l_4yoS2VaG-dMC96oxAm37VI6-zmYF5FKHjrDpi7gNsUoUzQebC46RTNXlvlEOYyHFFqXabP1AL_KQl_uQL_rot_wGr4o0kxgH7Ycz0zPZQ7NWY5zi7VvOMb8j2ds8w",
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                lifetime: 3600,
                username: "dummy_uid"
            )

            self.identityProvider.refreshTokensResult = AuthenticationTokens(
                idToken: "dummy_id_token",
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                lifetime: 3600,
                username: "dummy_uid"
            )

            let tokens = try await self.client.signInWithAuthenticationProvider(authenticationProvider: MyAuthenticationProvider())
            guard let variables = self.transport.variables.first else {
                return XCTFail("Expected request not found.")
            }

            do {
                let data = try JSONSerializationFormat.serialize(value: variables)

                guard let jsonObject = data.toJSONObject() as? [String: Any],
                      let input = jsonObject["input"] as? [String: Any],
                      let idToken = input["idToken"] as? String else {
                          return XCTFail("Expected input not found.")
                      }

                XCTAssertEqual("eyJhbGciOiJSUzI1NiIsImtpZCI6IjVEODQ2MTBFLUYzQ0ItNDU0Mi1BQjBDLUZGQzhGODZDMEU5OSJ9.eyJqdGkiOiIxNmE0ZjhkZS1hN2M3LTQ4ZDYtYmMwZS1jMDc2NWZhMTc2NmIiLCJpc3MiOiIyMTVBMzQzOC1ENjdBLTRGMDItQjc2My0wMzA0Q0E2NDlGMTEiLCJhdWQiOiJhdWRpZW5jZSIsInN1YiI6IjIxNUEzNDM4LUQ2N0EtNEYwMi1CNzYzLTAzMDRDQTY0OUYxMSIsImlhdCI6MTU3NzkzNTA2NCwiZXhwIjoxNTc3OTM1MzY0fQ.izTHh9B8j1vQXKRVGbdMAN7zo6VA_ivLUPF7Tto-74F0teGMNRBtqSMavBTnQlC5ZdxqzsgkiptxSoVqJngPfYXof42VkRpAgbMbbdUeTBx0s_8z6GSbIQgl-WDw07hM1pDrG2I5MtRcAkNBpUX1kKkAUJX-8cric_L31KIxSGCzBbePBr2TYLqglXo9hGWG5yFDrWw9H2gsJ6_O-mkgjN4l_4yoS2VaG-dMC96oxAm37VI6-zmYF5FKHjrDpi7gNsUoUzQebC46RTNXlvlEOYyHFFqXabP1AL_KQl_uQL_rot_wGr4o0kxgH7Ycz0zPZQ7NWY5zi7VvOMb8j2ds8w", idToken)
            } catch {
                return XCTFail("Failed to parse operation variables: \(error)")
            }

            XCTAssertEqual("dummy_id_token", tokens.idToken)
            XCTAssertEqual("dummy_access_token", tokens.accessToken)
            XCTAssertEqual("dummy_refresh_token", tokens.refreshToken)
            XCTAssertEqual(3600, tokens.lifetime)

            do {
                guard let storedIdToken = try self.client.getIdToken(),
                      let storedAccessToken = try self.client.getAccessToken(),
                      let storedRefreshToken = try self.client.getRefreshToken(),
                      let storedTokenExpiry = try self.client.getTokenExpiry() else {
                          return XCTFail("Tokens not found.")
                      }

                XCTAssertEqual(tokens.idToken, storedIdToken)
                XCTAssertEqual(tokens.accessToken, storedAccessToken)
                XCTAssertEqual(tokens.refreshToken, storedRefreshToken)
                XCTAssertTrue(storedTokenExpiry < Date(timeIntervalSinceNow: 3600 + 10))
                XCTAssertTrue(storedTokenExpiry > Date(timeIntervalSinceNow: 3600 - 10))
            } catch {
                XCTFail("Failed to validate the result: \(error)")
            }
        } catch {
            XCTFail("Failed to register: \(error)")
        }

        self.wait(for: [observer.signedInExpectation, observer.signingInExpectation], timeout: 10)

        XCTAssertEqual("dummy_uid", self.identityProvider.uid)
        XCTAssertEqual("dummy_token", self.identityProvider.signInParameters["answer"] as? String)
        XCTAssertEqual("FSSO", self.identityProvider.signInParameters["challengeType"] as? String)
    }

    func testProcessFederatedSignInTokens() async throws {
        let url = URL(string: "https://localhost")!
        _ = try await self.client.processFederatedSignInTokens(url: url)
        XCTAssertEqual(url, self.authUI.url)
    }

    func testSignInWithRegisterFederatedIdError() async throws {
        self.transport.responseBody.append([
            "data": NSNull(),
            "errors": [
                [
                    "errorType": "sudoplatform.ServiceError",
                    "message": ""
                ]
            ]
        ])

        self.credentialsProvider.identityId = nil

        do {
            try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")

            let keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
            let userKeyId = "dummy_key_id"
            try keyManager.generateKeyPair(userKeyId)
            try keyManager.addPassword(userKeyId.data(using: .utf8)!, name: "userKeyId")

            self.identityProvider.signInResult = AuthenticationTokens(
                idToken: "eyJhbGciOiJSUzI1NiIsImtpZCI6IjVEODQ2MTBFLUYzQ0ItNDU0Mi1BQjBDLUZGQzhGODZDMEU5OSJ9.eyJqdGkiOiIxNmE0ZjhkZS1hN2M3LTQ4ZDYtYmMwZS1jMDc2NWZhMTc2NmIiLCJpc3MiOiIyMTVBMzQzOC1ENjdBLTRGMDItQjc2My0wMzA0Q0E2NDlGMTEiLCJhdWQiOiJhdWRpZW5jZSIsInN1YiI6IjIxNUEzNDM4LUQ2N0EtNEYwMi1CNzYzLTAzMDRDQTY0OUYxMSIsImlhdCI6MTU3NzkzNTA2NCwiZXhwIjoxNTc3OTM1MzY0fQ.izTHh9B8j1vQXKRVGbdMAN7zo6VA_ivLUPF7Tto-74F0teGMNRBtqSMavBTnQlC5ZdxqzsgkiptxSoVqJngPfYXof42VkRpAgbMbbdUeTBx0s_8z6GSbIQgl-WDw07hM1pDrG2I5MtRcAkNBpUX1kKkAUJX-8cric_L31KIxSGCzBbePBr2TYLqglXo9hGWG5yFDrWw9H2gsJ6_O-mkgjN4l_4yoS2VaG-dMC96oxAm37VI6-zmYF5FKHjrDpi7gNsUoUzQebC46RTNXlvlEOYyHFFqXabP1AL_KQl_uQL_rot_wGr4o0kxgH7Ycz0zPZQ7NWY5zi7VvOMb8j2ds8w",
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                lifetime: 3600,
                username: "dummy_uid"
            )

            self.identityProvider.refreshTokensResult = AuthenticationTokens(
                idToken: "dummy_id_token",
                accessToken: "dummy_access_token",
                refreshToken: "dummy_refresh_token",
                lifetime: 3600,
                username: "dummy_uid"
            )

            let tokens = try await self.client.signInWithKey()
        } catch SudoUserClientError.graphQLError {
            // Expected error.
        } catch {
            XCTFail("Failed to register: \(error)")
        }
    }

    func testResetUserDataSucceeds() async throws {
        // ensure isSignedIn succeeds
        do {
            try self.keyManager.addPassword("dummy_id_token".data(using: .utf8)!, name: "idToken")
            try self.keyManager.addPassword("dummy_access_token".data(using: .utf8)!, name: "accessToken")
            try self.keyManager.addPassword("\(Date().addingTimeInterval(3605).timeIntervalSince1970)".data(using: .utf8)!, name: "refreshTokenExpiry")
        } catch {
            XCTFail("Failed to create keychain items: \(error)")
        }

        // simulate reset mutation success
        self.transport.responseBody.append([
            "data": [
                "reset": [
                    "__typename": "reset",
                    "success": true
                ]
            ]
        ])

        try await self.client.resetUserData()
    }

    func testResetUserDataThrowsWhenNotSignedIn() async throws {
        do {
            try await self.client.resetUserData()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notSignedIn {
            // expected error
        } catch {
            XCTFail("Expected notSignedIn error, but got \(error)")
        }
    }

    func testResetUserDataThrowsWhenMutationFails() async throws {
        // ensure isSignedIn succeeds
        do {
            try self.keyManager.addPassword("dummy_id_token".data(using: .utf8)!, name: "idToken")
            try self.keyManager.addPassword("dummy_access_token".data(using: .utf8)!, name: "accessToken")
            try self.keyManager.addPassword("\(Date().addingTimeInterval(3605).timeIntervalSince1970)".data(using: .utf8)!, name: "refreshTokenExpiry")
        } catch {
            XCTFail("Failed to create keychain items: \(error)")
        }

        // simulate reset mutation error
        self.transport.responseBody.append([
            "data": NSNull(),
            "errors": [
                [
                    "errorType": "sudoplatform.ServiceError",
                    "message": ""
                ]
            ]
        ])

        do {
            try await self.client.resetUserData()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.graphQLError {
            // expected error
        } catch {
            XCTFail("Expected notSignedIn error, but got \(error)")
        }

    }
}
