//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import Amplify
import AuthenticationServices
import SudoKeyManager
import SudoLogging
@testable import SudoUser
import XCTest

class SudoUserClientTests: XCTestCase {

    // MARK: - Properties

    var client: DefaultSudoUserClient!
    var keyManager: SudoKeyManager!
    var authenticationWorker: AuthenticationWorkerMock!
    var graphQLClient: GraphQLClientMock!
    let config = [
        "identityService": [
            "region": "us-east-1",
            "poolId": "us-east-1_mhy3BrqZd",
            "poolName": "IdentityUserPool",
            "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
            "refreshTokenLifetime": 10,
            "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
            "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
            "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4",
            "registrationMethods": ["TEST", "DEVICE_CHECK", "SAFETY_NET"]
        ],
        "sudoService": [
            "region": "us-west-2",
            "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
            "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"
        ],
        "federatedSignIn": [
            "appClientId": "2hrq71fef6fu4bcgnme4qp9qqg",
            "signInRedirectUri": "com.anonyome.mysudo-dev://",
            "signOutRedirectUri": "com.anonyome.mysudo-dev://",
            "refreshTokenLifetime": 20,
            "webDomain": "ssotest008.auth.us-west-2.amazoncognito.com"
        ]
    ]
    let idToken =         "eyJraWQiOiJPcndoSVlTRjU3Wm5tNmllanhBREhucGVrYXZDTEF1OWZ4RGNDdk91RDhZPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI1ZjliMWIwMy00ZDdlLTRmNzItODQ3OS1kZTdhNjJlYjAwMjEiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV85c0tzdUVhTXgiLCJjb2duaXRvOnVzZXJuYW1lIjoiU3Vkb1NlY3VyZVZhdWx0LUE0QjY1NDE5LUQxRUEtNEIzQy1CRkM1LTYyMUE5RkJBQkUyQyIsIm9yaWdpbl9qdGkiOiI2NGUxZmI4Ny01ZDRhLTQ1MzktODY1Ni1lMWU5MTExMDFkYzkiLCJjdXN0b206dXNlclR5cGUiOiJURVNUIiwiYXVkIjoiN3U1dmZmamJpa20xNXYxbGpxaHE0MXZlMDQiLCJjdXN0b206ZW50aXRsZW1lbnRzU2V0IjoiZHVtbXlfZW50aXRsZW1lbnRzX3NldCIsImV2ZW50X2lkIjoiNjI0MzcwMzktZjM4My00NDkyLTg5NjYtYzkzOGEzN2Y4Yjk0IiwiY3VzdG9tOnJlZ2lzdHJhdGlvbktpZCI6IjU4Y2E0N2E1LTc5NDUtNDVlMS04NDU5LWRmZGUzM2JhNmIxNyIsImN1c3RvbTpvZ19zdWIiOiI1ZjliMWIwMy00ZDdlLTRmNzItODQ3OS1kZTdhNjJlYjAwMjEiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTczOTkyNTc4NSwiZXhwIjoxNzM5OTI5Mzg0LCJpYXQiOjE3Mzk5MjU3ODUsImp0aSI6ImQyMmQ2YWFjLWI1ZjgtNDBkNC1hZDg2LTY2ZDc1MTk0ZWJkYSJ9.ZjJrFqPZkC6JP7vF2TOdSPoUB1dX238zlePtsi9m8GK31i7qZSxDolm7TGmpSC-jYY41vpZhDblUbikSclmr_dhTAmszxgne9GF8LkzW1Je2ca_wV0NQ64G3DmE27A8E8GP0mcU7jaZ8KucCxLzzJhry8KC4qdroGlib9yZ6RcSg6pCbSVBOB67yeqjKQCiTvV8UHnvQYhKUElI_PhEaQbiDAhQV4J4Fw8gcMBUwvilcdjFJj043at2nkkEoVaDV_J8OCP7_akIM3NUlGXInMBCT_hWi1xIhMT6ySY9ndLMucD333nSC0sVwZehOVUMnujnhxgI2P3sNDvLrwOs2AQ"
    let idTokenWithIdentityIdClaim = "eyJraWQiOiJYOUhRWUFhQnhmNzY1Q0RKWlgrUjh6Vnd0SnFiNDdcL2JSK0M4UWZzK0RaQT0iLCJhbGciOiJSUzI1NiJ9.eyJzdWIiOiIyYjQ0ZTJhMy00MTI1LTQ1ZTUtOTYwMi02MmIxYzI5ZTNjMTMiLCJhdWQiOiIzdWw0Z3Q1aWxkNTA4c29lZjdodnJmdDl2ZyIsImV2ZW50X2lkIjoiNjZjZGNhNGEtZTE2ZC00N2M5LWE0OTctZmI5NjJiOGJiMzg1IiwidG9rZW5fdXNlIjoiaWQiLCJhdXRoX3RpbWUiOjE1NzU1MDI1NTYsImlzcyI6Imh0dHBzOlwvXC9jb2duaXRvLWlkcC51cy13ZXN0LTIuYW1hem9uYXdzLmNvbVwvdXMtd2VzdC0yX24xRXp4ZzVWaiIsImNvZ25pdG86dXNlcm5hbWUiOiIxRTcyRUEwMS04MEI2LTQ1MEQtOTkzNS0wNEU2RDJBQ0E0OTYiLCJleHAiOjE1NzU1MDYxNTYsImlhdCI6MTU3NTUwMjU1Nn0.k1K5uAy5_toVahHHfM3bZnRtYK7IEwyGHyIcRfvav82dsEn_e4brM0u3O78OvHrdIleHuNZzcEf2FYyi9u0Kq3b4Eo8EZEdTEkKUiVT_RDUgPG-WYn5ZWNt3k1iYd6bEKy9Pt4Gpm2JhQnlhV_VAc1RY41G7Rfc4gGXWkU8dU62wqYFB1ZWI7WKP97dZ4Fcz5MAA_Nig0jDhkSB0nFX95srnvqWbp9p6mbo-Z-Zw44wADYT6suijofE_uSacuiLtzPoBkbW3sZah_1vSOJCLA1qU45wsZskeGIHb_DgOzvrePM-famPXi9D_p8UxRLQaewhK-ZZInE0CTan4_Zh2Hw"


    // MARK: - Lifecycle

    override func setUp() async throws {
        keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
        authenticationWorker = AuthenticationWorkerMock()
        graphQLClient = GraphQLClientMock()
        await resetAmplify()
        client = try DefaultSudoUserClient(config: config, keyNamespace: "ids")
        client.graphQLClient = graphQLClient
        client.authenticationWorker = authenticationWorker
        try await client.reset()
    }

    // MARK: - Tests

    func test_init_withMissingIdentityServiceConfig_willThrowError() async throws {
        await Amplify.reset()
        do {
            _ = try DefaultSudoUserClient(config: [:], keyNamespace: "ids")
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.identityServiceConfigNotFound {
            // Expected error caught.
        }
    }

    func test_init_withDefaultParameters_willSucceed() async throws {
        await Amplify.reset()
        _ = try DefaultSudoUserClient(keyNamespace: "ids", logger: nil)
    }

    func test_init_withConfigProvided_willSucceed() async throws {
        await Amplify.reset()
        _ = try DefaultSudoUserClient(
            config: [
                "identityService": [
                    "region": "us-east-1",
                    "poolId": "us-east-1_mhy3BrqZd",
                    "poolName": "IdentityUserPool",
                    "clientId": "4lqrlghcsb95q0a2gc0cc1d0p0",
                    "identityPoolId": "us-west-2:63c3cc9d-aa5a-4b02-a61e-4c17a87c8313",
                    "apiUrl": "https://2ybgaxwnsbhm7jtbfxa2lhksb4.appsync-api.us-west-2.amazonaws.com/graphql",
                    "apiKey": "da2-ch4vbuirebdd5juckl3ghf5zh4"
                ]
            ],
            keyNamespace: "ids"
        )
    }

    func test_reset() async throws {
        // given
        try keyManager.generateSymmetricKey("symmetrickey")
        try keyManager.generateKeyPair("userKeyId")
        try keyManager.generateKeyPair("accountKeyId")
        try keyManager.generateKeyPair("deviceCollectionKeyId")
        try keyManager.addPassword("userKeyId".data(using: String.Encoding.utf8)!, name: "userKeyId")
        try keyManager.addPassword("accountKeyId".data(using: String.Encoding.utf8)!, name: "accountKeyId")
        try keyManager.addPassword("deviceCollectionKeyId".data(using: String.Encoding.utf8)!, name: "deviceCollectionKeyId")
        try keyManager.addPassword("uid".data(using: String.Encoding.utf8)!, name: "uid")
        try keyManager.addPassword("accountId".data(using: String.Encoding.utf8)!, name: "accountId")
        try keyManager.addPassword("deviceCollectionId".data(using: String.Encoding.utf8)!, name: "deviceCollectionId")
        // when
        try await client.reset()
        // then
        XCTAssertNil(try keyManager.getPrivateKey("userKeyId"))
        XCTAssertNil(try keyManager.getPublicKey("userKeyId"))
        XCTAssertNil(try keyManager.getPrivateKey("accountKeyId"))
        XCTAssertNil(try keyManager.getPublicKey("accountKeyId"))
        XCTAssertNil(try keyManager.getPrivateKey("deviceCollectionKeyId"))
        XCTAssertNil(try keyManager.getPublicKey("deviceCollectionKeyId"))
        XCTAssertNil(try keyManager.getPassword("userKeyId"))
        XCTAssertNil(try keyManager.getPassword("accountKeyId"))
        XCTAssertNil(try keyManager.getPassword("deviceCollectionKeyId"))
        XCTAssertNil(try keyManager.getPassword("uid"))
        XCTAssertNil(try keyManager.getPassword("accountId"))
        XCTAssertNil(try keyManager.getPassword("deviceCollectionId"))
        XCTAssertNil(try keyManager.getSymmetricKey("symmetrickey"))
    }

    func test_register() async throws {
        // given
        let challenge = RegistrationChallenge()
        challenge.type = .deviceCheck
        challenge.answer = "dummy_nonce"
        challenge.expiry = Date(timeIntervalSinceNow: 3600)
        let vendorId = UUID()
        authenticationWorker.registerResult = .success("dummy_uid")
        // when
        _ = try await client.registerWithDeviceCheck(
            token: "dummy_token".data(using: .utf8)!,
            buildType: "debug",
            vendorId: vendorId,
            registrationId: "dummy_rid"
        )
        let status = try await client.isRegistered()
        let username = try await client.getUserName()
        XCTAssertTrue(status)
        XCTAssertEqual("dummy_uid", username)

        XCTAssertEqual("DEVICE_CHECK", authenticationWorker.registerParameters?.parameters["challengeType"] as? String)
        XCTAssertEqual(
            "dummy_token".data(using: .utf8)!.base64EncodedString(),
            authenticationWorker.registerParameters?.parameters["answer"] as? String
        )
        XCTAssertEqual("dummy_rid", authenticationWorker.registerParameters?.parameters["registrationId"] as? String)

        let data = withUnsafePointer(to: vendorId.uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: vendorId.uuid))
        }
        XCTAssertEqual(data.base64EncodedString(), authenticationWorker.registerParameters?.parameters["deviceId"] as? String)
    }

    func test_deregister() async throws {
        // given
        graphQLClient.mutateResult = .success(DeregisterMutation.Data())
        try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")
        // when
        _ = try await client.deregister()
        // then
        let status = try await client.isRegistered()
        XCTAssertFalse(status)
    }

    func test_signIn_withAuthenticationWorkerSuccess_andRegisterFederatedIdSuccess_willSucceed() async throws {
        // given
        let observer = SignInStatusObserverMock()
        await client.registerSignInStatusObserver(id: "dummy_id", observer: observer)
        graphQLClient.mutateResult = .success(RegisterFederatedIdMutation.Data())
        let tokens = AuthenticationTokens(
            idToken: idToken,
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token"
        )
        authenticationWorker.signInResult = .success(tokens)
        authenticationWorker.refreshTokensResult = .success(tokens)
        authenticationWorker.getAuthTokensResult = .success(tokens)
        authenticationWorker.getIsSignedInResult = .success(false)
        try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")
        let keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
        let userKeyId = "dummy_key_id"
        try keyManager.generateKeyPair(userKeyId)
        try keyManager.addPassword(userKeyId.data(using: .utf8)!, name: "userKeyId")
        // when
        let result = try await client.signInWithKey()
        // then
        XCTAssertTrue(authenticationWorker.signInCalled)
        XCTAssertTrue(graphQLClient.mutateCalled)
        let mutation = try XCTUnwrap(graphQLClient.mutateParameters?.mutation as? RegisterFederatedIdMutation)
        XCTAssertEqual(idToken, mutation.input?.idToken)
        XCTAssertEqual(idToken, result.idToken)
        XCTAssertEqual("dummy_access_token", result.accessToken)
        XCTAssertEqual("dummy_refresh_token", result.refreshToken)
        XCTAssertTrue(authenticationWorker.refreshTokensCalled)
        await fulfillment(of: [observer.signedInExpectation, observer.signingInExpectation], timeout: 10)
    }

    func test_signIn_withDuplicateMethodCalls_willThrowAlreadyInProgressError() async throws {
        // given
        authenticationWorker.signInResultDelay = 1
        graphQLClient.mutateResult = .success(RegisterFederatedIdMutation.Data())
        let tokens = AuthenticationTokens(
            idToken: idToken,
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token"
        )
        authenticationWorker.signInResult = .success(tokens)
        authenticationWorker.refreshTokensResult = .success(tokens)
        authenticationWorker.getAuthTokensResult = .success(tokens)
        authenticationWorker.getIsSignedInResult = .success(false)
        try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")
        let keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
        let userKeyId = "dummy_key_id"
        try keyManager.generateKeyPair(userKeyId)
        try keyManager.addPassword(userKeyId.data(using: .utf8)!, name: "userKeyId")
        // when
        do {
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    _ = try await self.client.signInWithKey()
                }
                taskGroup.addTask {
                    _ = try await self.client.signInWithKey()
                }
                try await taskGroup.waitForAll()
            }
        } catch SudoUserClientError.signInOperationAlreadyInProgress {
            // Expected error thrown.
        } catch {
            XCTFail("Unexpected error returned by signIn API: \(error)")
        }
    }

    func test_refreshTokens_withAuthenticationWorkerRefreshSuccess_willNotifySignInStatusObservers() async throws {
        // given
        let observer = SignInStatusObserverMock()
        await client.registerSignInStatusObserver(id: "dummy_id", observer: observer)
        let tokens = AuthenticationTokens(
            idToken: "dummy_id_token",
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token"
        )
        authenticationWorker.refreshTokensResult = .success(tokens)
        try keyManager.addPassword("dummy_refresh_token".data(using: .utf8)!, name: "refreshToken")
        // when
        let tokensResult = try await client.refreshTokens()
        // then
        XCTAssertEqual(tokensResult, tokens)
        await fulfillment(of: [observer.signingInExpectation, observer.signedInExpectation], timeout: 10)
    }

    func test_refreshTokens_withDuplicateMethodCalls_willThrowAlreadyInProgressError() async throws {
        // given
        authenticationWorker.refreshResultDelay = 1
        // when
        do {
            try await withThrowingTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    _ = try await self.client.refreshTokens()
                }
                taskGroup.addTask {
                    _ = try await self.client.refreshTokens()
                }
                try await taskGroup.waitForAll()
            }
        } catch SudoUserClientError.refreshTokensOperationAlreadyInProgress {
            // Expected error thrown.
        } catch {
            XCTFail("Unexpected error returned by refresh API: \(error)")
        }
    }

    func test_signOut_withAuthenticationWorkerSuccess_willSucceed() async throws {
        // given
        authenticationWorker.signOutResult = .success(())
        // when
        try await client.signOut()
        // then
        XCTAssertTrue(authenticationWorker.signOutCalled)
    }

    func test_signOut_withAuthenticationWorkerFailure_willThrowError() async throws {
        // given
        authenticationWorker.signOutResult = .failure(SudoUserClientError.notAuthorized)
        // when
        do {
            try await client.signOut()
            // then
        } catch SudoUserClientError.notAuthorized {
            // expected error caught
        }
    }

    func test_globalSignOut_willTriggerGlobalSignOutMutation_andCallAuthenticationWorker() async throws {
        // given
        graphQLClient.mutateResult = .success(GlobalSignOutMutation.Data())
        authenticationWorker.signOutResult = .success(())
        // when
        try await client.globalSignOut()
        // then
        XCTAssertTrue(graphQLClient.mutateCalled)
        XCTAssertTrue(graphQLClient.mutateParameters?.mutation is GlobalSignOutMutation)
        XCTAssertTrue(authenticationWorker.signOutCalled)
    }

    @MainActor
    func test_presentFederatedSignInUI_withAuthUISuccess_willPersistUsernameAndRegisterFederatedId() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(false)
        graphQLClient.mutateResult = .success(RegisterFederatedIdMutation.Data())
        let tokens = AuthenticationTokens(
            idToken: idToken,
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token"
        )
        authenticationWorker.federatedSignInResult = .success(tokens)
        authenticationWorker.refreshTokensResult = .success(tokens)
        authenticationWorker.getAuthTokensResult = .success(tokens)
        let username = UUID().uuidString
        authenticationWorker.getUsernameResult = .success(username)
        // when
        let result = try await client.presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor())
        // then
        let mutation = try XCTUnwrap(graphQLClient.mutateParameters?.mutation as? RegisterFederatedIdMutation)
        XCTAssertEqual(idToken, mutation.input?.idToken)
        let persistedUsername = try await client.clientStateActor.getUserName()
        XCTAssertEqual(persistedUsername, username)
        XCTAssertEqual(result, tokens)
    }

    @MainActor
    func test_presentFederatedSignInUI_withAuthUIFailure_willThrowError() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(false)
        let signInError = SudoUserClientError.identityNotConfirmed
        authenticationWorker.federatedSignInResult = .failure(signInError)
        // when
        do {
            _ = try await client.presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor())
            // then
            XCTFail("Sign in should not succeed")
        } catch SudoUserClientError.identityNotConfirmed {
            // Expected error received
        }
    }

    @MainActor
    func test_presentFederatedSignInUI_withAlreadySignedIn_willThrowError() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(true)
        // when
        do {
            _ = try await client.presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor())
            // then
            XCTFail("Sign in should not succeed")
        } catch SudoUserClientError.alreadySignedIn {
            // Expected error received
        }
    }

    @MainActor
    func test_presentFederatedSignInUI_whenNotSignedIn_willCallAuthenticationWorker() async {
        // given
        authenticationWorker.getIsSignedInResult = .success(false)
        let preferPrivateSession = false
        let presentationAnchor = ASPresentationAnchor()
        // when
        _ = try? await client.presentFederatedSignInUI(presentationAnchor: presentationAnchor, preferPrivateSession: preferPrivateSession)
        // then
        XCTAssertTrue(authenticationWorker.federatedSignInCalled)
        XCTAssertEqual(authenticationWorker.federatedSignInParameters?.preferPrivateSession, preferPrivateSession)
        XCTAssertIdentical(authenticationWorker.federatedSignInParameters?.presentationAnchor, presentationAnchor)
    }


    @MainActor
    func test_presentFederatedSignOutUI_withAuthUISuccess_willSucceed() async throws {
        // given
        authenticationWorker.federatedSignOutResult = .success(())
        // when
        try await client.presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor())
    }

    @MainActor
    func test_presentFederatedSignOutUI_withAuthUIFailure_willThrowError() async throws {
        // given
        let signOutError = SudoUserClientError.identityNotConfirmed
        authenticationWorker.federatedSignOutResult = .failure(signOutError)
        // when
        do {
            try await client.presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor())
            // then
            XCTFail("Sign out should not succeed")
        } catch SudoUserClientError.identityNotConfirmed {
            // Expected error received
        }
    }

    func test_getUserClaim() async throws {
        // given
        authenticationWorker.getAuthTokensResult = .success(
            AuthenticationTokens(
                idToken: idTokenWithIdentityIdClaim,
                accessToken: "dummy-access-token",
                refreshToken: "dummy-refresh-token"
            )
        )
        // when
        let result = try await client.getUserClaim(name: "cognito:username")
        // then
        XCTAssertEqual("1E72EA01-80B6-450D-9935-04E6D2ACA496", result as? String)
    }

    func test_isSignedIn_withAuthenticationWorkerTrueResult_willReturnTrue() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(true)
        // when
        let result = try await client.isSignedIn()
        // then
        XCTAssertTrue(result)
    }

    func test_isSignedIn_withAuthenticationWorkerFalseResult_willReturnFalse() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(false)
        // when
        let result = try await client.isSignedIn()
        // then
        XCTAssertFalse(result)
    }

    func test_isSignedIn_withAuthenticationWorkerError_willThrowError() async throws {
        // given
        let authError = SudoUserClientError.authTokenMissing
        authenticationWorker.getIsSignedInResult = .failure(authError)
        // when
        do {
            _ = try await client.isSignedIn()
            // then
            XCTFail("Is signed in should not succeed")
        } catch SudoUserClientError.authTokenMissing {
            // Expected error received
        }
    }

    func test_getSupportedRegistrationChallengeTypes() {
        // when
        let challengeTypes = client.getSupportedRegistrationChallengeType()
        // then
        XCTAssertTrue(challengeTypes.contains(.deviceCheck))
        XCTAssertTrue(challengeTypes.contains(.test))
    }

    func test_signInWithAuthenticationProvider_withAuthenticationWorkerSuccess_willSucceedAndCallSignInObservers() async throws {
        // given
        let observer = SignInStatusObserverMock()
        await client.registerSignInStatusObserver(id: "dummy_id", observer: observer)
        graphQLClient.mutateResult = .success(RegisterFederatedIdMutation.Data())
        try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")
        let tokens = AuthenticationTokens(
            idToken: idToken,
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token"
        )
        authenticationWorker.signInResult = .success(tokens)
        authenticationWorker.refreshTokensResult = .success(tokens)
        authenticationWorker.getAuthTokensResult = .success(tokens)
        authenticationWorker.getIsSignedInResult = .success(false)
        let authenticationProviderMock = AuthenticationProviderMock()
        // when
        let result = try await client.signInWithAuthenticationProvider(authenticationProvider: authenticationProviderMock)
        // then
        let mutation = try XCTUnwrap(graphQLClient.mutateParameters?.mutation as? RegisterFederatedIdMutation)
        XCTAssertEqual(idToken, mutation.input?.idToken)
        XCTAssertEqual("dummy_uid", authenticationWorker.signInParameters?.uid)
        XCTAssertEqual("dummy_token", authenticationWorker.signInParameters?.parameters["answer"] as? String)
        XCTAssertEqual("FSSO", authenticationWorker.signInParameters?.parameters["challengeType"] as? String)
        XCTAssertEqual(result, tokens)
        await fulfillment(of: [observer.signedInExpectation, observer.signingInExpectation], timeout: 10)
    }

    func test_signInWithAuthenticationProvider_willSetUsername() async throws {
        // given
        graphQLClient.mutateResult = .success(RegisterFederatedIdMutation.Data())
        let tokens = AuthenticationTokens(
            idToken: idToken,
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token"
        )
        authenticationWorker.signInResult = .success(tokens)
        authenticationWorker.refreshTokensResult = .success(tokens)
        authenticationWorker.getAuthTokensResult = .success(tokens)
        authenticationWorker.getIsSignedInResult = .success(false)
        let authenticationProviderMock = AuthenticationProviderMock()
        // when
        let result = try await client.signInWithAuthenticationProvider(authenticationProvider: authenticationProviderMock)
        // then
        let username = try await client.clientStateActor.getUserName()
        XCTAssertEqual(username, "dummy_uid")
    }

    func test_signInWithRegisterFederatedId_withMutationError_willThrowError() async throws {
        // given
        graphQLClient.mutateResult = .failure(SudoUserClientError.graphQLError(cause: []))
        try keyManager.addPassword("dummy_uid".data(using: .utf8)!, name: "userId")
        let keyManager = LegacySudoKeyManager(serviceName: "com.sudoplatform.appservicename", keyTag: "com.sudoplatform", namespace: "ids")
        let userKeyId = "dummy_key_id"
        try keyManager.generateKeyPair(userKeyId)
        try keyManager.addPassword(userKeyId.data(using: .utf8)!, name: "userKeyId")
        let tokens = AuthenticationTokens(
            idToken: idToken,
            accessToken: "dummy_access_token",
            refreshToken: "dummy_refresh_token"
        )
        authenticationWorker.signInResult = .success(tokens)
        authenticationWorker.refreshTokensResult = .success(tokens)
        authenticationWorker.getAuthTokensResult = .success(tokens)
        authenticationWorker.getIsSignedInResult = .success(false)
        // when
        do {
            _ = try await client.signInWithKey()
            // then
        } catch SudoUserClientError.graphQLError {
            // Expected error.
        }
    }

    func test_resetUserData_willSucceed() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(true)
        graphQLClient.mutateResult = .success(ResetMutation.Data())
        // when
        try await client.resetUserData()
    }

    func test_resetUserData_whenNotSignedIn_willThrowError() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(false)
        do {
            try await client.resetUserData()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.notSignedIn {
            // expected error
        }
    }

    func test_resetUserData_whenMutationFails_willThrowError() async throws {
        // given
        authenticationWorker.getIsSignedInResult = .success(true)
        graphQLClient.mutateResult = .failure(SudoUserClientError.graphQLError(cause: []))
        // when
        do {
            try await client.resetUserData()
            XCTFail("Expected error not thrown.")
        } catch SudoUserClientError.graphQLError {
            // expected error
        }
    }

    // MARK: - Helpers

    func makeRefreshToken(withExpiry expiry: Date) throws -> String {
        let refreshTokenJwt = JWT(
            issuer: UUID().uuidString,
            audience: UUID().uuidString,
            subject: UUID().uuidString,
            id: UUID().uuidString
        )
        refreshTokenJwt.expiry = expiry
        return try refreshTokenJwt.signAndEncode(keyManager: keyManager, keyId: UUID().uuidString)
    }

    func resetAmplify() async {
        if Amplify.Auth.isConfigured {
            _ = await Amplify.Auth.signOut()
        }
        await Amplify.reset()
    }
}
