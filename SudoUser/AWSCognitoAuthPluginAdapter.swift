//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import Foundation

// Adapter for functions used from AWSCognitoAuthPlugin
protocol AWSCognitoAuthPluginAdapter {

    func getCurrentUser() async throws -> any AuthUser

    func fetchAuthSession(options: AuthFetchSessionRequest.Options?) async throws -> AuthSession

    func signUp(
        username: String,
        password: String?,
        options: AuthSignUpRequest.Options?
    ) async throws -> AuthSignUpResult

    func signIn(
        username: String?,
        password: String?,
        options: AuthSignInRequest.Options?
    ) async throws -> AuthSignInResult

    func confirmSignIn(
        challengeResponse: String,
        options: AuthConfirmSignInRequest.Options?
    ) async throws -> AuthSignInResult

    func signOut(options: AuthSignOutRequest.Options?) async -> AuthSignOutResult

    func signInWithWebUI(
        presentationAnchor: AuthUIPresentationAnchor?,
        options: AuthWebUISignInRequest.Options?
    ) async throws -> AuthSignInResult
}

// Functions to allow default arguments. These maintain the same surface window of the original aws class we are adapting.
// (i.e. I duplicated the functions from AWS and as a protocol default arguments aren't allowed and the fix is this extension)
extension AWSCognitoAuthPluginAdapter {

    func signUp(
        username: String,
        options: AuthSignUpRequest.Options?
    ) async throws -> AuthSignUpResult {
        try await self.signUp(username: username, password: nil, options: options)
    }

    func confirmSignIn(
        challengeResponse: String,
    ) async throws -> AuthSignInResult {
        try await self.confirmSignIn(challengeResponse: challengeResponse, options: nil)
    }

    func signOut() async -> AuthSignOutResult {
        await self.signOut(options: nil)
    }

    func signInWithWebUI(
        presentationAnchor: AuthUIPresentationAnchor?,
        options: AuthWebUISignInRequest.Options?
    ) async throws -> AuthSignInResult {
        try await self.signInWithWebUI(presentationAnchor: nil, options: options)
    }
}

// AWSCognitoAuthPlugin conformance to Adapter
extension AWSCognitoAuthPlugin: AWSCognitoAuthPluginAdapter {}
