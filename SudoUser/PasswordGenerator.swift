//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Utility for generating a password to satisfy a specified password policy.
public protocol PasswordGenerator {

    /// Generate a random password with specified password policy.
    /// - Parameters:
    ///   - length: Password length.
    ///   - upperCase: Requires 1 uppercase character.
    ///   - lowerCase: Requires 1 lowercase character.
    ///   - special: Requires 1 special character.
    ///   - number: Requires 1 numeric character.
    /// - Returns: Generated password.
    func generatePassword(length: UInt, upperCase: Bool, lowerCase: Bool, special: Bool, number: Bool) -> String
}
