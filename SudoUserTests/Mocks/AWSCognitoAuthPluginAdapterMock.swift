//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import SudoUser
import Amplify
import AWSCognitoAuthPlugin
import Foundation

class AWSAuthPluginAdapterMock: AWSCognitoAuthPluginAdapter {

    var currentUserResult: Result<any AuthUser, Error> = .success(MockAuthUser())

    func getCurrentUser() async throws -> any AuthUser {
        try currentUserResult.get()
    }

    var fetchAuthSessionOptions: AuthFetchSessionRequest.Options?
    var authSession: AWSAuthCognitoSessionAdapterMock = AWSAuthCognitoSessionAdapterMock()
    var fetchAuthSessionError: Error?
    func fetchAuthSession(options: AuthFetchSessionRequest.Options?) async throws -> AuthSession {
        fetchAuthSessionOptions = options
        if let fetchAuthSessionError {
            throw fetchAuthSessionError
        }
        return authSession
    }

    var signUpResult: Result< AuthSignUpResult, Error> = .failure(
        NSError(domain: "signUpResult data not set", code: 0, userInfo: nil)
    )

    func signUp(
        username: String,
        password: String?,
        options: AuthSignUpRequest.Options?
    ) async throws -> AuthSignUpResult {
        try signUpResult.get()
    }

    // Controls what signIn returns
    var signInResult: Result<AuthSignInResult, Error>! = .failure(
        NSError(domain: "signInResult data not set", code: 0, userInfo: nil)
    )

    func signIn(
        username: String?,
        password: String?,
        options: AuthSignInRequest.Options?
    ) async throws -> AuthSignInResult {
        try signInResult.get()
    }

    var confirmSignInResult: Result<AuthSignInResult, Error>! = .failure(
        NSError(domain: "confirmSignInResult data not set", code: 0, userInfo: nil)
    )

    func confirmSignIn(
        challengeResponse: String,
        options: AuthConfirmSignInRequest.Options?
    ) async throws -> AuthSignInResult {
        try confirmSignInResult.get()
    }

    // MARK: - signOut
    var signOutResult: MockAuthSignOutResult = .init()

    func signOut(options: AuthSignOutRequest.Options?) async -> AuthSignOutResult {
        return signOutResult
    }

    // MARK: - signInWithWebUI
    var signInWithWebUIResult: Result<AuthSignInResult, Error>! = .failure(
        NSError(domain: "signInWithWebUIResult data not set", code: 0, userInfo: nil)
    )

    func signInWithWebUI(
        presentationAnchor: AuthUIPresentationAnchor?,
        options: AuthWebUISignInRequest.Options?
    ) async throws -> AuthSignInResult {
        try signInWithWebUIResult.get()
    }
}

// MARK: Concrete types used from AWS needed by mock

final class MockAuthUser: AuthUser {
    let username: String
    let userId: String

    init(username: String = "mockUser", userId: String = UUID().uuidString) {
        self.username = username
        self.userId = userId
    }
}

struct MockAuthSignOutResult: AuthSignOutResult, Sendable { }

extension AuthSignInResult {
    static func mockSignedIn() -> AuthSignInResult {
        return AuthSignInResult(nextStep: .done)
    }
}
