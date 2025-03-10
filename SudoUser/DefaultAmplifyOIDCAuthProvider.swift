//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import Foundation

/// Default`AmplifyOIDCAuthProvider` conforming instance which retrieves the ID token from the current
/// auth session to include with API requests.
class DefaultAmplifyOIDCAuthProvider: AmplifyOIDCAuthProvider {

    // MARK: - Conformance: AmplifyOIDCAuthProvider

    func getLatestAuthToken() async throws -> String {
        let authSession = try await Amplify.Auth.fetchAuthSession()
        guard let cognitoAuthSession = authSession as? AWSAuthCognitoSession else {
            throw SudoUserClientError.fatalError(description: "Unexpected auth session type")
        }
        let userPoolTokens = try cognitoAuthSession.userPoolTokensResult.get()
        return userPoolTokens.idToken
    }
}
