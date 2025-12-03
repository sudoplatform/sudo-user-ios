//
// Copyright © 2025 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import Foundation

// Adapter for functions used from AWSAuthCognitoSession
protocol AWSAuthCognitoSessionAdapter {

    /// Indicates whether the user is signedIn or not
    var isSignedIn: Bool { get }

    var userPoolTokensResult: Result<AuthCognitoTokens, AuthError> { get }

    var identityIdResult: Result<String, AuthError> { get }
}

// AWSAuthCognitoSessionAdapter protocol conformance for AWS session
extension AWSAuthCognitoSession: AWSAuthCognitoSessionAdapter {}
