//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager

/// Protocol encapsulating properties and methods required to be implemented by all authentication
/// providers.
public protocol AuthenticationProvider {

    /// Creates and returns authentication information.
    /// - Returns: Authentication info.
    func getAuthenticationInfo() async throws -> AuthenticationInfo

    /// Resets any cached authentication information.
    func reset()
}
