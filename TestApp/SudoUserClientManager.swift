//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoUser
import AWSAppSync

enum SudoUserClientManagerError: Error {
    case invalidConfig
}

class SudoUserClientManager {
    
    static private(set) var client: SudoUserClient?
    
    static private(set) var config: [String: Any] = [:]
    
    static func configure(name: String, config: [String: Any]) throws {
        self.config = config
        
        // TODO: Evaluate post SPM and amplify migration if we need this.
        // Disabled this becuase I was getting strange CI test failures inside app sync NSNotification
        // handling code where notification.note was force cast and it failed. There may be some singleton issues
        // and it's possible multiple app sync clients are clashing. This isn't used so disabliong and dealing with
        // it later.
        
        //let client = try DefaultSudoUserClient(config: config, keyNamespace: name)
        //self.client = client
    }
    
}
