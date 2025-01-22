//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import PushKit
import DeviceCheck
import SudoUser

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    public var pushPayload: [AnyHashable: Any] = [:]
    
    public var deviceCheckToken: Data?
    
    public var client: SudoUserClient?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        NSLog("App configuration: \(String(describing: Bundle.main.infoDictionary?["Configuration"]))")
        NSLog("*** vendorId=\(String(describing: UIDevice.current.identifierForVendor))")
        
        guard let url = Bundle(for: type(of: self)).url(forResource: "sudoplatformconfig", withExtension: "json") else {
            NSLog("Configuration file missing.")
            return true
        }
        
        do {
            let data = try Data(contentsOf: url)
            guard let config = data.toJSONObject() as? [String: Any] else {
                NSLog("Invalid configuration.")
                return true
            }
            
            NSLog("config: \(config)")
            
            do {
                try SudoUserClientManager.configure(name: "ids", config: config)
                self.client = SudoUserClientManager.client
            } catch let error {
                NSLog("Failed configure the client: \(error)")
            }
        } catch let error {
            NSLog("Cannot read the configuration file: \(error).")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getDeviceCheckToken() async throws -> Data? {
        if deviceCheckToken == nil {
            let currentDevice = DCDevice.current
            if currentDevice.isSupported {
                do {
                    deviceCheckToken = try await currentDevice.generateToken()
                    NSLog("Got new device check token \(String(describing: deviceCheckToken))")
                } catch {
                    NSLog("Failed to generate DeviceCheck token: \(error)")
                    return nil
                }
                
            }
            return deviceCheckToken
        }
        return deviceCheckToken
    }

}

extension Data {
    
    /**
     Converts NSData to HEX string.
     
     - Returns: HEX string representation of NSData.
     */
    func toHexString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    /**
     Converts NSData to JSON serializable object, e.g. Dictionary or Array.
     
     - Returns: Dictionary or Array representing JSON data. nil if the data
     does not represent JSON.
     */
    func toJSONObject() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.mutableContainers)
    }
    
    /**
     Converts JSON data to a pretty formatted string.
     
     - Return: pretty formatted JSON string.
     */
    func toJSONString() -> String? {
        guard let jsonObject = self.toJSONObject(),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
            let str = String(data: data, encoding: .utf8) else {
                return nil
        }
        
        return str
    }
    
}

