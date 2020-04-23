//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

/// Represents authentication tokens associated with a given user.
public struct AuthenticationTokens {
    /// Signed ID token carrying identity claims.
    public let idToken: String
    /// Signed access token used for API access that does not require details of the user's identity..
    public let accessToken: String
    /// Refresh token used for refreshing ID and access tokens.
    public let refreshToken: String
    /// Lifetime of the ID and access tokens in seconds.
    public let lifetime: Int

    public init(idToken: String, accessToken: String, refreshToken: String, lifetime: Int) {
        self.idToken = idToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.lifetime = lifetime
    }
}
