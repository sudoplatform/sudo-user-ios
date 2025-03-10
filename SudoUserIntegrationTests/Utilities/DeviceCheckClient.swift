//
// Copyright © 2025 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import Foundation
import SudoLogging
import SudoConfigManager
import SudoKeyManager
@testable import SudoUser

public class DeviceCheckClient {

    // MARK: - Properties

    /// Default logger for SudoUserClient.
    private let logger: SudoLogging.Logger

    /// GraphQL client used calling Identity Service API.
    private var apiClient: GraphQLClient

    /// Sudo Key Manager for storing tokens
    private let keyManager: SudoKeyManager

    // MARK: - Lifecycle

    public init(userClient: SudoUserClient, keyManager: SudoKeyManager) throws {
        logger = Logger(identifier: "SudoUserDeviceCheck", driver: NSLogDriver(level: .debug))
        self.keyManager = keyManager
        let defaultConfigManagerName = SudoConfigManagerFactory.Constants.defaultConfigManagerName
        let apiName = "adminConsoleProjectService"
        guard
            let configManager = SudoConfigManagerFactory.instance.getConfigManager(name: defaultConfigManagerName),
            let config = configManager.getConfigSet(namespace: apiName)
        else {
            throw SudoUserClientError.identityServiceConfigNotFound
        }
        guard let endpoint = config["apiUrl"] as? String, let region = config["region"] as? String else {
            throw SudoUserClientError.invalidConfig
        }
        // Set up an `GraphQLClient` to call GraphQL API that requires sign in.
        do {
            apiClient = try DefaultGraphQLClient(
                apiName: apiName,
                endpoint: endpoint,
                region: region
            )
        } catch {
            logger.error("failed to configure AppSync client due to \(error)")
            throw error
        }
    }

    // MARK: - Methods

    // swiftlint:disable inclusive_language
    public func whitelistDevice(deviceId: String) async throws {
        let whitelistDeviceInput = WhitelistDeviceInput(deviceId: deviceId, type: "IOS")
        // swiftlint:enable inclusive_language
        do {
            try await apiClient.mutate(WhitelistDeviceMutation(input: whitelistDeviceInput))
        } catch {
            throw SudoUserClientError.graphQLError(cause: [error])
        }
    }

    public func signIn(username: String, password: String) async throws {
        do {
            let signInResult = try await Amplify.Auth.signIn(username: username, password: password)
            if signInResult.isSignedIn {
                logger.info("Successful sign in \(signInResult).")
            } else {
                logger.error("Sign in next step is \(signInResult.nextStep)")
                throw SudoUserClientError.notSignedIn
            }
        } catch {
            throw SudoUserClientError.graphQLError(cause: [error])
        }
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            guard let cognitoTokenProvider = session as? AWSAuthCognitoSession else {
                throw SudoUserClientError.authTokenMissing
            }
            let tokens = try cognitoTokenProvider.getCognitoTokens().get()
            guard let idTokenData = tokens.idToken.data(using: .utf8) else {
                throw SudoUserClientError.authTokenMissing
            }
            try keyManager.addPassword(idTokenData, name: "idToken")
            guard let refreshTokenData = tokens.refreshToken.data(using: .utf8) else {
                throw SudoUserClientError.authTokenMissing
            }
            try keyManager.addPassword(refreshTokenData, name: "refreshToken")
            guard let accessTokenData = tokens.accessToken.data(using: .utf8) else {
                throw SudoUserClientError.authTokenMissing
            }
            try keyManager.addPassword(accessTokenData, name: "accessToken")
            let tokenExpiry = String(Date(timeIntervalSinceNow: 1200).timeIntervalSince1970)
            try keyManager.addPassword(tokenExpiry.data(using: .utf8)!, name: "tokenExpiry")
        } catch let clientError as SudoUserClientError {
            throw clientError
        } catch {
            throw SudoUserClientError.graphQLError(cause: [error])
        }
    }

    public func signOut() async throws {
        _ = await Amplify.Auth.signOut()
        logger.info("Successful sign out.")
    }
}
