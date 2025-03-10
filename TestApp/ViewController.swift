//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AuthenticationServices
import SudoUser
import UIKit

class ViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {

    // MARK: - Outlets

    @IBOutlet weak var federatedSignIn: UIButton!

    @IBOutlet weak var federatedSignOut: UIButton!

    // MARK: - Properties

    var authSession: ASWebAuthenticationSession?

    var client: SudoUserClient? { (UIApplication.shared.delegate as? AppDelegate)?.client }

    // MARK: - Conformance: ASWebAuthenticationPresentationContextProviding

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Perhaps I don't need the window object at all, and can just use:
        // return ASPresentationAnchor()
        return self.view.window!
    }

    // MARK: - Actions

    @IBAction func federatedSignIn(_ sender: Any) {
        guard let client, let presentationAnchor = view.window else {
            return
        }
        Task { @MainActor in
            do {
                let tokens = try await client.presentFederatedSignInUI(presentationAnchor: presentationAnchor)
                NSLog("idToken: \(tokens.idToken)")
                NSLog("accessToken: \(tokens.accessToken)")
                NSLog("refreshToken: \(tokens.refreshToken)")
                federatedSignIn.isEnabled = false
            } catch {
                AlertManager.instance.alert(error: error)
            }
        }
    }

    @IBAction func federatedSignOut(_ sender: Any) {
        guard let client, let presentationAnchor = view.window else {
            return
        }
        Task { @MainActor in
            do {
                try await client.presentFederatedSignOutUI(presentationAnchor: presentationAnchor)
                federatedSignIn.isEnabled = true
            } catch {
                AlertManager.instance.alert(error: error)
            }
        }
    }

    @IBAction func idpSignOut(_ sender: Any) {
        authSession = ASWebAuthenticationSession(
            url: URL(string: "https://dev-98hbdgse.auth0.com/v2/logout")!,
            callbackURLScheme: nil,
            completionHandler: { (callBack:URL?, error:Error? ) in
                // Handle errors if you need to.
            }
        )
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
}

