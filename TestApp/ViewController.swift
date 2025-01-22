//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {

    @IBOutlet weak var federatedSignIn: UIButton!

    @IBOutlet weak var federatedSignOut: UIButton!

    var authSession: ASWebAuthenticationSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Perhaps I don't need the window object at all, and can just use:
        // return ASPresentationAnchor()
        return self.view.window!
    }

    @IBAction func federatedSignIn(_ sender: Any) {
        guard let client = SudoUserClientManager.client else {
            return
        }

        Task(priority: .medium) {
            do {
                let tokens = try await client.presentFederatedSignInUI(presentationAnchor: self.view.window!)
                NSLog("idToken: \(tokens.idToken)")
                NSLog("accessToken: \(tokens.accessToken)")
                NSLog("refreshToken: \(tokens.refreshToken)")
                NSLog("lifetime: \(tokens.lifetime)")
                
                DispatchQueue.main.async {
                    self.federatedSignIn.isEnabled = false
                }
            } catch {
                AlertManager.instance.alert(error: error)
            }
        }
    }

    @IBAction func federatedSignOut(_ sender: Any) {
        guard let client = SudoUserClientManager.client else {
            return
        }
        
        Task(priority: .medium) {
            do {
                
                try await client.presentFederatedSignOutUI(presentationAnchor: self.view.window!)
                DispatchQueue.main.async {
                    self.federatedSignIn.isEnabled = true
                }
            } catch {
                AlertManager.instance.alert(error: error)
            }
        }
    }

    @IBAction func idpSignOut(_ sender: Any) {
        self.authSession = ASWebAuthenticationSession(url: URL(string: "https://dev-98hbdgse.auth0.com/v2/logout")!, callbackURLScheme: nil, completionHandler: { (callBack:URL?, error:Error? ) in
            // Handle errors if you need to.
        })
        self.authSession?.presentationContextProvider = self
        self.authSession?.start()
    }
}

