//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager

/// Protocol encapsulating properties and methods required to be implemented by all authentication
/// providers.
public protocol AuthenticationProvider {

    /// Creates and returns authentication information.
    ///
    /// - Returns: authentication information.
    @available(*, deprecated, message: "Use getAuthenticationInfo(completion:) instead.")
    func getAuthenticationInfo() throws -> AuthenticationInfo

    /// Creates and returns authentication information.
    ///
    /// - Parameters:
    ///   - completion: The completion handler to invoke to pass the authentication information or error.
    func getAuthenticationInfo(completion: @escaping(Swift.Result<AuthenticationInfo, Error>) -> Void)

    /// Resets any cached authentication information.
    func reset()

}

extension AuthenticationProvider {

    public func getAuthenticationInfo(completion: @escaping(Swift.Result<AuthenticationInfo, Error>) -> Void) {
        do {
            completion(.success(try self.getAuthenticationInfo()))
        } catch {
            completion(.failure(error))
        }
    }

}
