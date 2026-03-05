//
// Copyright © 2026 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
@testable import SudoUser

// MARK: - Test Doubles

/// A mock delegate that records invocations and optionally throws.
class MockSignInDelegate: SudoPlatformSignInDelegate {
    var signInCallCount = 0
    var signInError: Error?

    func signIn() async throws {
        signInCallCount += 1
        if let error = signInError {
            throw error
        }
    }
}

// MARK: - Tests

class SignInGuardTests: XCTestCase {

    // MARK: - Properties

    var userClient: MockSudoUserClient!
    var delegate: MockSignInDelegate!
    var instanceUnderTest: SignInGuard!

    // MARK: - Lifecycle

    override func setUp() async throws {
        userClient = MockSudoUserClient()
        delegate = MockSignInDelegate()
        instanceUnderTest = SignInGuard(userClient: userClient)
    }

    // MARK: - No delegate configured

    func test_ensureSignedIn_noDelegateSet_doesNotCheckSignInStatus() async throws {
        // Given: no delegate is set (default)
        userClient.isSignedInReturn = true

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then: isSignedIn was never consulted because there is no delegate
        XCTAssertFalse(userClient.isSignedInCalled)
    }

    func test_ensureSignedIn_noDelegateSet_doesNotThrow() async throws {
        // Given: no delegate, user is not signed in
        userClient.isSignedInReturn = false

        // When / Then: should complete without throwing
        try await instanceUnderTest.ensureSignedIn()
    }

    // MARK: - Delegate set at init

    func test_ensureSignedIn_withDelegateAtInit_userSignedIn_delegateNotCalled() async throws {
        // Given
        userClient.isSignedInReturn = true
        instanceUnderTest = SignInGuard(userClient: userClient, delegate: delegate)

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then
        XCTAssertEqual(delegate.signInCallCount, 0)
    }

    func test_ensureSignedIn_withDelegateAtInit_userNotSignedIn_delegateCalled() async throws {
        // Given
        userClient.isSignedInReturn = false
        instanceUnderTest = SignInGuard(userClient: userClient, delegate: delegate)

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then
        XCTAssertEqual(delegate.signInCallCount, 1)
    }

    // MARK: - setDelegate

    func test_ensureSignedIn_delegateSetAfterInit_userNotSignedIn_delegateCalled() async throws {
        // Given: delegate added after construction
        userClient.isSignedInReturn = false
        await instanceUnderTest.setDelegate(delegate)

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then
        XCTAssertEqual(delegate.signInCallCount, 1)
    }

    func test_ensureSignedIn_delegateRemovedAfterSet_userNotSignedIn_delegateNotCalled() async throws {
        // Given: delegate set then removed
        userClient.isSignedInReturn = false
        await instanceUnderTest.setDelegate(delegate)
        await instanceUnderTest.setDelegate(nil)

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then: original delegate should never be invoked
        XCTAssertEqual(delegate.signInCallCount, 0)
    }

    func test_ensureSignedIn_delegateReplacedWithNew_onlyNewDelegateCalled() async throws {
        // Given
        userClient.isSignedInReturn = false
        await instanceUnderTest.setDelegate(delegate)

        let newDelegate = MockSignInDelegate()
        await instanceUnderTest.setDelegate(newDelegate)

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then
        XCTAssertEqual(delegate.signInCallCount, 0, "Old delegate should not be called")
        XCTAssertEqual(newDelegate.signInCallCount, 1, "New delegate should be called")
    }

    // MARK: - isSignedIn error handling

    func test_ensureSignedIn_isSignedInThrows_treatsAsNotSignedIn_delegateCalled() async throws {
        // Given: isSignedIn() throws — guard should treat this as not signed in
        userClient.isSignedInError = SudoUserClientError.notSignedIn
        await instanceUnderTest.setDelegate(delegate)

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then: delegate must still be invoked
        XCTAssertEqual(delegate.signInCallCount, 1)
    }

    // MARK: - Error propagation from delegate

    func test_ensureSignedIn_userNotSignedIn_delegateThrows_errorPropagated() async throws {
        // Given
        userClient.isSignedInReturn = false
        let expectedError = SudoUserClientError.notSignedIn
        delegate.signInError = expectedError
        await instanceUnderTest.setDelegate(delegate)

        // When / Then
        do {
            try await instanceUnderTest.ensureSignedIn()
            XCTFail("Expected error to be thrown")
        } catch let error as SudoUserClientError {
            guard case .notSignedIn = error else {
                XCTFail("Expected .notSignedIn, got \(error)")
                return
            }
        }
    }

    func test_ensureSignedIn_userSignedIn_delegateConfiguredToThrow_delegateNotCalled() async throws {
        // Given: user IS signed in, delegate would throw if called
        userClient.isSignedInReturn = true
        delegate.signInError = SudoUserClientError.notSignedIn
        await instanceUnderTest.setDelegate(delegate)

        // When / Then: no error because delegate should not be invoked
        try await instanceUnderTest.ensureSignedIn()
        XCTAssertEqual(delegate.signInCallCount, 0)
    }

    // MARK: - Multiple calls

    func test_ensureSignedIn_calledMultipleTimes_userAlwaysSignedIn_delegateNeverCalled() async throws {
        // Given
        userClient.isSignedInReturn = true
        await instanceUnderTest.setDelegate(delegate)

        // When
        for _ in 0..<3 {
            try await instanceUnderTest.ensureSignedIn()
        }

        // Then
        XCTAssertEqual(delegate.signInCallCount, 0)
    }

    func test_ensureSignedIn_calledMultipleTimes_userNeverSignedIn_delegateCalledEachTime() async throws {
        // Given
        userClient.isSignedInReturn = false
        await instanceUnderTest.setDelegate(delegate)

        // When
        for _ in 0..<3 {
            try await instanceUnderTest.ensureSignedIn()
        }

        // Then: delegate invoked once per call
        XCTAssertEqual(delegate.signInCallCount, 3)
    }

    // MARK: - Weak delegate reference

    func test_ensureSignedIn_delegateDeallocated_doesNotCallDelegate() async throws {
        // Given: delegate is set but then released (weak reference in SignInDelegateManager)
        userClient.isSignedInReturn = false
        var ephemeralDelegate: MockSignInDelegate? = MockSignInDelegate()
        await instanceUnderTest.setDelegate(ephemeralDelegate)

        // Release the only strong reference
        ephemeralDelegate = nil

        // When
        try await instanceUnderTest.ensureSignedIn()

        // Then: guard should behave as if no delegate is set
        // (No crash and isSignedIn should not be called)
        XCTAssertFalse(userClient.isSignedInCalled)
    }
}


