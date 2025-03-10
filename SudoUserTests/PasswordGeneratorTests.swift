//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import SudoUser
import XCTest

class PasswordGeneratorTests: XCTestCase {

    // MARK: - Properties

    var instanceUnderTest: DefaultPasswordGenerator!

    // MARK: - Lifecycle

    override func setUp() async throws {
        instanceUnderTest = DefaultPasswordGenerator()
    }

    // MARK: - Tests

    func test_generatePassword_willGeneratePasswordSatisfyingInputPolicy() {
        // given
        let upperCaseChars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let lowerCaseChars = Array("abcdefghijklmnopqrstuvwxyz")
        let numberChars = Array("0123456789")
        let specialChars = Array(".!?;,&%$@#^*~")
        // when
        let password = instanceUnderTest.generatePassword(
            length: 50,
            upperCase: true,
            lowerCase: true,
            special: true,
            number: true
        )
        // then
        var lowerFound = false
        var upperFound = false
        var numberFound = false
        var specialFound = false
        for char in password {
            if lowerCaseChars.contains(char) {
                lowerFound = true
            } else if upperCaseChars.contains(char) {
                upperFound = true
            } else if numberChars.contains(char) {
                numberFound = true
            } else if specialChars.contains(char) {
                specialFound = true
            }
        }
        XCTAssertTrue(lowerFound)
        XCTAssertTrue(upperFound)
        XCTAssertTrue(numberFound)
        XCTAssertTrue(specialFound)
        XCTAssertEqual(50, password.count)
    }
}
