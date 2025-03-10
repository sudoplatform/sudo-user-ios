//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Protocol encapsulating properties and methods related to credentials used
/// to authenticate to the backend.
public protocol AuthenticationInfo {

    /// Authentication type.
    var type: String { get }

    /// Indicates whether or not the authentication information is valid, i.e. well-formed
    /// and has not expired.
    ///
    /// - Returns: `true` if the authentication information is valid.
    func isValid() -> Bool

    /// Returns the authentication information serialized to a String.
    ///
    /// - Returns: String representation of the authentication information.
    func toString() -> String

    /// Returns the username associated with this authentication information.
    /// - Returns: Username.
    func getUsername() -> String

}
