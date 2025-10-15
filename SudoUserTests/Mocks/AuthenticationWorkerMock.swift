//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AuthenticationServices
import Foundation
@testable import SudoUser

class AuthenticationWorkerMock: AuthenticationWorker {

    var getIsSignedInCalled = false
    var getIsSignedInResult: Result<Bool, Error> = .failure(SudoUserClientError.fatalError(description: "not implemented"))

    func getIsSignedIn() async throws -> Bool {
        getIsSignedInCalled = true
        return try getIsSignedInResult.get()
    }

    var getUsernameCalled = false
    var getUsernameResult: Result<String, Error> = .failure(SudoUserClientError.fatalError(description: "not implemented"))

    func getUsername() async throws -> String {
        getUsernameCalled = true
        return try getUsernameResult.get()
    }

    var getUserIdCalled = false
    var getUserIdResult: Result<String, Error> = .failure(SudoUserClientError.fatalError(description: "not implemented"))

    func getUserId() async throws -> String {
        getUserIdCalled = true
        return try getUserIdResult.get()
    }

    var getAuthTokensCalled = false
    var getAuthTokensResult: Result<AuthenticationTokens, Error> = .failure(
        SudoUserClientError.fatalError(description: "not implemented")
    )
    func getAuthTokens() async throws -> SudoUser.AuthenticationTokens {
        getAuthTokensCalled = true
        return try getAuthTokensResult.get()
    }

    var getIdentityIdCalled = false
    var getIdentityIdResult: Result<String, Error> = .failure(SudoUserClientError.fatalError(description: "not implemented"))

    func getIdentityId() async throws -> String {
        getIdentityIdCalled = true
        return try getIdentityIdResult.get()
    }

    var registerCalled = false
    var registerParameters: (uid: String, parameters: [String: String])?
    var registerResult: Result<String, Error> = .success("")

    func register(uid: String, parameters: [String: String]) async throws -> String {
        registerCalled = true
        registerParameters = (uid, parameters)
        return try registerResult.get()
    }

    var signInCalled = false
    var signInParameters: (uid: String, parameters: [String: Any])?
    var signInResult: Result<AuthenticationTokens, Error> = .success(
        AuthenticationTokens(
            idToken: "",
            accessToken: "",
            refreshToken: ""
        )
    )
    var signInResultDelay: TimeInterval?

    func signIn(uid: String, parameters: [String: Any]) async throws -> AuthenticationTokens {
        signInCalled = true
        signInParameters = (uid, parameters)
        if let signInResultDelay {
            try? await Task.sleep(seconds: signInResultDelay)
        }
        return try signInResult.get()
    }

    var refreshTokensCalled = false
    var refreshTokensResult: Result<AuthenticationTokens, Error> = .success(
        AuthenticationTokens(
            idToken: "",
            accessToken: "",
            refreshToken: ""
        )
    )
    var refreshResultDelay: TimeInterval?

    func refreshTokens() async throws -> AuthenticationTokens {
        refreshTokensCalled = true
        if let refreshResultDelay {
            try? await Task.sleep(seconds: refreshResultDelay)
        }
        return try refreshTokensResult.get()
    }

    var signOutCalled = false
    var signOutResult: Result<Void, Error> = .success(())

    func signOut() async throws {
        signOutCalled = true
        try signOutResult.get()
    }

    var signOutLocallyCalled = false
    var signOutLocallyResult: Result<Void, Error> = .success(())

    func signOutLocally() async throws {
        signOutLocallyCalled = true
        return try signOutLocallyResult.get()
    }

    var federatedSignInCalled: Bool = false
    var federatedSignInParameters: (presentationAnchor: ASPresentationAnchor, preferPrivateSession: Bool)?
    var federatedSignInResult: Result<AuthenticationTokens, Error> = .success(
        AuthenticationTokens(
            idToken: "",
            accessToken: "",
            refreshToken: ""
        )
    )

    func presentFederatedSignInUI(
        presentationAnchor: ASPresentationAnchor,
        preferPrivateSession: Bool
    ) async throws -> AuthenticationTokens {
        federatedSignInCalled = true
        federatedSignInParameters = (presentationAnchor, preferPrivateSession)
        return try federatedSignInResult.get()
    }

    var federatedSignOutResult: Result<Void, Error> = .success(())
    func presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor) async throws {
        try federatedSignOutResult.get()
    }
}
