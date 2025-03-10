//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AuthenticationServices
import Foundation

class ASWebAuthenticationSessionMock: ASWebAuthenticationSession {

    var initCalled = false
    var initCallCount = 0
    var initParameters: (url: URL, callbackURLScheme: String?, completionHandler: ASWebAuthenticationSession.CompletionHandler)?
    var initParameterList: [(url: URL, callbackURLScheme: String?, completionHandler: ASWebAuthenticationSession.CompletionHandler)] = []

    override init(url URL: URL, callbackURLScheme: String?, completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler) {
        initCalled = true
        initCallCount += 1
        initParameters = (URL, callbackURLScheme, completionHandler)
        initParameterList.append((URL, callbackURLScheme, completionHandler))
        super.init(url: URL, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
    }

    var startCalled = false
    var startCallCount: Int = 0
    var startResult: Bool = false

    override func start() -> Bool {
        startCalled = true
        startCallCount += 1
        return startResult
    }
}
