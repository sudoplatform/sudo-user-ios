//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import SudoUser
import XCTest

class SignInStatusObserverMock: SignInStatusObserver {

    let signingInExpectation: XCTestExpectation = XCTestExpectation()
    let signedInExpectation: XCTestExpectation = XCTestExpectation()

    func signInStatusChanged(status: SignInStatus) {
        switch  status {
        case .signedIn:
            self.signedInExpectation.fulfill()
        case .signingIn:
            self.signingInExpectation.fulfill()
        default:
            break
        }
    }
}
