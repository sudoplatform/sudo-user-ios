//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import UIKit

class AlertManager {

    static let instance = AlertManager()

    var alerts = Array<UIAlertController>()

    var presented = false

    func presentAlert(_ alert: UIAlertController) {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            if alert.actions.count == 0 {
                let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel) { (action: UIAlertAction) in
                    self.presented = false
                    if self.alerts.count > 0 {
                        if let alert = self.alerts.first {
                            self.alerts.remove(at: 0)
                            self.presentAlert(alert)
                        }
                    }
                }
                alert.addAction(dismissAction)
            }

            if presented {
                self.alerts.append(alert)
            } else {
                presented = true
                if let presentedViewController = rootViewController.presentedViewController {
                    DispatchQueue.main.async {
                        presentedViewController.present(alert, animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        rootViewController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func alert(function: String = #function, file: String = #file, line: Int = #line, error: Error) {
        self.presentAlert(UIAlertController(title: "Error", message: "\(file):\(function):\(line): \(error)", preferredStyle: .alert))
    }

    func alert(message: String, title: String = "Message") {
        self.presentAlert(UIAlertController(title: title, message: message, preferredStyle: .alert))
    }

}
