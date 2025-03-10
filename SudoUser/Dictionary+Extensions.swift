//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Dictionary where Value: Any {

    /// Intializes a new `Dictionary` instance from an array
    /// of name/value pairs.
    /// - Returns: A new initialized `Dictionary` instance.
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }

    /// Converts Dictionary to JSON data.
    /// - Returns: JSON data.
    func toJSONData() -> Data? {
        guard JSONSerialization.isValidJSONObject(self),
            let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }

        return data
    }

    /// Converts Dictionary to pretty formatted JSON data.
    /// - Returns: JSON data.
    func toJSONPrettyString() -> String? {
        guard JSONSerialization.isValidJSONObject(self),
            let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else {
            return nil
        }

        return String(data: data, encoding: String.Encoding.utf8)
    }

    /// Decodes the dictionary into a Codable-conforming type.
    ///
    /// This method first serializes the dictionary into `Data` using `JSONSerialization`,
    /// then decodes it using `JSONDecoder`. It returns `nil` if serialization or decoding fails.
    /// - Parameter type: The `Decodable` type to decode into.
    /// - Returns: An instance of the specified type if decoding succeeds, otherwise `nil`.
    func decoded<T: Decodable>(to type: T.Type) -> T? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
