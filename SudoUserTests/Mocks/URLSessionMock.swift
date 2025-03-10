//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import SudoUser

class URLSessionMock: URLSessionProtocol {

    var dataForRequestCalled: Bool = false
    var dataForRequestCallCount: Int = 0
    var dataForRequestParameters: (request: URLRequest, Void)?
    var dataForRequestParameterList: [(request: URLRequest, Void)] = []
    var dataForRequestResult: Result<(Data, URLResponse), Error> = .failure(URLError(.unknown))

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataForRequestCalled = true
        dataForRequestCallCount += 1
        dataForRequestParameters = (request, ())
        dataForRequestParameterList.append((request, ()))
        return try dataForRequestResult.get()
    }
}
