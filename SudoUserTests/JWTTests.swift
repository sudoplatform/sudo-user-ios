//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager
@testable import SudoUser
import XCTest

class JWTTests: XCTestCase {

    // MARK: - Tests

    func test_signAndEncode_willStoreValuesCorrectly() throws {
        // given
        let keyManager: SudoKeyManager = LegacySudoKeyManager(
            serviceName: "com.sudoplatform.appservicename",
            keyTag: "com.sudoplatform",
            namespace: "sudo"
        )
        let jwt = JWT(issuer: "dummy_issuer", audience: "dummy_audience", subject: "dummy_subject", id: "dummy_id")
        try keyManager.generateKeyPair("dummy_key_id")
        // when
        let token = try jwt.signAndEncode(keyManager: keyManager, keyId: "dummy_key_id")
        // then
        let result = try JWT(string: token, keyManager: keyManager)
        XCTAssertEqual("dummy_issuer", result.issuer)
        XCTAssertEqual("dummy_audience", result.audience)
        XCTAssertEqual("dummy_subject", result.subject)
        XCTAssertEqual("dummy_id", result.id)
    }
}
