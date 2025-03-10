//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension String {
    func chunks(size: Int) -> [String] {
        map { $0 }.chunks(size: size).compactMap { String($0) }
    }
}
