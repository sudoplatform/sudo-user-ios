//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

struct DefaultPasswordGenerator: PasswordGenerator {

    // MARK: - Constants

    enum PasswordCharSet {
        static let allChars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?;,&%$@#^*~")
        static let upperCaseChars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        static let lowerCaseChars = Array("abcdefghijklmnopqrstuvwxyz")
        static let numberChars = Array("0123456789")
        static let specialChars = Array(".!?;,&%$@#^*~")
    }

    // MARK: - Conformance: PasswordGenerator

    func generatePassword(length: UInt, upperCase: Bool, lowerCase: Bool, special: Bool, number: Bool) -> String {
        var password: [Character] = []
        if upperCase {
            let index = Int(arc4random()) % (PasswordCharSet.upperCaseChars.count - 1)
            password.append(PasswordCharSet.upperCaseChars[index])
        }
        if lowerCase {
            let index = Int(arc4random()) % (PasswordCharSet.lowerCaseChars.count - 1)
            password.append(PasswordCharSet.lowerCaseChars[index])
        }
        if special {
            let index = Int(arc4random()) % (PasswordCharSet.specialChars.count - 1)
            password.append(PasswordCharSet.specialChars[index])
        }
        if number {
            let index = Int(arc4random()) % (PasswordCharSet.numberChars.count - 1)
            password.append(PasswordCharSet.numberChars[index])
        }
        while password.count < length {
            let index = Int(arc4random()) % (PasswordCharSet.allChars.count - 1)
            password.append(PasswordCharSet.allChars[index])
        }
        return String(password.shuffled())
    }
}
