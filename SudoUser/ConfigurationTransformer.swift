//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation

/// Utility for transforming between the SudoUserClient configuration structs and the configuration
/// required to initialize the Amplify client.
enum ConfigurationTransformer {

    /// Returns the configuration  to configure the AWS Amplify client based on the properties contained
    /// within the provided configurations.
    /// - Parameters:
    ///   - identityServiceConfig: The identity service configuration.
    ///   - federatedSignInConfig: The federated sign in configuration.
    /// - Returns: An Amplify client configuration.
    static func transform(
        identityServiceConfig: IdentityServiceConfig,
        federatedSignInConfig: FederatedSignInConfig?
    ) -> AuthCategoryConfiguration {
        var authConfigValues: [String: JSONValue] = [
            "CognitoUserPool": [
                "Default": [
                    "PoolId": JSONValue.string(identityServiceConfig.poolId),
                    "AppClientId": JSONValue.string(identityServiceConfig.clientId),
                    "Region": JSONValue.string(identityServiceConfig.region)
                ]
            ],
            "CredentialsProvider": [
                "CognitoIdentity": [
                    "Default": [
                        "PoolId": JSONValue.string(identityServiceConfig.identityPoolId),
                        "Region": JSONValue.string(identityServiceConfig.region)
                    ]
                ]
            ]
        ]
        if let federatedSignInConfig {
            authConfigValues["Auth"] = [
                "Default": [
                    "OAuth": [
                        "WebDomain": JSONValue.string(federatedSignInConfig.webDomain),
                        "AppClientId": JSONValue.string(federatedSignInConfig.appClientId),
                        "SignInRedirectURI": JSONValue.string(federatedSignInConfig.signInRedirectUri),
                        "SignOutRedirectURI": JSONValue.string(federatedSignInConfig.signOutRedirectUri),
                        "Scopes": ["openid"]
                    ]
                ]
            ]
        }
        let plugins: [String: JSONValue] = ["awsCognitoAuthPlugin": JSONValue.object(authConfigValues)]
        return AuthCategoryConfiguration(plugins: plugins)
    }
}
