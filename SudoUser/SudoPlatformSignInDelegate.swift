//
// Copyright © 2026 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Delegate protocol for handling authentication when the user is not signed in.
///
/// Implement this protocol to provide custom sign-in logic when operations are attempted
/// while the user is not authenticated.
public protocol SudoPlatformSignInDelegate: AnyObject {
    /// Called when a sudo platform operation is attempted while the user is not signed in.
    ///
    /// Implementations should perform the necessary sign-in logic and throw an error
    /// if sign-in fails or is cancelled.
    ///
    /// - Throws: Any error that occurs during sign-in. The error will be propagated
    ///   to the caller and the original operation will not be executed.
    func signIn() async throws
}
