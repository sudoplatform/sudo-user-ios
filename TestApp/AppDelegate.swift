//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SudoUser
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties

    var client: SudoUserClient?

    var window: UIWindow?

    // MARK: - Conformance: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            // Return early if running unit tests
            return true
        }
        NSLog("App configuration: \(String(describing: Bundle.main.infoDictionary?["Configuration"]))")
        NSLog("*** vendorId=\(String(describing: UIDevice.current.identifierForVendor))")
        do {
            client = try DefaultSudoUserClient(keyNamespace: "ids")
        } catch let error {
            NSLog("Failed configure the client: \(error)")
        }
        return true
    }
}
