//  This file was automatically generated and should not be edited.

import Amplify

struct RegisterFederatedIdInput: GraphQLMapConvertible {
  var graphQLMap: GraphQLMap

  init(idToken: String) {
    graphQLMap = ["idToken": idToken]
  }

  var idToken: String {
    get {
      return graphQLMap["idToken"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "idToken")
    }
  }
}

final class NotImplementedQuery: GraphQLQuery {
  static let operationString =
    "query NotImplemented($dummy: String!) {\n  notImplemented(dummy: $dummy)\n}"

  var dummy: String

  init(dummy: String) {
    self.dummy = dummy
  }

  var variables: GraphQLMap? {
    return ["dummy": dummy]
  }

  struct Data: GraphQLSelectionSet {
    static let possibleTypes = ["Query"]

    static let selections: [GraphQLSelection] = [
      GraphQLField("notImplemented", arguments: ["dummy": GraphQLVariable("dummy")], type: .scalar(Bool.self)),
    ]

    var snapshot: Snapshot

    init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    init(notImplemented: Bool? = nil) {
      self.init(snapshot: ["__typename": "Query", "notImplemented": notImplemented])
    }

    var notImplemented: Bool? {
      get {
        return snapshot["notImplemented"] as? Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "notImplemented")
      }
    }
  }
}

final class DeregisterMutation: GraphQLMutation {
  static let operationString =
    "mutation Deregister {\n  deregister {\n    __typename\n    success\n  }\n}"

  init() {
  }

  struct Data: GraphQLSelectionSet {
    static let possibleTypes = ["Mutation"]

    static let selections: [GraphQLSelection] = [
      GraphQLField("deregister", type: .object(Deregister.selections)),
    ]

    var snapshot: Snapshot

    init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    init(deregister: Deregister? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deregister": deregister.flatMap { $0.snapshot }])
    }

    var deregister: Deregister? {
      get {
        return (snapshot["deregister"] as? Snapshot).flatMap { Deregister(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deregister")
      }
    }

    struct Deregister: GraphQLSelectionSet {
      static let possibleTypes = ["Deregister"]

      static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      var snapshot: Snapshot

      init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      init(success: Bool) {
        self.init(snapshot: ["__typename": "Deregister", "success": success])
      }

      var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      var success: Bool {
        get {
          return snapshot["success"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

final class GlobalSignOutMutation: GraphQLMutation {
  static let operationString =
    "mutation GlobalSignOut {\n  globalSignOut {\n    __typename\n    success\n  }\n}"

  init() {
  }

  struct Data: GraphQLSelectionSet {
    static let possibleTypes = ["Mutation"]

    static let selections: [GraphQLSelection] = [
      GraphQLField("globalSignOut", type: .object(GlobalSignOut.selections)),
    ]

    var snapshot: Snapshot

    init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    init(globalSignOut: GlobalSignOut? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "globalSignOut": globalSignOut.flatMap { $0.snapshot }])
    }

    var globalSignOut: GlobalSignOut? {
      get {
        return (snapshot["globalSignOut"] as? Snapshot).flatMap { GlobalSignOut(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "globalSignOut")
      }
    }

    struct GlobalSignOut: GraphQLSelectionSet {
      static let possibleTypes = ["GlobalSignOut"]

      static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      var snapshot: Snapshot

      init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      init(success: Bool) {
        self.init(snapshot: ["__typename": "GlobalSignOut", "success": success])
      }

      var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      var success: Bool {
        get {
          return snapshot["success"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

final class ResetMutation: GraphQLMutation {
  static let operationString =
    "mutation Reset {\n  reset {\n    __typename\n    success\n  }\n}"

  init() {
  }

  struct Data: GraphQLSelectionSet {
    static let possibleTypes = ["Mutation"]

    static let selections: [GraphQLSelection] = [
      GraphQLField("reset", type: .object(Reset.selections)),
    ]

    var snapshot: Snapshot

    init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    init(reset: Reset? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "reset": reset.flatMap { $0.snapshot }])
    }

    var reset: Reset? {
      get {
        return (snapshot["reset"] as? Snapshot).flatMap { Reset(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "reset")
      }
    }

    struct Reset: GraphQLSelectionSet {
      static let possibleTypes = ["ApiResult"]

      static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      var snapshot: Snapshot

      init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      init(success: Bool) {
        self.init(snapshot: ["__typename": "ApiResult", "success": success])
      }

      var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      var success: Bool {
        get {
          return snapshot["success"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "success")
        }
      }
    }
  }
}

final class RegisterFederatedIdMutation: GraphQLMutation {
  static let operationString =
    "mutation RegisterFederatedId($input: RegisterFederatedIdInput) {\n  registerFederatedId(input: $input) {\n    __typename\n    identityId\n  }\n}"

  var input: RegisterFederatedIdInput?

  init(input: RegisterFederatedIdInput? = nil) {
    self.input = input
  }

  var variables: GraphQLMap? {
    return ["input": input]
  }

  struct Data: GraphQLSelectionSet {
    static let possibleTypes = ["Mutation"]

    static let selections: [GraphQLSelection] = [
      GraphQLField("registerFederatedId", arguments: ["input": GraphQLVariable("input")], type: .object(RegisterFederatedId.selections)),
    ]

    var snapshot: Snapshot

    init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    init(registerFederatedId: RegisterFederatedId? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "registerFederatedId": registerFederatedId.flatMap { $0.snapshot }])
    }

    var registerFederatedId: RegisterFederatedId? {
      get {
        return (snapshot["registerFederatedId"] as? Snapshot).flatMap { RegisterFederatedId(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "registerFederatedId")
      }
    }

    struct RegisterFederatedId: GraphQLSelectionSet {
      static let possibleTypes = ["FederatedId"]

      static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("identityId", type: .nonNull(.scalar(String.self))),
      ]

      var snapshot: Snapshot

      init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      init(identityId: String) {
        self.init(snapshot: ["__typename": "FederatedId", "identityId": identityId])
      }

      var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      var identityId: String {
        get {
          return snapshot["identityId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "identityId")
        }
      }
    }
  }
}
