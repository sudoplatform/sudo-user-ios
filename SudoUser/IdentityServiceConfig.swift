//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Entity representing the identity service configuration properties required by the `DefaultSudoUserClient`.
struct IdentityServiceConfig: Equatable {

    // MARK: - Properties

    /// AWS app client identifier.
    let clientId: String

    /// The endpoint URL for the identity service.
    let apiUrl: String

    /// AWS region hosting identity service as `String`.
    let region: String

    /// ID of AWS Cognito User Pool used by identity service.
    let poolId: String

    /// ID of AWS Cognito Identity Pool used by identity service.
    let identityPoolId: String

    /// Refresh token lifetime in days.
    let refreshTokenLifetime: Int

    /// Supported registration methods.
    let registrationMethods: [ChallengeType]
}

extension IdentityServiceConfig: Codable {

    // MARK: - Conformance: Decodable

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        clientId = try container.decode(String.self, forKey: .clientId)
        apiUrl = try container.decode(String.self, forKey: .apiUrl)
        region = try container.decode(String.self, forKey: .region)
        poolId = try container.decode(String.self, forKey: .poolId)
        identityPoolId = try container.decode(String.self, forKey: .identityPoolId)
        refreshTokenLifetime = try container.decodeIfPresent(Int.self, forKey: .refreshTokenLifetime) ?? 60
        registrationMethods = try container.decodeIfPresent([ChallengeType].self, forKey: .registrationMethods) ?? []
    }
}
