//
// Copyright © 2026 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Internal actor for thread-safe sign-in delegate storage
private actor SignInDelegateManager {
    private weak var delegate: SudoPlatformSignInDelegate?
    
    init(delegate: SudoPlatformSignInDelegate? = nil) {
        self.delegate = delegate
    }

    func setDelegate(_ delegate: SudoPlatformSignInDelegate?) {
        self.delegate = delegate
    }

    func getDelegate() -> SudoPlatformSignInDelegate? {
        return delegate
    }
}

/// A reusable helper class that provides sign-in checking functionality for Sudo Platform libraries.
///
/// This class encapsulates the logic for checking if a user is signed in and invoking a delegate
/// to handle sign-in when needed. It is designed to be used by any SudoPlatform Client
/// to provide consistent sign-in callback behavior across the platform.

public class SignInGuard {
    private let userClient: SudoUserClient
    private let delegateManager: SignInDelegateManager

    /// Initializes a new SignInGuard instance.
    ///
    /// - Parameters:
    ///   - userClient: The SudoUserClient instance to use for checking sign-in status.
    ///   - delegate: Optional delegate to be invoked when sign-in is required. Can be set later using `setDelegate(_:)`.
    public init(userClient: SudoUserClient, delegate: SudoPlatformSignInDelegate? = nil) {
        self.userClient = userClient
        self.delegateManager = SignInDelegateManager(delegate: delegate)
    }

    /// Sets the delegate to be invoked when sign-in is required.
    ///
    /// - Parameter delegate: A delegate conforming to `SudoPlatformSignInDelegate`, or nil to disable sign-in checking.
    public func setDelegate(_ delegate: SudoPlatformSignInDelegate?) async {
        await delegateManager.setDelegate(delegate)
    }

    /// Checks if the user is signed in and invokes the delegate if needed.
    ///
    /// This method performs the following:
    /// 1. If no delegate is set, returns immediately
    /// 2. Checks if the user is signed in using `userClient.isSignedIn()`
    /// 3. If not signed in, invokes the delegate's `signIn()` method
    ///
    /// - Throws: Any error thrown by the delegate's `signIn()` method, or errors from checking sign-in status.

    public func ensureSignedIn() async throws {
        // Get delegate in thread-safe manner
        guard let delegate = await delegateManager.getDelegate() else {
            // No delegate configured - skip check (backward compatible behavior)
            return
        }

        // Check if user is signed in
        let isSignedIn: Bool
        do {
            isSignedIn = try await userClient.isSignedIn()
        } catch {
            // If we can't determine sign-in status, assume not signed in
            isSignedIn = false
        }

        // If not signed in, invoke delegate
        if !isSignedIn {
            try await delegate.signIn()
        }
    }
}
