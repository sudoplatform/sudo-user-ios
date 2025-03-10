//
// Copyright © 2025 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Protocol that wraps the`URLSession` to enable mocking.
protocol URLSessionProtocol {

    /// Convenience method to load data using a URLRequest, creates and resumes a URLSessionDataTask internally.
    /// - Parameter request: The URLRequest for which to load data.
    /// - Returns: Data and response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
