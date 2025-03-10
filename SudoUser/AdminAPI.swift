//  This file was automatically generated and should not be edited.

import Amplify
import Foundation

protocol GraphQLInputValue {
}

struct GraphQLVariable {
  let name: String
  
  init(_ name: String) {
    self.name = name
  }
}

extension GraphQLVariable: GraphQLInputValue {
}

extension JSONEncodable {
  func evaluate(with variables: [String: JSONEncodable]?) throws -> Any {
    return jsonValue
  }
}

typealias GraphQLMap = [String: JSONEncodable?]

extension Dictionary where Key == String, Value == JSONEncodable? {
  var withNilValuesRemoved: Dictionary<String, JSONEncodable> {
    var filtered = Dictionary<String, JSONEncodable>(minimumCapacity: count)
    for (key, value) in self {
      if value != nil {
        filtered[key] = value
      }
    }
    return filtered
  }
}

protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

extension GraphQLMapConvertible {
  var jsonValue: Any {
    return graphQLMap.withNilValuesRemoved.jsonValue
  }
}

typealias GraphQLID = String

protocol APISwiftGraphQLOperation: AnyObject {
  
  static var operationString: String { get }
  static var requestString: String { get }
  static var operationIdentifier: String? { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

extension APISwiftGraphQLOperation {
  static var requestString: String {
    return operationString
  }

  static var operationIdentifier: String? {
    return nil
  }

  var variables: GraphQLMap? {
    return nil
  }
}

protocol GraphQLQuery: APISwiftGraphQLOperation {}

protocol GraphQLMutation: APISwiftGraphQLOperation {}

protocol GraphQLSubscription: APISwiftGraphQLOperation {}

protocol GraphQLFragment: GraphQLSelectionSet {
  static var possibleTypes: [String] { get }
}

typealias Snapshot = [String: Any?]

protocol GraphQLSelectionSet: Decodable {
  static var selections: [GraphQLSelection] { get }
  
  var snapshot: Snapshot { get }
  init(snapshot: Snapshot)
}

extension GraphQLSelectionSet {
    init(from decoder: Decoder) throws {
        if let jsonObject = try? APISwiftJSONValue(from: decoder) {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(jsonObject)
            let decodedDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
            let optionalDictionary = decodedDictionary.mapValues { $0 as Any? }

            self.init(snapshot: optionalDictionary)
        } else {
            self.init(snapshot: [:])
        }
    }
}

enum APISwiftJSONValue: Codable {
    case array([APISwiftJSONValue])
    case boolean(Bool)
    case number(Double)
    case object([String: APISwiftJSONValue])
    case string(String)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode([String: APISwiftJSONValue].self) {
            self = .object(value)
        } else if let value = try? container.decode([APISwiftJSONValue].self) {
            self = .array(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .boolean(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .array(let value):
            try container.encode(value)
        case .boolean(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

protocol GraphQLSelection {
}

struct GraphQLField: GraphQLSelection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?
  
  var responseKey: String {
    return alias ?? name
  }
  
  let type: GraphQLOutputType
  
  init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
  }
}

indirect enum GraphQLOutputType {
  case scalar(JSONDecodable.Type)
  case object([GraphQLSelection])
  case nonNull(GraphQLOutputType)
  case list(GraphQLOutputType)
  
  var namedType: GraphQLOutputType {
    switch self {
    case .nonNull(let innerType), .list(let innerType):
      return innerType.namedType
    case .scalar, .object:
      return self
    }
  }
}

struct GraphQLBooleanCondition: GraphQLSelection {
  let variableName: String
  let inverted: Bool
  let selections: [GraphQLSelection]
  
  init(variableName: String, inverted: Bool, selections: [GraphQLSelection]) {
    self.variableName = variableName
    self.inverted = inverted;
    self.selections = selections;
  }
}

struct GraphQLTypeCondition: GraphQLSelection {
  let possibleTypes: [String]
  let selections: [GraphQLSelection]
  
  init(possibleTypes: [String], selections: [GraphQLSelection]) {
    self.possibleTypes = possibleTypes
    self.selections = selections;
  }
}

struct GraphQLFragmentSpread: GraphQLSelection {
  let fragment: GraphQLFragment.Type
  
  init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}

struct GraphQLTypeCase: GraphQLSelection {
  let variants: [String: [GraphQLSelection]]
  let `default`: [GraphQLSelection]
  
  init(variants: [String: [GraphQLSelection]], default: [GraphQLSelection]) {
    self.variants = variants
    self.default = `default`;
  }
}

typealias JSONObject = [String: Any]

protocol JSONDecodable {
  init(jsonValue value: Any) throws
}

protocol JSONEncodable: GraphQLInputValue {
  var jsonValue: Any { get }
}

enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: Any, to: Any.Type)
  
  var errorDescription: String? {
    switch self {
    case .missingValue:
      return "Missing value"
    case .nullValue:
      return "Unexpected null value"
    case .wrongType:
      return "Wrong type"
    case .couldNotConvert(let value, let expectedType):
      return "Could not convert \"\(value)\" to \(expectedType)"
    }
  }
}

extension String: JSONDecodable, JSONEncodable {
  init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
    self = string
  }

  var jsonValue: Any {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  var jsonValue: Any {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  var jsonValue: Any {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  var jsonValue: Any {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  init(jsonValue value: Any) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  var jsonValue: Any {
    return self
  }
}

extension RawRepresentable where RawValue: JSONDecodable {
  init(jsonValue value: Any) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  var jsonValue: Any {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: JSONDecodable {
  init(jsonValue value: Any) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

extension Optional: JSONEncodable {
  var jsonValue: Any {
    switch self {
    case .none:
      return NSNull()
    case .some(let wrapped as JSONEncodable):
      return wrapped.jsonValue
    default:
      fatalError("Optional is only JSONEncodable if Wrapped is")
    }
  }
}

extension Dictionary: JSONEncodable {
  var jsonValue: Any {
    return jsonObject
  }
  
  var jsonObject: JSONObject {
    var jsonObject = JSONObject(minimumCapacity: count)
    for (key, value) in self {
      if case let (key as String, value as JSONEncodable) = (key, value) {
        jsonObject[key] = value.jsonValue
      } else {
        fatalError("Dictionary is only JSONEncodable if Value is (and if Key is String)")
      }
    }
    return jsonObject
  }
}

extension Array: JSONEncodable {
  var jsonValue: Any {
    return map() { element -> (Any) in
      if case let element as JSONEncodable = element {
        return element.jsonValue
      } else {
        fatalError("Array is only JSONEncodable if Element is")
      }
    }
  }
}

extension URL: JSONDecodable, JSONEncodable {
  init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    self.init(string: string)!
  }

  var jsonValue: Any {
    return self.absoluteString
  }
}

extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    lhs.merge(rhs) { (_, new) in new }
  }
}

struct WhitelistDeviceInput: GraphQLMapConvertible {
  var graphQLMap: GraphQLMap

  init(deviceId: String, type: String) {
    graphQLMap = ["deviceId": deviceId, "type": type]
  }

  var deviceId: String {
    get {
      return graphQLMap["deviceId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceId")
    }
  }

  var type: String {
    get {
      return graphQLMap["type"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

final class WhitelistDeviceMutation: GraphQLMutation {
  static let operationString =
    "mutation WhitelistDevice($input: WhitelistDeviceInput!) {\n  whitelistDevice(input: $input) {\n    __typename\n    deviceId\n    expiry\n  }\n}"

  var input: WhitelistDeviceInput

  init(input: WhitelistDeviceInput) {
    self.input = input
  }

  var variables: GraphQLMap? {
    return ["input": input]
  }

  struct Data: GraphQLSelectionSet {
    static let possibleTypes = ["Mutation"]

    static let selections: [GraphQLSelection] = [
      GraphQLField("whitelistDevice", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(WhitelistDevice.selections))),
    ]

    var snapshot: Snapshot

    init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    init(whitelistDevice: WhitelistDevice) {
      self.init(snapshot: ["__typename": "Mutation", "whitelistDevice": whitelistDevice.snapshot])
    }

    var whitelistDevice: WhitelistDevice {
      get {
        return WhitelistDevice(snapshot: snapshot["whitelistDevice"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "whitelistDevice")
      }
    }

    struct WhitelistDevice: GraphQLSelectionSet {
      static let possibleTypes = ["WhitelistDeviceStatus"]

      static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("deviceId", type: .nonNull(.scalar(String.self))),
        GraphQLField("expiry", type: .scalar(String.self)),
      ]

      var snapshot: Snapshot

      init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      init(deviceId: String, expiry: String? = nil) {
        self.init(snapshot: ["__typename": "WhitelistDeviceStatus", "deviceId": deviceId, "expiry": expiry])
      }

      var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      var deviceId: String {
        get {
          return snapshot["deviceId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "deviceId")
        }
      }

      var expiry: String? {
        get {
          return snapshot["expiry"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "expiry")
        }
      }
    }
  }
}
