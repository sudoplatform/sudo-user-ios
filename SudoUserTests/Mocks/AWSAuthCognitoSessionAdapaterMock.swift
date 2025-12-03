//
// Copyright © 2025 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import Foundation
@testable import SudoUser

final class AWSAuthCognitoSessionAdapterMock: AWSAuthCognitoSessionAdapter, AuthSession, @unchecked Sendable {

    var isSignedIn: Bool = false

    var userPoolTokensResult: Result<AuthCognitoTokens, AuthError> = .success(
        AuthCognitoTokensMock(
            idToken: "c137",
            accessToken: "i_have_the_power_of_god",
            refreshToken: "you_should_have_mocked_this_earlier"
        )
    )

    func getUserPoolTokens() throws -> AuthCognitoTokens {
        try userPoolTokensResult.get()
    }

    var identityIdResult: Result<String, AuthError> = .success("ghost-in-the-mock")

    func getIdentityId() throws -> String {
        try identityIdResult.get()
    }
}

struct AuthCognitoTokensMock: AuthCognitoTokens {
    var idToken: String
    var accessToken: String
    var refreshToken: String

}
