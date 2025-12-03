//
// Copyright © 2025 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import SudoUser

class SudoUserClientErrorTransformerSpy: DefaultSudoUserClientErrorTransformer {
    var transformCallCount: Int = 0
    var tranformInput: Error?
    override func transform(_ error: Error) -> SudoUserClientError {
        transformCallCount += 1
        tranformInput = error
        return super.transform(error)
    }
}
