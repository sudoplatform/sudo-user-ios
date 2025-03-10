//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

@testable import Amplify
import DeviceCheck
import SudoKeyManager
@testable import SudoUser
import UIKit
import XCTest

class DeviceCheckTests: XCTestCase {

    // MARK: - Properties

    var instanceUnderTest: DeviceCheckClient!
    var sudoUserClient: DefaultSudoUserClient!
    var configName: String!
    var config: [String: Any]!

    // MARK: - Lifecycle

    override func setUp() async throws {
        if Amplify.Auth.isConfigured {
            await Amplify.Auth.reset()
        }
        await Amplify.reset()
        guard let configName = ProcessInfo.processInfo.environment["CONFIG_NAME"] else {
            throw SudoUserClientError.fatalError(description: "Failed to config name from environment")
        }
        self.configName = configName
        guard
            let url = Bundle.main.url(forResource: "sudoplatformconfig", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let config = data.toJSONObject() as? [String: Any]
        else {
            throw SudoUserClientError.invalidConfig
        }
        self.config = config
        sudoUserClient = try DefaultSudoUserClient(keyNamespace: "ids")
        try await sudoUserClient.reset()
    }

    // MARK: - Tests

    @MainActor func test_registerWithDeviceCheckToken_withAllowListedDevice_willSucceed() async throws {
        // given
        if configName != "gc-dev" {
            throw XCTSkip("DeviceCheck test only runs in gc-dev environment")
        }
        guard sudoUserClient.getSupportedRegistrationChallengeType().contains(.deviceCheck) else {
            throw XCTSkip("The environment does not support DeviceCheck.")
        }
        guard !isSimulator() else {
            throw XCTSkip("DeviceCheck is not supported by the simulator.")
        }
        guard let deviceCheckToken = await getDeviceCheckToken() else {
            return XCTFail("DeviceCheck token not found.")
        }
        let deviceCheckClient = try DeviceCheckClient(userClient: sudoUserClient, keyManager: sudoUserClient.keyManager)
        do {
            try await deviceCheckClient.signOut()
        } catch {
            NSLog("ignoring sign out failure \(error)")
        }
        let vendorId = try XCTUnwrap(UIDevice.current.identifierForVendor)
        let deviceId = vendorId.uuidString

        guard let username = ProcessInfo.processInfo.environment["ADMIN_CONSOLE_USERNAME"] else {
            return XCTFail("Admin Console Username is not set")
        }
        guard let password = ProcessInfo.processInfo.environment["ADMIN_CONSOLE_PASSWORD"] else {
            return XCTFail("Admin Console Password is not set")
        }
        do {
            try await deviceCheckClient.signIn(username: username, password: password)
            try await deviceCheckClient.whitelistDevice(deviceId: deviceId)
        } catch {
            return XCTFail("could not whitelist device \(error)")
        }
        // when
        _ = try await sudoUserClient.registerWithDeviceCheck(
            token: deviceCheckToken,
            buildType: "debug",
            vendorId: vendorId,
            registrationId: "dummy_rid"
        )
        // when
        let status = try await sudoUserClient.isRegistered()
        XCTAssertTrue(status)
    }

    // MARK: - Helpers

    func isSimulator() -> Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }

    // MARK: - Helpers

    func getDeviceCheckToken() async -> Data? {
        let currentDevice = DCDevice.current
        guard currentDevice.isSupported else {
            return nil
        }
        do {
            let deviceCheckToken = try await currentDevice.generateToken()
            NSLog("Got new device check token \(String(describing: deviceCheckToken))")
            return deviceCheckToken
        } catch {
            NSLog("Failed to generate DeviceCheck token: \(error)")
            return nil
        }
    }
}
