//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import SudoUser
import XCTest

class JSONSerializableObjectTests: XCTestCase {

    // MARK: - Tests

    func test_toData_willEncodeAndDecodeCorrectly() throws {
        // given
        let instanceUnderTest = JSONSerializableObject()
        instanceUnderTest.setProperty("Int", value: 1)
        instanceUnderTest.setProperty("Bool", value: true)
        instanceUnderTest.setProperty("String", value: "string")
        instanceUnderTest.setProperty("Date", value: Date(timeIntervalSince1970: 1))
        instanceUnderTest.setProperty("[Int]", value: [1, 2])
        instanceUnderTest.setProperty("[Bool]", value: [true, false])
        instanceUnderTest.setProperty("[String]", value: ["string1", "string2"])
        instanceUnderTest.setProperty("[Date]", value: [Date(timeIntervalSince1970: 1), Date(timeIntervalSince1970: 2)])
        instanceUnderTest.setProperty(
            "[SerializableObject]",
            value: [
                JSONSerializableObject(properties: ["String": "string1" as NSString, "Int": 1 as NSNumber ])!,
                JSONSerializableObject(properties: ["String": "string2" as NSString, "Int": 2 as NSNumber ])!
            ]
        )
        // when
        let data = try instanceUnderTest.toData()
        // then
        let newSo = try XCTUnwrap(JSONSerializableObject(data: data))
        XCTAssertEqual(1, newSo.getPropertyAsInt("Int"))
        XCTAssertEqual(true, newSo.getPropertyAsBool("Bool"))
        XCTAssertEqual("string", newSo.getPropertyAsString("String"))
        let date = try XCTUnwrap(newSo.getPropertyAsDate("Date"))
        XCTAssertEqual(Date(timeIntervalSince1970: 1).compare(date), .orderedSame)
        XCTAssertEqual([1, 2], newSo.getPropertyAsIntArray("[Int]"))
        XCTAssertEqual([true, false], newSo.getPropertyAsBoolArray("[Bool]"))
        XCTAssertEqual(["string1", "string2"], newSo.getPropertyAsStringArray("[String]"))
        XCTAssertEqual(
            [Date(timeIntervalSince1970: 1), Date(timeIntervalSince1970: 2)],
            newSo.getPropertyAsDateArray("[Date]")
        )
        XCTAssertEqual(
            [
                JSONSerializableObject(properties: ["String": "string1" as NSString, "Int": 1 as NSNumber])!,
                JSONSerializableObject(properties: ["String": "string2" as NSString, "Int": 2 as NSNumber])!
            ] as [JSONSerializableObject],
            newSo.getPropertyAsSerializableObjectArray("[SerializableObject]")
        )
    }
}
