//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import SudoUser

class GraphQLClientMock: GraphQLClient {

    var mutateCalled: Bool = false
    var mutateCallCount: Int = 0
    var mutateParameters: (mutation: Any, Void)?
    var mutateParameterList: [Any] = []
    var mutateResult: Result<Any, Error> = .failure(SudoUserClientError.fatalError(description: "Not implemented"))

    func mutate<M>(_ mutation: M) async throws -> M.Data where M: SudoUser.GraphQLMutation {
        mutateCalled = true
        mutateCallCount += 1
        mutateParameters = (mutation, ())
        mutateParameterList.append((mutation, ()))
        if let result = try mutateResult.get() as? M.Data {
            return result
        }
        throw SudoUserClientError.fatalError(description: "Invalid result type")
    }
}
