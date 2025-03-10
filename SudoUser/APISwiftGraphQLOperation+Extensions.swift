//
// Copyright © 2023 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore
import Foundation

extension APISwiftGraphQLOperation {

    /// Will transform the type AppSync generated code to an Amplify GraphQL request.
    /// - Parameters:
    ///   - apiName: The service name.
    ///   - authorizationType: The type of authorization to use with the request.
    /// - Returns: A request to the GraphQL backed.
    func transformToGraphQLRequest(apiName: String) -> GraphQLRequest<Data> {
        let variablesDict = variables?.jsonValue as? [String: Any]
        return GraphQLRequest<Data>(
            apiName: apiName,
            document: Self.requestString,
            variables: variablesDict,
            responseType: Data.self,
            authMode: AWSAuthorizationType.openIDConnect
        )
    }
}
