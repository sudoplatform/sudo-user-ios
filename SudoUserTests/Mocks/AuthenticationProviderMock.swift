//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import SudoUser

class MyAuthenticationInfo: AuthenticationInfo {

    let type = "FSSO"

    func isValid() -> Bool {
        return true
    }

    func toString() -> String {
        return "dummy_token"
    }

    func getUsername() -> String {
        return "dummy_uid"
    }
}

class AuthenticationProviderMock: AuthenticationProvider {

    func getAuthenticationInfo() async throws -> AuthenticationInfo {
        return MyAuthenticationInfo()
    }

    func reset() {
        // no-op
    }
}
