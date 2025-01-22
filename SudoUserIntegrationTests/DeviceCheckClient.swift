//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSAppSync
import AWSPluginsCore
import Amplify
import AmplifyPlugins
import SudoLogging
import SudoUser
import SudoConfigManager
import SudoKeyManager

public class DeviceCheckClient {

    /// Default logger for SudoUserClient.
    private let logger: SudoLogging.Logger

    /// GraphQL client used calling Identity Service API.
    private var apiClient: AWSAppSyncClient

    /// Sudo Key Manager for storing tokens
    private let keyManager: SudoKeyManager

    public init(userClient: SudoUserClient, keyManager: SudoKeyManager) throws {
        logger = Logger(identifier: "SudoUserDeviceCheck", driver: NSLogDriver(level: .debug))
        self.keyManager = keyManager

        guard let acpServiceConfig = DefaultSudoConfigManager()?.getConfigSet(
            namespace: "adminConsoleProjectService"
        ) else {
            throw SudoUserClientError.identityServiceConfigNotFound
        }
        guard let configProvider = DeviceCheckClientConfigProvider(config: acpServiceConfig) else {
            throw SudoUserClientError.invalidConfig
        }
        let authProvider = GraphQLAuthProvider(client: userClient)
        // Set up an `AWSAppSyncClient` to call GraphQL API that requires sign in.
        do {
            let appSyncConfig = try AWSAppSyncClientConfiguration(
                appSyncServiceConfig: configProvider,
                userPoolsAuthProvider: authProvider
            )
            self.apiClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)
            self.apiClient.apolloClient?.cacheKeyForObject = { $0["id"] }

            let mainBundle = Bundle.main
            guard let url = mainBundle.url(
                forResource: "sudouseramplifyconfiguration",
                withExtension: "json"
            ) else {
                throw SudoUserClientError.invalidConfig
            }
            let amplifyConfiguration = try AmplifyConfiguration(configurationFile: url)
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(amplifyConfiguration)
        } catch {
            logger.error("failed to configure AppSync client due to \(error)")
            throw error
        }
    }

    // swiftlint:disable inclusive_language
    public func whitelistDevice(deviceId: String) async throws {
        let whitelistDeviceInput = WhitelistDeviceInput(deviceId: deviceId, type: "IOS")
        // swiftlint:enable inclusive_language
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            apiClient.perform(
                mutation: WhitelistDeviceMutation(input: whitelistDeviceInput),
                queue: DispatchQueue(label: "com.sudoplatform.sudouser"),
                resultHandler: { (result, error) in
                if let error = error as? AWSAppSyncClientError {
                    continuation.resume(throwing: SudoUserClientError.graphQLError(cause: [error]))
                } else {
                    if let errors = result?.errors {
                        continuation.resume(throwing: SudoUserClientError.graphQLError(cause: errors))
                    } else {
                        self.logger.info("White listed device successfully.")
                        continuation.resume(returning: ())
                    }
                }
            })
        })
    }

    public func signIn(username: String, password: String) async throws {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            Amplify.Auth.signIn(
                username: username,
                password: password
            ) { result in
                switch result {
                case .success(let signInResult):
                    if signInResult.isSignedIn {
                        self.logger.info("Successful sign in \(signInResult).")
                    } else {
                        self.logger.error("Sign in next step is \(signInResult.nextStep)")
                        continuation.resume(throwing: SudoUserClientError.notSignedIn)
                    }
                    continuation.resume(returning: ())
                case .failure(let error):
                    continuation.resume(throwing: SudoUserClientError.graphQLError(cause: [error]))
                }
            }
        })
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            Amplify.Auth.fetchAuthSession { result in
                do {
                    let session = try result.get()
                    if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                        let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                        guard let idTokenData = tokens.idToken.data(using: .utf8) else {
                            continuation.resume(throwing: SudoUserClientError.authTokenMissing)
                            return
                        }
                        try self.keyManager.addPassword(
                            idTokenData,
                            name: "idToken"
                        )
                        guard let refreshTokenData = tokens.refreshToken.data(using: .utf8) else {
                            continuation.resume(throwing: SudoUserClientError.authTokenMissing)
                            return
                        }
                        try self.keyManager.addPassword(
                            refreshTokenData,
                            name: "refreshToken"
                        )
                        guard let accessTokenData = tokens.accessToken.data(using: .utf8) else {
                            continuation.resume(throwing: SudoUserClientError.authTokenMissing)
                            return
                        }
                        try self.keyManager.addPassword(
                            accessTokenData,
                            name: "accessToken"
                        )
                        let tokenExpiry = String(Date(timeIntervalSinceNow: 1200).timeIntervalSince1970)
                        try self.keyManager.addPassword(tokenExpiry.data(using: .utf8)!, name: "tokenExpiry")
                        continuation.resume(returning: ())
                    }
                } catch {
                    continuation.resume(throwing: SudoUserClientError.graphQLError(cause: [error]))
                }
            }
        })
    }

    public func signOut() async throws {
        return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Void, Error>) in
            Amplify.Auth.signOut() { result in
                    switch result {
                    case .success(_):
                        self.logger.info("Successful sign out.")
                        continuation.resume(returning: ())
                    case .failure(let error):
                        continuation.resume(throwing: SudoUserClientError.graphQLError(cause: [error]))
                    }
                }
        })

    }
}
