//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

enum Constants {

    enum Default {

        /// The default lifetime of the private key signed token used in the challenge response during sign in.
        static let signInTokenLifetime: TimeInterval = 300
    }

    enum ConfigurationNamespace {
        static let identityService = "identityService"
        static let federatedSignIn = "federatedSignIn"
    }

    enum KeyManager {
        static let defaultKeyManagerServiceName = "com.sudoplatform.appservicename"
        static let defaultKeyManagerKeyTag = "com.sudoplatform"
    }

    enum KeyName {
        static let userId = "userId"
        static let userKeyId = "userKeyId"
    }

    enum ValidationDataName {
        static let challengeType = "challengeType"
        static let answer = "answer"
        static let vendorId = "vendorId"
        static let publicKey = "publicKey"
        static let registrationId = "registrationId"
    }

    enum Limit {
        static let maxValidationDataSize = 2048
    }

    enum RegistrationParameter {
        static let challengeType = "challengeType"
        static let answer = "answer"
        static let answerMetadata = "answerMetadata"
        static let buildType = "buildType"
        static let deviceId = "deviceId"
        static let publicKey = "publicKey"
        static let registrationId = "registrationId"
    }

    enum CognitoChallengeParameter {
        static let audience = "audience"
        static let nonce = "nonce"
    }

    enum CognitoAuthenticationParameter {
        static let userName = "USERNAME"
        static let answer = "ANSWER"
        static let refreshToken = "REFRESH_TOKEN"
    }

    enum AuthenticationParameter {
        static let keyId = "keyId"
        static let tokenLifetime = "tokenLifetime"
        static let answer = "answer"
        static let challengeType = "challengeType"
    }
}
