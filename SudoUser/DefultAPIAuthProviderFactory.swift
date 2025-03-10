//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

/// Default implementation of the factory which makes the utility which provides
/// the ID token to API requests.
class DefaultAPIAuthProviderFactory: APIAuthProviderFactory {

    override func oidcAuthProvider() -> AmplifyOIDCAuthProvider? {
        DefaultAmplifyOIDCAuthProvider()
    }
}
