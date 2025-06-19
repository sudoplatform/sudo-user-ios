//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AuthenticationServices
import Foundation

/// A protocol defining authentication operations such as user registration, sign-in,
/// token management, and sign-out.
///
/// Conforming instances handle interactions with an authentication provider,
/// managing user sessions and authentication tokens.
protocol AuthenticationWorker: AnyObject {

    // MARK: - Getters

    /// Checks if a user is currently signed in.
    /// - Returns: `true` if a user is signed in, otherwise `false`.
    func getIsSignedIn() async throws -> Bool

    /// Retrieves the username of the currently signed-in user.
    /// - Returns: The username as a `String`.
    func getUsername() async throws -> String

    /// Retrieves the unique identifier of the currently signed-in user.
    /// - Returns: The user ID as a `String`.
    func getUserId() async throws -> String

    /// Retrieves the current authentication tokens for the signed-in user.
    /// - Returns: An `AuthenticationTokens` object containing the access, ID, and refresh tokens.
    func getAuthTokens() async throws -> AuthenticationTokens

    /// Retrieves the Cognito Identity ID associated with the user.
    /// - Returns: The Identity ID as a `String`.
    func getIdentityId() async throws -> String

    // MARK: - Authentication

    /// Registers a new identity (user) with the authentication provider.
    /// - Parameters:
    ///   - uid: A unique identifier for the user.
    ///   - parameters: A dictionary of registration parameters (e.g., email, password).
    /// - Returns: The user ID of the newly registered user.
    func register(uid: String, parameters: [String: String]) async throws -> String

    /// Signs in an existing user with the authentication provider.
    /// - Parameters:
    ///   - uid: The unique identifier of the user.
    ///   - parameters: A dictionary containing sign-in parameters (e.g., password, MFA code).
    /// - Returns: An `AuthenticationTokens` object containing the access, ID, and refresh tokens.
    func signIn(uid: String, parameters: [String: Any]) async throws -> AuthenticationTokens

    /// Refreshes authentication tokens using the refresh token.
    /// - Returns: An updated `AuthenticationTokens` object with new access and ID tokens.
    func refreshTokens() async throws -> AuthenticationTokens

    /// Signs out the user from the current device only.
    func signOut() async throws

    /// Signs out the user from the current device only and will return successfully if
    /// the local auth state was updated successfully.
    func signOutLocally() async throws

    // MARK: - Web UI

    /// Presents the sign in UI for federated sign in using an external identity provider.
    /// - Parameters:
    ///   - presentationAnchor: Window to act as the anchor for this UI.
    ///   - preferPrivateSession: Will start the webUI sign in a private browser session, if supported by the current browser. Default: `true`.
    ///   This value internally sets `prefersEphemeralWebBrowserSession` in ASWebAuthenticationSession. As per Apple documentation,
    ///   whether the request is honored depends on the user’s default web browser. Safari always honors the request.
    /// - Returns: Authentication tokens.
    func presentFederatedSignInUI(presentationAnchor: ASPresentationAnchor, preferPrivateSession: Bool) async throws -> AuthenticationTokens

    /// Presents the sign out UI for federated sign in using an external identity provider.
    /// - Parameter presentationAnchor: Window to act as the anchor for this UI.
    func presentFederatedSignOutUI(presentationAnchor: ASPresentationAnchor) async throws
}
