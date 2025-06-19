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

    @IBOutlet weak var privateFederatedSignIn: UIButton!

    @IBOutlet weak var federatedSignIn: UIButton!

    @IBOutlet weak var federatedSignOut: UIButton!

    @IBOutlet var idpSignOut: UIButton!

    // MARK: - Properties

    var authSession: ASWebAuthenticationSession?

    var client: SudoUserClient? { (UIApplication.shared.delegate as? AppDelegate)?.client }

    // MARK: - Conformance: ASWebAuthenticationPresentationContextProviding

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        view.window ?? ASPresentationAnchor()
    }

    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { @MainActor in
            await updateButtonStates()
        }
    }

    // MARK: - Actions

    @IBAction func privateFederatedSignIn(_ sender: Any) {
        Task { @MainActor in
            await presentFederatedSignIn(preferPrivateSession: true)
        }
    }

    @IBAction func federatedSignIn(_ sender: Any) {
        Task { @MainActor in
            await presentFederatedSignIn(preferPrivateSession: false)
        }
    }

    @IBAction func federatedSignOut(_ sender: Any) {
        Task { @MainActor in
            await presentFederatedSignOut()
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

    // MARK: - Helpers

    @MainActor func presentFederatedSignIn(preferPrivateSession: Bool) async {
        guard let client, let presentationAnchor = view.window else {
            return
        }
        privateFederatedSignIn.isEnabled = false
        federatedSignIn.isEnabled = false
        do {
            let tokens = try await client.presentFederatedSignInUI(
                presentationAnchor: presentationAnchor,
                preferPrivateSession: preferPrivateSession
            )
            AlertManager.instance.alert(
                message: "Sign In Success",
                title: "Access token: \(tokens.accessToken) \n ID token: \(tokens.idToken) \n Refresh token: \(tokens.refreshToken)"
            )
        } catch {
            AlertManager.instance.alert(error: error)
        }
        await updateButtonStates()
    }

    @MainActor func presentFederatedSignOut() async {
        guard let client, let presentationAnchor = view.window else {
            return
        }
        do {
            try await client.presentFederatedSignOutUI(presentationAnchor: presentationAnchor)
        } catch {
            AlertManager.instance.alert(error: error)
        }
        await updateButtonStates()
    }

    @MainActor func updateButtonStates() async {
        let isSignedIn = (try? await client?.isSignedIn()) ?? false
        federatedSignIn.isEnabled = !isSignedIn
        privateFederatedSignIn.isEnabled = !isSignedIn
        federatedSignOut.isEnabled = isSignedIn
        idpSignOut.isEnabled = isSignedIn
    }
}
