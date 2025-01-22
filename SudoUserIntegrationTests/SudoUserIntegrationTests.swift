//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import SudoKeyManager
import SudoUser
@testable import TestApp

class MySignInStatusObserver: SignInStatusObserver {

    var signingInExpectation: XCTestExpectation = XCTestExpectation()
    var signedInExpectation: XCTestExpectation = XCTestExpectation()

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

class SudoUserClientIntegrationTests: XCTestCase {

    var bundle: Bundle!

    var testKeyId: String!

    var testAuthenticationProvider: TESTAuthenticationProvider!

    var configName: String = ""

    var client: SudoUserClient!

    var keyManager: SudoKeyManager!

    var config: [String: Any] = [:]

    var refreshToken: String = ""

    var registerKeyName: String = ""

    var challenge: RegistrationChallenge?

    var token: String?

    var region: String = ""

    var bucket: String = ""

    var failed: Bool {
        guard let failureCount = testRun?.failureCount else {
            return false
        }

        return failureCount > 0
    }

    var sudoId: String?

    var sudoVersion: Int?

    func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    override func setUp() async throws {
        // Ensure that we don't continue past setup if setup fails
        continueAfterFailure = false
        defer { continueAfterFailure = true }
        guard let configName = ProcessInfo.processInfo.environment["CONFIG_NAME"] else {
            return XCTFail("Config name not set in the execution environment.")
        }
        self.configName = configName
        NSLog("CONFIG_NAME: \(configName)")

        self.bundle = Bundle(for: type(of: self))

        guard let url = self.bundle.url(forResource: "sudoplatformconfig", withExtension: "json") else {
            return XCTFail("Failed to determine the URL of config file.")
        }

        guard let data = try? Data(contentsOf: url) else {
            return XCTFail("Failed to read config from file: \(url)")
        }

        guard let config = data.toJSONObject() as? [String: Any] else {
            return XCTFail("Failed to parse client config.")
        }

        self.config = config

        self.keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")

        do {
            self.client = try DefaultSudoUserClient(config: self.config, keyNamespace: "ids")
            try await self.client.reset()
        } catch {
            return XCTFail("Failed to initialize the client: \(error)")
        }

        self.registerKeyName = "register_key"

        guard let testKeyUrl = self.bundle.url(forResource: self.registerKeyName, withExtension: "private") else {
            return XCTFail("Failed to determine the URL of TEST key file.")
        }

        guard let testKey = try? String(contentsOf: testKeyUrl) else {
            return XCTFail("Failed to read TEST key from file: \(testKeyUrl)")
        }

        guard let testKeyIdUrl = self.bundle.url(forResource: self.registerKeyName, withExtension: "id") else {
            return XCTFail("Failed to determine the URL of TEST key ID file.")
        }

        guard let testKeyId = try? String(contentsOf: testKeyIdUrl).trimmingCharacters(in: .whitespacesAndNewlines) else {
            return XCTFail("Failed to read TEST key ID from file: \(testKeyIdUrl)")
        }

        self.testKeyId = testKeyId

        do {
            self.testAuthenticationProvider = try TESTAuthenticationProvider(
                name: "SudoSecureVault",
                key: testKey,
                keyId: testKeyId,
                keyManager: LegacySudoKeyManager(
                    serviceName: "com.sudoplatform.appservicename",
                    keyTag: "com.sudoplatform",
                    namespace: "test"
                ),
                customAttributes: ["custom:entitlementsSet": "dummy_entitlements_set"]
            )
        } catch {
            XCTFail("Failed to initialize TEST authentication provider: \(error)")
        }
    }

    override func tearDown() async throws {
        if try await self.client?.isRegistered() == true {
            do {
            _ = try await self.client.signInWithKey()
            } catch {
                XCTFail("Failed to sign in: \(error)")
            }

            do {
            _ = try await self.client.deregister()
            } catch {
                XCTFail("Failed to deregister: \(error)")
            }
        }

        do {
            try await self.client?.reset()
        } catch {
            XCTFail("Failed to reset the client: \(error)")
        }
    }

    func testRegister() async throws {
        guard try await !self.client.isRegistered() else {
            return
        }

        do {
            _ = try await self.client.registerWithAuthenticationProvider(authenticationProvider: self.testAuthenticationProvider, registrationId: "dummy_rid")
            let status = try await self.client.isRegistered()
            XCTAssertTrue(status)
        } catch {
            XCTFail("Failed to register: \(error)")
        }
    }
// AppSync has a version conflict with the aws package we use and SQLite, so we can't import
// the libraries we need to support this. Disabling for now till we upgrade to amplify.
    
//    func testRegisterWithDeviceCheckToken() async throws {
//        if self.configName != "gc-dev" {
//            throw XCTSkip("DeviceCheck test only runs in gc-dev environment")
//        }
//
//        let challengeTypes = self.client.getSupportedRegistrationChallengeType()
//        guard challengeTypes.contains(.deviceCheck) else {
//            throw XCTSkip("The environment does not support DeviceCheck.")
//        }
//
//        guard !self.isSimulator() else {
//            throw XCTSkip("DeviceCheck is not supported by the simulator.")
//        }
//
//        guard let appDelegate = await UIApplication.shared.delegate as? AppDelegate else {
//            return XCTFail("Failed access app delegate.")
//        }
//
//        guard let deviceCheckToken = try await appDelegate.getDeviceCheckToken() else {
//            return XCTFail("DeviceCheck token not found.")
//        }
//
//        var deviceCheckClient: DeviceCheckClient
//
//        do {
//            deviceCheckClient = try DeviceCheckClient(
//                userClient: self.client,
//                keyManager: self.keyManager
//            )
//        } catch {
//            return XCTFail("Failed to initialize device check admin api client")
//        }
//        do {
//            try await deviceCheckClient.signOut()
//        } catch {
//            NSLog("ignoring sign out failure \(error)")
//        }
//
//        let vendorId = await UIDevice.current.identifierForVendor!
//        let deviceId = vendorId.uuidString
//        guard let username = ProcessInfo.processInfo.environment["ADMIN_CONSOLE_USERNAME"] else {
//            return XCTFail("Admin Console Username is not set")
//        }
//        guard let password = ProcessInfo.processInfo.environment["ADMIN_CONSOLE_PASSWORD"] else {
//            return XCTFail("Admin Console Password is not set")
//        }
//        do {
//            try await deviceCheckClient.signIn(username: username, password: password)
//            try await deviceCheckClient.whitelistDevice(deviceId: deviceId)
//        } catch {
//            return XCTFail("could not whitelist device \(error)")
//        }
//
//        do {
//            _ = try await self.client.registerWithDeviceCheck(token: deviceCheckToken,
//                                                    buildType: "debug",
//                                                    vendorId: vendorId,
//                                                    registrationId: "dummy_rid")
//            let status = try await self.client.isRegistered()
//            XCTAssertTrue(status)
//        } catch {
//            return XCTFail("Failed to register: \(error)")
//        }
//    }

    func testSignIn() async throws {
        try await self.testRegister()

        guard !self.failed else {
            return
        }

        let observer = MySignInStatusObserver()
        await self.client.registerSignInStatusObserver(id: "dummy_id", observer: observer)

        do {
            let tokens = try await self.client.signInWithKey()
            self.refreshToken = tokens.refreshToken
            XCTAssertNotNil(tokens.idToken)
            XCTAssertNotNil(tokens.accessToken)
            XCTAssertNotNil(tokens.refreshToken)
            XCTAssertEqual(3600, tokens.lifetime)

            do {
                let status = try await self.client.isSignedIn()
                XCTAssertTrue(status)

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
                XCTAssertNotNil(try self.client.getUserClaim(name: "sub"))
                XCTAssertEqual("dummy_entitlements_set", try? self.client.getUserClaim(name: "custom:entitlementsSet") as? String)

                guard let idToken = try self.client.getIdToken() else {
                    return XCTFail("ID token not found.")
                }

                let jwt = try JWT(string: idToken, keyManager: nil)
                guard let identityId = jwt.payload["custom:identityId"] as? String else {
                    return XCTFail("Identity ID not found in the ID token.")
                }

                let storedIdentityId = await self.client.getIdentityId()
                XCTAssertEqual(identityId, storedIdentityId)
            } catch {
                XCTFail("Failed to validate the result: \(error)")
            }
        } catch {
            XCTFail("Failed to sign in: \(error)")
        }

        // TODO: change this to self.fulfillment when our gitlab runners are upgraded to >= Xcode 14.3
        self.wait(for: [observer.signingInExpectation, observer.signedInExpectation], timeout: 20)
    }

    func testSignInFailure() async throws {
        try await self.testRegister()

        guard !self.failed else {
            return
        }

        let oldKeyId: Data
        do {
            let password = try self.keyManager.getPassword("userKeyId")
            guard let data = password else {
                return XCTFail("Failed to retrieve the user key Id.")
            }

            oldKeyId = data

            try self.keyManager.deletePassword("userKeyId")
            let keyId = try self.keyManager.generateKeyId()
            try self.keyManager.generateKeyPair(keyId)
            try self.keyManager.addPassword(keyId.data(using: .utf8)!, name: "userKeyId")
        } catch {
            return XCTFail("Failed to change the user key: \(error)")
        }

        do {
            _ = try await self.client.signInWithKey()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        } catch {
            XCTFail("Failed to sign in: \(error)")
        }

        do {
            try self.keyManager.deletePassword("userKeyId")
            try self.keyManager.addPassword(oldKeyId, name: "userKeyId")
        } catch {
            return XCTFail("Failed to change the user key: \(error)")
        }
    }

    func testSignInWithExpiredToken() async throws {
        try await self.testRegister()

        guard !self.failed else {
            return
        }

        let client: SudoUserClient
        do {
            var config = self.config
            config["tokenLifetime"] = -3600
            client = try DefaultSudoUserClient(config: config, keyNamespace: "ids")
        } catch {
            return XCTFail("Failed to initialize the client: \(error)")
        }

        do {
            _ = try await client.signInWithKey()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        } catch {
            XCTFail("Failed to sign in: \(error)")
        }
    }

    func testRefreshTokens() async throws {
        try await self.testSignIn()

        guard !self.failed else {
            return
        }

        let observer = MySignInStatusObserver()
        await self.client.registerSignInStatusObserver(id: "dummy_id", observer: observer)

        do {
            let tokens = try await self.client.refreshTokens()
            XCTAssertNotNil(tokens.idToken)
            XCTAssertNotNil(tokens.accessToken)
            XCTAssertNotNil(tokens.refreshToken)
            XCTAssertEqual(3600, tokens.lifetime)
        } catch {
            XCTFail("Failed to refresh tokens: \(error)")
        }

        // TODO: change this to self.fulfillment when our gitlab runners are upgraded to >= Xcode 14.3
        self.wait(for: [observer.signingInExpectation, observer.signedInExpectation], timeout: 20)
    }

    func testRegisterBadAnswer() async throws {
        guard try await !self.client.isRegistered() else {
            return
        }

        do {
            // Remove the TEST key and generate a random key to cause the signature validation to fail.
            let keyManager = LegacySudoKeyManager(
                serviceName: "com.sudoplatform.appservicename",
                keyTag: "com.sudoplatform",
                namespace: "test"
            )

            try keyManager.deleteKeyPair(testKeyId)
            try keyManager.generateKeyPair(testKeyId)

            _ = try await self.client.registerWithAuthenticationProvider(authenticationProvider: self.testAuthenticationProvider, registrationId: "dummy_rid")
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        } catch {
            XCTFail("Failed to register: \(error)")
        }
    }

    func testGraphQLAuthProvider() async throws {
        try await self.testSignIn()

        guard !self.failed else {
            return
        }

        let expectation = self.expectation(description: "")

        let authProvider = GraphQLAuthProvider(client: self.client)
        authProvider.getLatestAuthToken { (token, error) in
            XCTAssertNotNil(token)
            XCTAssertNil(error)
            expectation.fulfill()
        }

        // TODO: change this to self.fulfillment when our gitlab runners are upgraded to >= Xcode 14.3
        self.wait(for: [expectation], timeout: 20)
    }

    func testSignOut() async throws {
        try await self.testSignIn()

        guard !self.failed else {
            return
        }

        do {
            try await self.client.signOut()
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
            XCTFail("Failed to globally sign out: \(error)")
        }

        do {
            _ = try await self.client.refreshTokens(refreshToken: self.refreshToken)
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        } catch {
            XCTFail("Failed to refresh tokens: \(error)")
        }

        try await self.testSignIn()
    }

    func testGlobalSignOut() async throws {
        try await self.testSignIn()

        guard !self.failed else {
            return
        }

        do {
            try await self.client.globalSignOut()
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
            XCTFail("Failed to globally sign out: \(error)")
        }

        do {
            _ = try await self.client.refreshTokens(refreshToken: self.refreshToken)
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        } catch {
            XCTFail("Failed to refresh tokens: \(error)")
        }

        try await self.testSignIn()
    }

    func testCustomFSSO() async throws {
        guard let keyUrl = self.bundle.url(forResource: "fsso", withExtension: "key"),
            let keyIdUrl = self.bundle.url(forResource: "fsso", withExtension: "id") else {
            throw XCTSkip("Did not find FSSO key in the test bundle.")
        }

        guard let keyData = try? Data(contentsOf: keyUrl),
            let key = String(bytes: keyData, encoding: .utf8),
            let keyIdData = try? Data(contentsOf: keyIdUrl),
            let keyId = String(bytes: keyIdData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return XCTFail("Failed to read FSSO key and key ID.")
        }

        let username = "sudouser-fsso-test-\(UUID().uuidString)"
        let keyManager = LegacySudoKeyManager(
            serviceName: "com.sudoplatform.appservicename",
            keyTag: "com.sudoplatform",
            namespace: "fsso"
        )

        let authenticationProvider: AuthenticationProvider
        do {
            authenticationProvider = try LocalAuthenticationProvider(
                name: "client_system_test_iss",
                key: key,
                keyId: keyId.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username,
                keyManager: keyManager,
                customAttributes: ["custom:entitlementsSet": "dummy_entitlements_set"]
            )
        } catch {
            return XCTFail("Failed to initialize authentication provider: \(error)")
        }

        do {
            _ = try await self.client.registerWithAuthenticationProvider(authenticationProvider: authenticationProvider, registrationId: "dummy_rid")
            let status = try await self.client.isRegistered()
            XCTAssertTrue(status)
        } catch {
            try? keyManager.removeAllKeys()
            return XCTFail("Failed to register: \(error)")
        }

        do {
            _ = try await self.client.signInWithAuthenticationProvider(authenticationProvider: authenticationProvider)
            XCTAssertEqual("dummy_entitlements_set", try? self.client.getUserClaim(name: "custom:entitlementsSet") as? String)
        } catch {
            try? keyManager.removeAllKeys()
            return XCTFail("Failed to sign in: \(error)")
        }

        do {
            _ = try await self.client.deregister()
        } catch {
            XCTFail("Failed to de-register: \(error)")
        }
    }

    func testCustomFSSODuplicateRegistration() async throws {
        guard let keyUrl = self.bundle.url(forResource: "fsso", withExtension: "key"),
            let keyIdUrl = self.bundle.url(forResource: "fsso", withExtension: "id") else {
            throw XCTSkip("Did not find FSSO key in the test bundle.")
        }

        guard let keyData = try? Data(contentsOf: keyUrl),
            let key = String(bytes: keyData, encoding: .utf8),
            let keyIdData = try? Data(contentsOf: keyIdUrl),
            let keyId = String(bytes: keyIdData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return XCTFail("Failed to read FSSO key and key ID.")
        }

        let username = "sudouser-fsso-test-\(UUID().uuidString)"
        let keyManager = LegacySudoKeyManager(
            serviceName: "com.sudoplatform.appservicename",
            keyTag: "com.sudoplatform",
            namespace: "fsso"
        )

        let authenticationProvider: AuthenticationProvider
        do {
            authenticationProvider = try LocalAuthenticationProvider(
                name: "client_system_test_iss",
                key: key,
                keyId: keyId.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username,
                keyManager: keyManager,
                customAttributes: ["custom:entitlementsSet": "dummy_entitlements_set"]
            )
        } catch {
            return XCTFail("Failed to initialize authentication provider: \(error)")
        }

        do {
            _ = try await self.client.registerWithAuthenticationProvider(authenticationProvider: authenticationProvider, registrationId: "dummy_rid")
            let status = try await self.client.isRegistered()
            XCTAssertTrue(status)
        } catch {
            try? keyManager.removeAllKeys()
            return XCTFail("Failed to register: \(error)")
        }

        do {
            try await self.client.reset()
            _ = try await self.client.registerWithAuthenticationProvider(authenticationProvider: try LocalAuthenticationProvider(
                name: "client_system_test_iss",
                key: key,
                keyId: keyId.trimmingCharacters(in: .whitespacesAndNewlines),
                username: username,
                keyManager: keyManager
            ), registrationId: "dummy_rid")
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.alreadyRegistered {
            // Expected error thrown.
        } catch {
            try? keyManager.removeAllKeys()
            return XCTFail("Failed to register: \(error)")
        }

        try await self.client.setUserName(name: username)

        do {
            _ = try await self.client.signInWithAuthenticationProvider(authenticationProvider: authenticationProvider)
            XCTAssertEqual("dummy_entitlements_set", try? self.client.getUserClaim(name: "custom:entitlementsSet") as? String)
        } catch {
            try? keyManager.removeAllKeys()
            return XCTFail("Failed to sign in: \(error)")
        }

        do {
            _ = try await self.client.deregister()
        } catch {
            XCTFail("Failed to de-register: \(error)")
        }
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

    func testRestUserDataSucceeds() async throws {
        try await self.testRegister()
        _ = try await self.client.signInWithKey()
        let username = try self.client.getUserName()

        do {
            try await self.client.resetUserData()
            let isSignedIn = try await self.client.isSignedIn()
            XCTAssertTrue(isSignedIn)
            let isRegistered = try await self.client.isRegistered()
            XCTAssertTrue(isRegistered)
        } catch {
            XCTFail("expected success but got error \(error)")
        }
    }
}
