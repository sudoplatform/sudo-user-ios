//
// Copyright © 2025 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSPluginsCore
import Foundation
import SudoConfigManager
import SudoKeyManager
import SudoLogging
@testable import SudoUser

class DeviceCheckClient {

    // MARK: - Properties

    private let apiName = "adminConsoleProjectService"

    /// Default logger for SudoUserClient.
    private let logger: SudoLogging.Logger

    // MARK: - Lifecycle

    init() throws {
        logger = Logger(identifier: "SudoUserDeviceCheck", driver: NSLogDriver(level: .debug))
        let defaultConfigManagerName = SudoConfigManagerFactory.Constants.defaultConfigManagerName
        guard
            let configManager = SudoConfigManagerFactory.instance.getConfigManager(name: defaultConfigManagerName),
            let config = configManager.getConfigSet(namespace: apiName)
        else {
            throw SudoUserClientError.identityServiceConfigNotFound
        }
        guard
            let endpoint = config["apiUrl"] as? String,
            let region = config["region"] as? String,
            let clientId = config["clientId"] as? String,
            let userPoolId = config["userPoolId"] as? String
        else {
            throw SudoUserClientError.invalidConfig
        }
        let authConfigValues: [String: JSONValue] = [
            "CognitoUserPool": [
                "Default": [
                    "PoolId": JSONValue.string(userPoolId),
                    "AppClientId": JSONValue.string(clientId),
                    "Region": JSONValue.string(region)
                ]
            ]
        ]
        let apiConfigValues: [String: JSONValue] = [
            apiName: [
                "endpointType": "GraphQL",
                "endpoint": JSONValue.string(endpoint),
                "region": JSONValue.string(region),
                "authorizationType": JSONValue.string("AMAZON_COGNITO_USER_POOLS")
            ]
        ]
        let amplifyConfig = AmplifyConfiguration(
            api: APICategoryConfiguration(plugins: ["awsAPIPlugin": JSONValue.object(apiConfigValues)]),
            auth: AuthCategoryConfiguration(plugins: ["awsCognitoAuthPlugin": JSONValue.object(authConfigValues)])
        )
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.add(plugin: AWSAPIPlugin())
        try Amplify.configure(amplifyConfig)
    }

    // MARK: - Methods

    // swiftlint:disable inclusive_language
    public func whitelistDevice(deviceId: String) async throws {
        let input = WhitelistDeviceInput(deviceId: deviceId, type: "IOS")
        let mutation = WhitelistDeviceMutation(input: input)
        let variablesDict = mutation.variables?.jsonValue as? [String: Any]
        let request = GraphQLRequest<WhitelistDeviceMutation.Data>(
            apiName: apiName,
            document: WhitelistDeviceMutation.requestString,
            variables: variablesDict,
            responseType: WhitelistDeviceMutation.Data.self,
            authMode: AWSAuthorizationType.amazonCognitoUserPools
        )
        // swiftlint:enable inclusive_language
        do {
            _ = try await Amplify.API.mutate(request: request).get()
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
    }
}
