//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager

/// List of possible errors thrown by `AuthenticationProvider` implementation.
///
/// - notInitialized: Indicates the authentication provider is not initialized correctly to be
///     able to generate authenticatino information.
public enum AuthenticationProviderError: Error {
    case notInitialized
}

/// Protocol encapsulating properties and methods required to be implemented by all authentication
/// providers.
public protocol AuthenticationProvider {

    /// Creates and returns authentication information.
    ///
    /// - Returns: authentication information.
    func getAuthenticationInfo() throws -> AuthenticationInfo

    /// Resets any cached authentication information.
    func reset()

}
