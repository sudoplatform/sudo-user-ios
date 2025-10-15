//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import Amplify
import XCTest
import SudoKeyManager
@testable import SudoUser

class SudoUserClientIntegrationTests: XCTestCase {

    // MARK: - Properties

    var config: [String: Any] = [:]
    var testKeyId: String!
    var testKeyManager: LegacySudoKeyManager!
    var testAuthenticationProvider: TESTAuthenticationProvider!
    var fssoKeyManager: LegacySudoKeyManager!
    var client: DefaultSudoUserClient!

    // MARK: - Lifecycle

    override func setUp() async throws {
        guard
            let url = Bundle.main.url(forResource: "sudoplatformconfig", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let config = data.toJSONObject() as? [String: Any]
        else {
            throw SudoUserClientError.invalidConfig
        }
        self.config = config
        guard
            let testKeyUrl = Bundle.main.url(forResource: "register_key", withExtension: "private"),
            let testKey = try? String(contentsOf: testKeyUrl),
            let testKeyIdUrl = Bundle.main.url(forResource: "register_key", withExtension: "id"),
            let testKeyId = try? String(contentsOf: testKeyIdUrl).trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            throw SudoUserClientError.fatalError(description: "Failed to get test key from bundle")
        }
        self.testKeyId = testKeyId
        await resetAmplify()
        client = try DefaultSudoUserClient(config: config, keyNamespace: "ids")
        await resetClient()
        testKeyManager = LegacySudoKeyManager(
            serviceName: "com.sudoplatform.appservicename",
            keyTag: "com.sudoplatform",
            namespace: "test"
        )
        testAuthenticationProvider = try TESTAuthenticationProvider(
            name: "SudoUser",
            key: testKey,
            keyId: testKeyId,
            keyManager: testKeyManager,
            customAttributes: ["custom:entitlementsSet": "dummy_entitlements_set"]
        )
        fssoKeyManager = LegacySudoKeyManager(
            serviceName: "com.sudoplatform.appservicename",
            keyTag: "com.sudoplatform",
            namespace: "fsso"
        )
    }

    override func tearDown() async throws {
        await resetClient()
        await resetAmplify()
    }

    // MARK: - Tests

    func test_register_willSucceed() async throws {
        // when
        _ = try await client.registerWithAuthenticationProvider(
            authenticationProvider: testAuthenticationProvider,
            registrationId: "dummy_rid"
        )
        // then
        let status = try await client.isRegistered()
        XCTAssertTrue(status)
    }

    func test_register_withInvalidKey_willThrowNotAuthorizedError() async throws {
        // given
        // Remove the TEST key and generate a random key to cause the signature validation to fail.
        try testKeyManager.deleteKeyPair(testKeyId)
        try testKeyManager.generateKeyPair(testKeyId)
        do {
            _ = try await client.registerWithAuthenticationProvider(
                authenticationProvider: testAuthenticationProvider,
                registrationId: "dummy_rid"
            )
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        }
    }

    func test_signIn_withInvalidTestRegistrationData_willParseAndThrowServiceError() async throws {
        // given
        class BadAuthenticationInfo: AuthenticationInfo {

            let type: String = "TEST"

            func isValid() -> Bool {
                return true
            }

            func toString() -> String {
                return UUID().uuidString
            }

            func getUsername() -> String {
                return UUID().uuidString
            }
        }
        class BadAuthenticationProvider: AuthenticationProvider {

            func getAuthenticationInfo() async throws -> any SudoUser.AuthenticationInfo {
                BadAuthenticationInfo()
            }

            func reset() {
                // no-op
            }
        }
        let badAuthenticationProvider = BadAuthenticationProvider()
        // when
        do {
            _ = try await client.registerWithAuthenticationProvider(authenticationProvider: badAuthenticationProvider, registrationId: nil)
            XCTFail("Should not succeed")
        } catch SudoUserClientError.notAuthorized {
            // expected error
        }
    }

    func test_signIn_willSucceed() async throws {
        // given
        try await register()
        let observer = SignInStatusObserverMock()
        await client.registerSignInStatusObserver(id: "dummy_id", observer: observer)
        // when
        let tokens = try await client.signInWithKey()
        // then
        XCTAssertNotNil(tokens.idToken)
        XCTAssertNotNil(tokens.accessToken)
        XCTAssertNotNil(tokens.refreshToken)

        let status = try await client.isSignedIn()
        XCTAssertTrue(status)

        let storedIdToken = try await client.getIdToken()
        let storedAccessToken = try await client.getAccessToken()
        let storedRefreshToken = try await client.getRefreshToken()

        XCTAssertEqual(tokens.idToken, storedIdToken)
        XCTAssertEqual(tokens.accessToken, storedAccessToken)
        XCTAssertEqual(tokens.refreshToken, storedRefreshToken)

        let sub = try await client.getUserClaim(name: "sub")
        XCTAssertNotNil(sub)
        let entitlementsSet = try? await client.getUserClaim(name: "custom:entitlementsSet") as? String
        XCTAssertEqual("dummy_entitlements_set", entitlementsSet)

        let idToken = try await client.getIdToken()
        let jwt = try JWT(string: idToken, keyManager: nil)
        let identityId = try XCTUnwrap(jwt.payload["custom:identityId"] as? String)
        let storedIdentityId = try await client.getIdentityId()
        XCTAssertEqual(identityId, storedIdentityId)
        await fulfillment(of: [observer.signingInExpectation, observer.signedInExpectation], timeout: 20)
    }

    func test_signIn_withInvalidKey_willThrowNotAuthorizedError() async throws {
        // given
        try await register()
        try client.keyManager.deletePassword("userKeyId")
        let keyId = try client.keyManager.generateKeyId()
        try client.keyManager.generateKeyPair(keyId)
        try client.keyManager.addPassword(keyId.data(using: .utf8)!, name: "userKeyId")
        do {
            _ = try await client.signInWithKey()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        }
    }

    func test_signIn_withExpiredToken_willThrowNotAuthorizedError() async throws {
        // given
        client.signInTokenLifetime = TimeInterval(-3600)
        try await register()
        do {
            // when
            _ = try await client.signInWithKey()
            // then
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notAuthorized {
            // Expected error thrown.
        }
    }

    func test_isSignedIn_withUnregisteredUser_willReturnFalse() async throws {
        // when
        let result = try await client.isSignedIn()
        // then
        XCTAssertFalse(result)
    }

    func test_isSignedIn_withRegisteredUserNotSignedIn_willReturnFalse() async throws {
        // given
        try await register()
        // when
        let result = try await client.isSignedIn()
        // then
        XCTAssertFalse(result)
    }

    func test_isSignedIn_withSignInUser_willReturnTrue() async throws {
        // given
        try await register()
        _ = try await client.signInWithKey()
        // when
        let result = try await client.isSignedIn()
        // then
        XCTAssertTrue(result)
    }

    func test_refreshTokens_willReturnUpdatedTokens_andNotifyObserver() async throws {
        // given
        try await register()
        _ = try await client.signInWithKey()
        let observer = SignInStatusObserverMock()
        await client.registerSignInStatusObserver(id: "dummy_id", observer: observer)
        // when
        let tokens = try await client.refreshTokens()
        // then
        XCTAssertNotNil(tokens.idToken)
        XCTAssertNotNil(tokens.accessToken)
        XCTAssertNotNil(tokens.refreshToken)
        await fulfillment(of: [observer.signingInExpectation, observer.signedInExpectation], timeout: 20)
    }

    func test_signOut_willClearAuthTokens() async throws {
        // given
        try await register()
        _ = try await client.signInWithKey()
        // when
        try await client.signOut()
        // then
        let idToken = try? await client.getIdToken()
        let accessToken = try? await client.getAccessToken()
        let refreshToken = try? await client.getRefreshToken()
        XCTAssertNil(idToken)
        XCTAssertNil(accessToken)
        XCTAssertNil(refreshToken)
        do {
            _ = try await client.refreshTokens()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notSignedIn {
            // Expected error thrown.
        } catch {
            XCTFail("Failed to refresh tokens: \(error)")
        }
        _ = try await client.signInWithKey()
    }

    func test_signOut_whenRegistered_whenNotSignedIn_willSucceed() async throws {
        // given
        try await register()
        // when
        try await client.signOut()
        // then
        let isSignedIn = try await client.isSignedIn()
        XCTAssertFalse(isSignedIn)
    }

    func test_signOut_whenNotRegistered_willSucceed() async throws {
        // when
        try await client.signOut()
        // then
        let isSignedIn = try await client.isSignedIn()
        XCTAssertFalse(isSignedIn)
    }

    func test_globalSignOut_willClearAuthTokens() async throws {
        // given
        try await register()
        _ = try await client.signInWithKey()
        // when
        try await client.globalSignOut()
        // then
        let idToken = try? await client.getIdToken()
        let accessToken = try? await client.getAccessToken()
        let refreshToken = try? await client.getRefreshToken()
        XCTAssertNil(idToken)
        XCTAssertNil(accessToken)
        XCTAssertNil(refreshToken)
        do {
            _ = try await client.refreshTokens()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notSignedIn {
            // Expected error thrown.
        }
        _ = try await client.signInWithKey()
    }

    func test_customFSSO_willSucceed() async throws {
        // given
        guard let (key, keyId) = getFSSOKeyPair() else {
            throw XCTSkip("Did not find FSSO key in the test bundle.")
        }
        let username = "sudouser-fsso-test-\(UUID().uuidString)"
        let authenticationProvider = try LocalAuthenticationProvider(
            name: "client_system_test_iss",
            key: key,
            keyId: keyId.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username,
            keyManager: fssoKeyManager,
            customAttributes: ["custom:entitlementsSet": "dummy_entitlements_set"]
        )
        // when
        _ = try await client.registerWithAuthenticationProvider(
            authenticationProvider: authenticationProvider,
            registrationId: "dummy_rid"
        )
        _ = try await client.signInWithAuthenticationProvider(authenticationProvider: authenticationProvider)
        // then
        let status = try await client.isRegistered()
        XCTAssertTrue(status)
        let entitlementsSet = try? await client.getUserClaim(name: "custom:entitlementsSet") as? String
        XCTAssertEqual("dummy_entitlements_set", entitlementsSet)
        _ = try await client.deregister()
    }

    func test_customFSSO_withDuplicateRegistration_willThrowAlreadyRegisteredError() async throws {
        // given
        guard let (key, keyId) = getFSSOKeyPair() else {
            throw XCTSkip("Did not find FSSO key in the test bundle.")
        }
        let username = "sudouser-fsso-test-\(UUID().uuidString)"
        let authenticationProvider = try LocalAuthenticationProvider(
            name: "client_system_test_iss",
            key: key,
            keyId: keyId.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username,
            keyManager: fssoKeyManager,
            customAttributes: ["custom:entitlementsSet": "dummy_entitlements_set"]
        )
        _ = try await client.registerWithAuthenticationProvider(authenticationProvider: authenticationProvider, registrationId: "dummy_rid")
        let status = try await client.isRegistered()
        XCTAssertTrue(status)
        try await client.reset()
        let duplicatedAuthenticationProvider = try LocalAuthenticationProvider(
            name: "client_system_test_iss",
            key: key,
            keyId: keyId.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username,
            keyManager: fssoKeyManager
        )
        // when
        do {
            _ = try await client.registerWithAuthenticationProvider(
                authenticationProvider: duplicatedAuthenticationProvider,
                registrationId: "dummy_rid"
            )
            // then
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.alreadyRegistered {
            // Expected error thrown.
        }
        _ = try await client.signInWithAuthenticationProvider(authenticationProvider: authenticationProvider)
        let entitlementsSet = try? await client.getUserClaim(name: "custom:entitlementsSet") as? String
        XCTAssertEqual("dummy_entitlements_set", entitlementsSet)
        _ = try await client.deregister()
    }

    func test_resetUserData_whenNotSignedIn_willThrowNotSignedInError() async throws {
        do {
            try await client.resetUserData()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notSignedIn {
            // expected error
        }
    }

    func test_resetUserData_whenSignedIn_willSucceed() async throws {
        // given
        try await register()
        _ = try await client.signInWithKey()
        _ = try await client.getUserName()
        // when
        try await client.resetUserData()
        // then
        let isSignedIn = try await client.isSignedIn()
        let isRegistered = try await client.isRegistered()
        XCTAssertTrue(isSignedIn)
        XCTAssertTrue(isRegistered)
    }

    // MARK: - Helpers

    func resetAmplify() async {
        if Amplify.Auth.isConfigured {
            _ = await Amplify.Auth.signOut()
        }
        await Amplify.reset()
    }

    func resetClient() async {
        try? fssoKeyManager?.removeAllKeys()
        _ = try? await client?.deregister()
        try? await client?.reset()
    }

    func register() async throws {
        _ = try await client.registerWithAuthenticationProvider(
            authenticationProvider: testAuthenticationProvider,
            registrationId: "dummy_rid"
        )
    }

    func getFSSOKeyPair() -> (key: String, keyId: String)? {
        guard
            let keyUrl = Bundle.main.url(forResource: "fsso", withExtension: "key"),
            let keyIdUrl = Bundle.main.url(forResource: "fsso", withExtension: "id"),
            let keyData = try? Data(contentsOf: keyUrl),
            let key = String(bytes: keyData, encoding: .utf8),
            let keyIdData = try? Data(contentsOf: keyIdUrl),
            let keyId = String(bytes: keyIdData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        else {
            return nil
        }
        return (key, keyId)
    }
}
