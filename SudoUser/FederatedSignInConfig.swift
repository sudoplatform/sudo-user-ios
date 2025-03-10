//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Configuration settings for federated sign-in using an external identity provider.
///
/// This struct encapsulates the necessary details for setting up and handling federated authentication
/// with Cognito or other OIDC-compliant identity providers.
struct FederatedSignInConfig: Equatable, Codable {

    // MARK: - Properties

    /// The client ID of the Cognito User Pool app.
    let appClientId: String

    /// The domain of the website used to sign in.
    let webDomain: String

    /// The URI where users are redirected after a successful sign-in.
    let signInRedirectUri: String

    /// The URI where users are redirected after signing out.
    let signOutRedirectUri: String
}
