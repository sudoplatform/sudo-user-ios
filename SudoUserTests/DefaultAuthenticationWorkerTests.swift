//
// Copyright © 2025 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//
import XCTest
import Amplify
import AWSCognitoAuthPlugin
import SudoLogging
@testable import SudoUser

final class DefaultAuthenticationWorkerTests: XCTestCase {

    var authPlugin: AWSAuthPluginAdapterMock!
    var errorTransformerSpy: SudoUserClientErrorTransformerSpy = SudoUserClientErrorTransformerSpy()
    var instance: DefaultAuthenticationWorker!

    override func setUp() async throws {
        authPlugin = AWSAuthPluginAdapterMock()
        instance = DefaultAuthenticationWorker(
            keyManager: MockKeyManager(),
            authPlugin: authPlugin,
            passwordGenerator: DefaultPasswordGenerator(),
            logger: Logger.sudoUserLogger,
            errorTransformer: errorTransformerSpy
            )
    }

    func testFetchAuthTokensReturnsAuthSessionWhenSignedIn() async throws {
        authPlugin.authSession.isSignedIn = true
        let tokens = try await instance.fetchAuthTokens(forceRefresh: true)
        XCTAssertEqual(tokens.idToken, try authPlugin.authSession.userPoolTokensResult.get().idToken)
        XCTAssertEqual(tokens.accessToken, try authPlugin.authSession.userPoolTokensResult.get().accessToken)
        XCTAssertEqual(tokens.refreshToken, try authPlugin.authSession.userPoolTokensResult.get().refreshToken)
    }

    func testFetchAuthTokens_authSessionFailure_throwsError() async throws {
        authPlugin.fetchAuthSessionError = SudoUserClientError.alreadyRegistered // any error
        do {
            _ = try await instance.fetchAuthTokens(forceRefresh: true)
            XCTFail("should not run")
        } catch {
            XCTAssertEqual(
                errorTransformerSpy.tranformInput?.localizedDescription,
                SudoUserClientError.alreadyRegistered.localizedDescription
            )
            XCTAssertEqual(errorTransformerSpy.transformCallCount, 1)
        }
    }

    func testFetchAuthTokens_userPoolTokensResult_transformsError() async throws {
        authPlugin.authSession.isSignedIn = true
        let expectedError = AuthError.service("no phone", "no secret", nil)
        authPlugin.authSession.userPoolTokensResult = .failure(expectedError)
        do {
            _ = try await instance.fetchAuthTokens(forceRefresh: true)
            XCTFail("should not run")
        } catch {
            XCTAssertEqual(
                errorTransformerSpy.tranformInput?.localizedDescription,
                expectedError.localizedDescription
            )
            XCTAssertEqual(errorTransformerSpy.transformCallCount, 1)
        }
    }
}
