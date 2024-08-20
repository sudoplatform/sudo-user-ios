//  This file was automatically generated and should not be edited.

#if canImport(AWSAPIPlugin)
import Foundation

public protocol GraphQLInputValue {
}

public struct GraphQLVariable {
  let name: String
  
  public init(_ name: String) {
    self.name = name
  }
}

extension GraphQLVariable: GraphQLInputValue {
}

extension JSONEncodable {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> Any {
    return jsonValue
  }
}

public typealias GraphQLMap = [String: JSONEncodable?]

extension Dictionary where Key == String, Value == JSONEncodable? {
  public var withNilValuesRemoved: Dictionary<String, JSONEncodable> {
    var filtered = Dictionary<String, JSONEncodable>(minimumCapacity: count)
    for (key, value) in self {
      if value != nil {
        filtered[key] = value
      }
    }
    return filtered
  }
}

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

public extension GraphQLMapConvertible {
  var jsonValue: Any {
    return graphQLMap.withNilValuesRemoved.jsonValue
  }
}

public typealias GraphQLID = String

public protocol APISwiftGraphQLOperation: AnyObject {
  
  static var operationString: String { get }
  static var requestString: String { get }
  static var operationIdentifier: String? { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

public extension APISwiftGraphQLOperation {
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

public protocol GraphQLQuery: APISwiftGraphQLOperation {}

public protocol GraphQLMutation: APISwiftGraphQLOperation {}

public protocol GraphQLSubscription: APISwiftGraphQLOperation {}

public protocol GraphQLFragment: GraphQLSelectionSet {
  static var possibleTypes: [String] { get }
}

public typealias Snapshot = [String: Any?]

public protocol GraphQLSelectionSet: Decodable {
  static var selections: [GraphQLSelection] { get }
  
  var snapshot: Snapshot { get }
  init(snapshot: Snapshot)
}

extension GraphQLSelectionSet {
    public init(from decoder: Decoder) throws {
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

public protocol GraphQLSelection {
}

public struct GraphQLField: GraphQLSelection {
  let name: String
  let alias: String?
  let arguments: [String: GraphQLInputValue]?
  
  var responseKey: String {
    return alias ?? name
  }
  
  let type: GraphQLOutputType
  
  public init(_ name: String, alias: String? = nil, arguments: [String: GraphQLInputValue]? = nil, type: GraphQLOutputType) {
    self.name = name
    self.alias = alias
    
    self.arguments = arguments
    
    self.type = type
  }
}

public indirect enum GraphQLOutputType {
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

public struct GraphQLBooleanCondition: GraphQLSelection {
  let variableName: String
  let inverted: Bool
  let selections: [GraphQLSelection]
  
  public init(variableName: String, inverted: Bool, selections: [GraphQLSelection]) {
    self.variableName = variableName
    self.inverted = inverted;
    self.selections = selections;
  }
}

public struct GraphQLTypeCondition: GraphQLSelection {
  let possibleTypes: [String]
  let selections: [GraphQLSelection]
  
  public init(possibleTypes: [String], selections: [GraphQLSelection]) {
    self.possibleTypes = possibleTypes
    self.selections = selections;
  }
}

public struct GraphQLFragmentSpread: GraphQLSelection {
  let fragment: GraphQLFragment.Type
  
  public init(_ fragment: GraphQLFragment.Type) {
    self.fragment = fragment
  }
}

public struct GraphQLTypeCase: GraphQLSelection {
  let variants: [String: [GraphQLSelection]]
  let `default`: [GraphQLSelection]
  
  public init(variants: [String: [GraphQLSelection]], default: [GraphQLSelection]) {
    self.variants = variants
    self.default = `default`;
  }
}

public typealias JSONObject = [String: Any]

public protocol JSONDecodable {
  init(jsonValue value: Any) throws
}

public protocol JSONEncodable: GraphQLInputValue {
  var jsonValue: Any { get }
}

public enum JSONDecodingError: Error, LocalizedError {
  case missingValue
  case nullValue
  case wrongType
  case couldNotConvert(value: Any, to: Any.Type)
  
  public var errorDescription: String? {
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
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: String.self)
    }
    self = string
  }

  public var jsonValue: Any {
    return self
  }
}

extension Int: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Int.self)
    }
    self = number.intValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Float: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Float.self)
    }
    self = number.floatValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Double: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let number = value as? NSNumber else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Double.self)
    }
    self = number.doubleValue
  }

  public var jsonValue: Any {
    return self
  }
}

extension Bool: JSONDecodable, JSONEncodable {
  public init(jsonValue value: Any) throws {
    guard let bool = value as? Bool else {
        throw JSONDecodingError.couldNotConvert(value: value, to: Bool.self)
    }
    self = bool
  }

  public var jsonValue: Any {
    return self
  }
}

extension RawRepresentable where RawValue: JSONDecodable {
  public init(jsonValue value: Any) throws {
    let rawValue = try RawValue(jsonValue: value)
    if let tempSelf = Self(rawValue: rawValue) {
      self = tempSelf
    } else {
      throw JSONDecodingError.couldNotConvert(value: value, to: Self.self)
    }
  }
}

extension RawRepresentable where RawValue: JSONEncodable {
  public var jsonValue: Any {
    return rawValue.jsonValue
  }
}

extension Optional where Wrapped: JSONDecodable {
  public init(jsonValue value: Any) throws {
    if value is NSNull {
      self = .none
    } else {
      self = .some(try Wrapped(jsonValue: value))
    }
  }
}

extension Optional: JSONEncodable {
  public var jsonValue: Any {
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
  public var jsonValue: Any {
    return jsonObject
  }
  
  public var jsonObject: JSONObject {
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
  public var jsonValue: Any {
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
  public init(jsonValue value: Any) throws {
    guard let string = value as? String else {
      throw JSONDecodingError.couldNotConvert(value: value, to: URL.self)
    }
    self.init(string: string)!
  }

  public var jsonValue: Any {
    return self.absoluteString
  }
}

extension Dictionary {
  static func += (lhs: inout Dictionary, rhs: Dictionary) {
    lhs.merge(rhs) { (_, new) in new }
  }
}

#elseif canImport(AWSAppSync)
import AWSAppSync
#endif

public struct AddEntitlementsSetInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String, description: String? = nil, entitlements: [EntitlementInput]) {
    graphQLMap = ["name": name, "description": description, "entitlements": entitlements]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var entitlements: [EntitlementInput] {
    get {
      return graphQLMap["entitlements"] as! [EntitlementInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "entitlements")
    }
  }
}

public struct EntitlementInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String, description: String? = nil, value: Int) {
    graphQLMap = ["name": name, "description": description, "value": value]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var value: Int {
    get {
      return graphQLMap["value"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "value")
    }
  }
}

public struct SetEntitlementsSetInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String, description: String? = nil, entitlements: [EntitlementInput]) {
    graphQLMap = ["name": name, "description": description, "entitlements": entitlements]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var entitlements: [EntitlementInput] {
    get {
      return graphQLMap["entitlements"] as! [EntitlementInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "entitlements")
    }
  }
}

public struct RemoveEntitlementsSetInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String) {
    graphQLMap = ["name": name]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }
}

public struct AddEntitlementsSequenceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String, description: String? = nil, transitions: [EntitlementsSequenceTransitionInput]) {
    graphQLMap = ["name": name, "description": description, "transitions": transitions]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var transitions: [EntitlementsSequenceTransitionInput] {
    get {
      return graphQLMap["transitions"] as! [EntitlementsSequenceTransitionInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "transitions")
    }
  }
}

public struct EntitlementsSequenceTransitionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(entitlementsSetName: String, duration: String? = nil) {
    graphQLMap = ["entitlementsSetName": entitlementsSetName, "duration": duration]
  }

  public var entitlementsSetName: String {
    get {
      return graphQLMap["entitlementsSetName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "entitlementsSetName")
    }
  }

  public var duration: String? {
    get {
      return graphQLMap["duration"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "duration")
    }
  }
}

public struct SetEntitlementsSequenceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String, description: String? = nil, transitions: [EntitlementsSequenceTransitionInput]) {
    graphQLMap = ["name": name, "description": description, "transitions": transitions]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }

  public var description: String? {
    get {
      return graphQLMap["description"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "description")
    }
  }

  public var transitions: [EntitlementsSequenceTransitionInput] {
    get {
      return graphQLMap["transitions"] as! [EntitlementsSequenceTransitionInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "transitions")
    }
  }
}

public struct RemoveEntitlementsSequenceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String) {
    graphQLMap = ["name": name]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }
}

public struct ApplyEntitlementsSetToUsersInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(operations: [ApplyEntitlementsSetToUserInput]) {
    graphQLMap = ["operations": operations]
  }

  public var operations: [ApplyEntitlementsSetToUserInput] {
    get {
      return graphQLMap["operations"] as! [ApplyEntitlementsSetToUserInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "operations")
    }
  }
}

public struct ApplyEntitlementsSetToUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(externalId: String, entitlementsSetName: String) {
    graphQLMap = ["externalId": externalId, "entitlementsSetName": entitlementsSetName]
  }

  public var externalId: String {
    get {
      return graphQLMap["externalId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "externalId")
    }
  }

  public var entitlementsSetName: String {
    get {
      return graphQLMap["entitlementsSetName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "entitlementsSetName")
    }
  }
}

public enum AccountStates: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case active
  case locked
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ACTIVE": self = .active
      case "LOCKED": self = .locked
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .active: return "ACTIVE"
      case .locked: return "LOCKED"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: AccountStates, rhs: AccountStates) -> Bool {
    switch (lhs, rhs) {
      case (.active, .active): return true
      case (.locked, .locked): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct ApplyEntitlementsSequenceToUsersInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(operations: [ApplyEntitlementsSequenceToUserInput]) {
    graphQLMap = ["operations": operations]
  }

  public var operations: [ApplyEntitlementsSequenceToUserInput] {
    get {
      return graphQLMap["operations"] as! [ApplyEntitlementsSequenceToUserInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "operations")
    }
  }
}

public struct ApplyEntitlementsSequenceToUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(externalId: String, entitlementsSequenceName: String, transitionsRelativeToEpochMs: Double? = nil) {
    graphQLMap = ["externalId": externalId, "entitlementsSequenceName": entitlementsSequenceName, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs]
  }

  public var externalId: String {
    get {
      return graphQLMap["externalId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "externalId")
    }
  }

  public var entitlementsSequenceName: String {
    get {
      return graphQLMap["entitlementsSequenceName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "entitlementsSequenceName")
    }
  }

  public var transitionsRelativeToEpochMs: Double? {
    get {
      return graphQLMap["transitionsRelativeToEpochMs"] as! Double?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
    }
  }
}

public struct ApplyEntitlementsToUsersInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(operations: [ApplyEntitlementsToUserInput]) {
    graphQLMap = ["operations": operations]
  }

  public var operations: [ApplyEntitlementsToUserInput] {
    get {
      return graphQLMap["operations"] as! [ApplyEntitlementsToUserInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "operations")
    }
  }
}

public struct ApplyEntitlementsToUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(externalId: String, entitlements: [EntitlementInput]) {
    graphQLMap = ["externalId": externalId, "entitlements": entitlements]
  }

  public var externalId: String {
    get {
      return graphQLMap["externalId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "externalId")
    }
  }

  public var entitlements: [EntitlementInput] {
    get {
      return graphQLMap["entitlements"] as! [EntitlementInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "entitlements")
    }
  }
}

public struct ApplyExpendableEntitlementsToUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(externalId: String, expendableEntitlements: [EntitlementInput], requestId: GraphQLID) {
    graphQLMap = ["externalId": externalId, "expendableEntitlements": expendableEntitlements, "requestId": requestId]
  }

  public var externalId: String {
    get {
      return graphQLMap["externalId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "externalId")
    }
  }

  public var expendableEntitlements: [EntitlementInput] {
    get {
      return graphQLMap["expendableEntitlements"] as! [EntitlementInput]
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expendableEntitlements")
    }
  }

  public var requestId: GraphQLID {
    get {
      return graphQLMap["requestId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requestId")
    }
  }
}

public struct RemoveEntitledUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(externalId: String) {
    graphQLMap = ["externalId": externalId]
  }

  public var externalId: String {
    get {
      return graphQLMap["externalId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "externalId")
    }
  }
}

public struct ExpireEncryptedBlobRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct DeleteUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(username: String) {
    graphQLMap = ["username": username]
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }
}

public struct ResetUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(username: String) {
    graphQLMap = ["username": username]
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }
}

public struct DisableUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(username: String) {
    graphQLMap = ["username": username]
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }
}

public struct EnableUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(username: String) {
    graphQLMap = ["username": username]
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }
}

public struct DeviceCheckInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(token: String, buildType: String) {
    graphQLMap = ["token": token, "buildType": buildType]
  }

  public var token: String {
    get {
      return graphQLMap["token"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "token")
    }
  }

  public var buildType: String {
    get {
      return graphQLMap["buildType"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "buildType")
    }
  }
}

public struct WhitelistDeviceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(deviceId: String, type: String) {
    graphQLMap = ["deviceId": deviceId, "type": type]
  }

  public var deviceId: String {
    get {
      return graphQLMap["deviceId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceId")
    }
  }

  public var type: String {
    get {
      return graphQLMap["type"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

public struct DeviceCheckKeyInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(issuer: String, keyId: String, privateKey: String) {
    graphQLMap = ["issuer": issuer, "keyId": keyId, "privateKey": privateKey]
  }

  public var issuer: String {
    get {
      return graphQLMap["issuer"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "issuer")
    }
  }

  public var keyId: String {
    get {
      return graphQLMap["keyId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "keyId")
    }
  }

  public var privateKey: String {
    get {
      return graphQLMap["privateKey"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "privateKey")
    }
  }
}

public struct UploadPlayIntegrityKeyInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(key: String) {
    graphQLMap = ["key": key]
  }

  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }
}

public struct UploadSigningCertificateFingerprintInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(fingerprint: String, friendlyName: String) {
    graphQLMap = ["fingerprint": fingerprint, "friendlyName": friendlyName]
  }

  public var fingerprint: String {
    get {
      return graphQLMap["fingerprint"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "fingerprint")
    }
  }

  public var friendlyName: String {
    get {
      return graphQLMap["friendlyName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "friendlyName")
    }
  }
}

public struct DeleteSigningCertificateFingerprintInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(fingerprint: String) {
    graphQLMap = ["fingerprint": fingerprint]
  }

  public var fingerprint: String {
    get {
      return graphQLMap["fingerprint"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "fingerprint")
    }
  }
}

public struct RevokeTestRegistrationKeyInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: String) {
    graphQLMap = ["id": id]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct UploadTrustedIssuerKeyInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: String, issuer: String, label: String, key: String) {
    graphQLMap = ["id": id, "issuer": issuer, "label": label, "key": key]
  }

  public var id: String {
    get {
      return graphQLMap["id"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }

  public var issuer: String {
    get {
      return graphQLMap["issuer"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "issuer")
    }
  }

  public var label: String {
    get {
      return graphQLMap["label"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "label")
    }
  }

  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }
}

public struct ChangeOwnerInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(fromUsername: String, toUsername: String) {
    graphQLMap = ["fromUsername": fromUsername, "toUsername": toUsername]
  }

  public var fromUsername: String {
    get {
      return graphQLMap["fromUsername"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "fromUsername")
    }
  }

  public var toUsername: String {
    get {
      return graphQLMap["toUsername"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "toUsername")
    }
  }
}

public struct ResetIdentityVerificationStatusRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ownerToReset: String, requiredVerificationMethod: String) {
    graphQLMap = ["ownerToReset": ownerToReset, "requiredVerificationMethod": requiredVerificationMethod]
  }

  public var ownerToReset: String {
    get {
      return graphQLMap["ownerToReset"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ownerToReset")
    }
  }

  public var requiredVerificationMethod: String {
    get {
      return graphQLMap["requiredVerificationMethod"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "requiredVerificationMethod")
    }
  }
}

public struct SetIdentityDocumentInfoRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ownerToUpdate: String, firstName: String, lastName: String, address: String? = nil, city: String? = nil, state: String? = nil, postalCode: String? = nil, country: String, dateOfBirth: String, documentType: String, documentStateOfIssuance: String? = nil, documentCountryOfIssuance: String, documentNumber: String, documentExpirationDate: String, verified: Bool, retryBlocked: Bool) {
    graphQLMap = ["ownerToUpdate": ownerToUpdate, "firstName": firstName, "lastName": lastName, "address": address, "city": city, "state": state, "postalCode": postalCode, "country": country, "dateOfBirth": dateOfBirth, "documentType": documentType, "documentStateOfIssuance": documentStateOfIssuance, "documentCountryOfIssuance": documentCountryOfIssuance, "documentNumber": documentNumber, "documentExpirationDate": documentExpirationDate, "verified": verified, "retryBlocked": retryBlocked]
  }

  public var ownerToUpdate: String {
    get {
      return graphQLMap["ownerToUpdate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ownerToUpdate")
    }
  }

  public var firstName: String {
    get {
      return graphQLMap["firstName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var lastName: String {
    get {
      return graphQLMap["lastName"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lastName")
    }
  }

  public var address: String? {
    get {
      return graphQLMap["address"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var city: String? {
    get {
      return graphQLMap["city"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var state: String? {
    get {
      return graphQLMap["state"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "state")
    }
  }

  public var postalCode: String? {
    get {
      return graphQLMap["postalCode"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postalCode")
    }
  }

  public var country: String {
    get {
      return graphQLMap["country"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "country")
    }
  }

  public var dateOfBirth: String {
    get {
      return graphQLMap["dateOfBirth"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "dateOfBirth")
    }
  }

  public var documentType: String {
    get {
      return graphQLMap["documentType"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "documentType")
    }
  }

  public var documentStateOfIssuance: String? {
    get {
      return graphQLMap["documentStateOfIssuance"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "documentStateOfIssuance")
    }
  }

  public var documentCountryOfIssuance: String {
    get {
      return graphQLMap["documentCountryOfIssuance"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "documentCountryOfIssuance")
    }
  }

  public var documentNumber: String {
    get {
      return graphQLMap["documentNumber"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "documentNumber")
    }
  }

  public var documentExpirationDate: String {
    get {
      return graphQLMap["documentExpirationDate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "documentExpirationDate")
    }
  }

  public var verified: Bool {
    get {
      return graphQLMap["verified"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "verified")
    }
  }

  public var retryBlocked: Bool {
    get {
      return graphQLMap["retryBlocked"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "retryBlocked")
    }
  }
}

public struct AssistIdentityVerificationRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ownerToAssist: String, dobIssue: Bool) {
    graphQLMap = ["ownerToAssist": ownerToAssist, "dobIssue": dobIssue]
  }

  public var ownerToAssist: String {
    get {
      return graphQLMap["ownerToAssist"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ownerToAssist")
    }
  }

  public var dobIssue: Bool {
    get {
      return graphQLMap["dobIssue"] as! Bool
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "dobIssue")
    }
  }
}

public struct NotificationProviderInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(bundleId: String, appName: String? = nil, platform: platformProviderType, notificationType: notificationType, principal: String? = nil, credentials: String? = nil) {
    graphQLMap = ["bundleId": bundleId, "appName": appName, "platform": platform, "notificationType": notificationType, "principal": principal, "credentials": credentials]
  }

  public var bundleId: String {
    get {
      return graphQLMap["bundleId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bundleId")
    }
  }

  public var appName: String? {
    get {
      return graphQLMap["appName"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appName")
    }
  }

  public var platform: platformProviderType {
    get {
      return graphQLMap["platform"] as! platformProviderType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "platform")
    }
  }

  public var notificationType: notificationType {
    get {
      return graphQLMap["notificationType"] as! notificationType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notificationType")
    }
  }

  public var principal: String? {
    get {
      return graphQLMap["principal"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "principal")
    }
  }

  public var credentials: String? {
    get {
      return graphQLMap["credentials"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "credentials")
    }
  }
}

public enum platformProviderType: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case apns
  case apnsSandbox
  case apnsVoip
  case apnsVoipSandbox
  case gcm
  case test
  case webhook
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "APNS": self = .apns
      case "APNS_SANDBOX": self = .apnsSandbox
      case "APNS_VOIP": self = .apnsVoip
      case "APNS_VOIP_SANDBOX": self = .apnsVoipSandbox
      case "GCM": self = .gcm
      case "TEST": self = .test
      case "WEBHOOK": self = .webhook
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .apns: return "APNS"
      case .apnsSandbox: return "APNS_SANDBOX"
      case .apnsVoip: return "APNS_VOIP"
      case .apnsVoipSandbox: return "APNS_VOIP_SANDBOX"
      case .gcm: return "GCM"
      case .test: return "TEST"
      case .webhook: return "WEBHOOK"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: platformProviderType, rhs: platformProviderType) -> Bool {
    switch (lhs, rhs) {
      case (.apns, .apns): return true
      case (.apnsSandbox, .apnsSandbox): return true
      case (.apnsVoip, .apnsVoip): return true
      case (.apnsVoipSandbox, .apnsVoipSandbox): return true
      case (.gcm, .gcm): return true
      case (.test, .test): return true
      case (.webhook, .webhook): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum notificationType: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case standard
  case voip
  case both
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "STANDARD": self = .standard
      case "VOIP": self = .voip
      case "BOTH": self = .both
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .standard: return "STANDARD"
      case .voip: return "VOIP"
      case .both: return "BOTH"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: notificationType, rhs: notificationType) -> Bool {
    switch (lhs, rhs) {
      case (.standard, .standard): return true
      case (.voip, .voip): return true
      case (.both, .both): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct UseNotificationProviderInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(bundleId: String, appName: String? = nil, platform: platformProviderType, notificationType: notificationType, providerArn: String) {
    graphQLMap = ["bundleId": bundleId, "appName": appName, "platform": platform, "notificationType": notificationType, "providerArn": providerArn]
  }

  public var bundleId: String {
    get {
      return graphQLMap["bundleId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bundleId")
    }
  }

  public var appName: String? {
    get {
      return graphQLMap["appName"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "appName")
    }
  }

  public var platform: platformProviderType {
    get {
      return graphQLMap["platform"] as! platformProviderType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "platform")
    }
  }

  public var notificationType: notificationType {
    get {
      return graphQLMap["notificationType"] as! notificationType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notificationType")
    }
  }

  public var providerArn: String {
    get {
      return graphQLMap["providerArn"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "providerArn")
    }
  }
}

public struct DeleteNotificationProviderInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(bundleId: String, platform: platformProviderType, notificationType: notificationType) {
    graphQLMap = ["bundleId": bundleId, "platform": platform, "notificationType": notificationType]
  }

  public var bundleId: String {
    get {
      return graphQLMap["bundleId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bundleId")
    }
  }

  public var platform: platformProviderType {
    get {
      return graphQLMap["platform"] as! platformProviderType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "platform")
    }
  }

  public var notificationType: notificationType {
    get {
      return graphQLMap["notificationType"] as! notificationType
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "notificationType")
    }
  }
}

public struct DeregisterAppOnDeviceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(userId: String, bundleId: String, deviceId: String) {
    graphQLMap = ["userId": userId, "bundleId": bundleId, "deviceId": deviceId]
  }

  public var userId: String {
    get {
      return graphQLMap["userId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }

  public var bundleId: String {
    get {
      return graphQLMap["bundleId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "bundleId")
    }
  }

  public var deviceId: String {
    get {
      return graphQLMap["deviceId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceId")
    }
  }
}

public struct UploadSudoOwnershipProofPublicKeyInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(issuer: String, kid: String, key: String) {
    graphQLMap = ["issuer": issuer, "kid": kid, "key": key]
  }

  public var issuer: String {
    get {
      return graphQLMap["issuer"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "issuer")
    }
  }

  public var kid: String {
    get {
      return graphQLMap["kid"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "kid")
    }
  }

  public var key: String {
    get {
      return graphQLMap["key"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "key")
    }
  }
}

public struct AcceptPendingFundingSourceRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public enum CardState: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case issued
  case failed
  case closed
  case suspended
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ISSUED": self = .issued
      case "FAILED": self = .failed
      case "CLOSED": self = .closed
      case "SUSPENDED": self = .suspended
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .issued: return "ISSUED"
      case .failed: return "FAILED"
      case .closed: return "CLOSED"
      case .suspended: return "SUSPENDED"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: CardState, rhs: CardState) -> Bool {
    switch (lhs, rhs) {
      case (.issued, .issued): return true
      case (.failed, .failed): return true
      case (.closed, .closed): return true
      case (.suspended, .suspended): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum StateReason: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case user
  case admin
  case entitlement
  case locked
  case unlocked
  case suspicious
  case processing
  case deletion
  case unknown
  /// Auto generated constant for unknown enum values
  // case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "USER": self = .user
      case "ADMIN": self = .admin
      case "ENTITLEMENT": self = .entitlement
      case "LOCKED": self = .locked
      case "UNLOCKED": self = .unlocked
      case "SUSPICIOUS": self = .suspicious
      case "PROCESSING": self = .processing
      case "DELETION": self = .deletion
      case "UNKNOWN": self = .unknown
      default: self = .unknown
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .user: return "USER"
      case .admin: return "ADMIN"
      case .entitlement: return "ENTITLEMENT"
      case .locked: return "LOCKED"
      case .unlocked: return "UNLOCKED"
      case .suspicious: return "SUSPICIOUS"
      case .processing: return "PROCESSING"
      case .deletion: return "DELETION"
      case .unknown: return "UNKNOWN"
      // case .unknown(let value): return value
    }
  }

  public static func == (lhs: StateReason, rhs: StateReason) -> Bool {
    switch (lhs, rhs) {
      case (.user, .user): return true
      case (.admin, .admin): return true
      case (.entitlement, .entitlement): return true
      case (.locked, .locked): return true
      case (.unlocked, .unlocked): return true
      case (.suspicious, .suspicious): return true
      case (.processing, .processing): return true
      case (.deletion, .deletion): return true
      case (.unknown, .unknown): return true
      // case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum FundingSourceState: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case active
  case inactive
  case refresh
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ACTIVE": self = .active
      case "INACTIVE": self = .inactive
      case "REFRESH": self = .refresh
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .active: return "ACTIVE"
      case .inactive: return "INACTIVE"
      case .refresh: return "REFRESH"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: FundingSourceState, rhs: FundingSourceState) -> Bool {
    switch (lhs, rhs) {
      case (.active, .active): return true
      case (.inactive, .inactive): return true
      case (.refresh, .refresh): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum BankAccountType: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case savings
  case checking
  case other
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "SAVINGS": self = .savings
      case "CHECKING": self = .checking
      case "OTHER": self = .other
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .savings: return "SAVINGS"
      case .checking: return "CHECKING"
      case .other: return "OTHER"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: BankAccountType, rhs: BankAccountType) -> Bool {
    switch (lhs, rhs) {
      case (.savings, .savings): return true
      case (.checking, .checking): return true
      case (.other, .other): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum CardType: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case credit
  case debit
  case prepaid
  case other
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "CREDIT": self = .credit
      case "DEBIT": self = .debit
      case "PREPAID": self = .prepaid
      case "OTHER": self = .other
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .credit: return "CREDIT"
      case .debit: return "DEBIT"
      case .prepaid: return "PREPAID"
      case .other: return "OTHER"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: CardType, rhs: CardType) -> Bool {
    switch (lhs, rhs) {
      case (.credit, .credit): return true
      case (.debit, .debit): return true
      case (.prepaid, .prepaid): return true
      case (.other, .other): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public enum CreditCardNetwork: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case amex
  case diners
  case discover
  case jcb
  case mastercard
  case unionpay
  case visa
  case other
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "AMEX": self = .amex
      case "DINERS": self = .diners
      case "DISCOVER": self = .discover
      case "JCB": self = .jcb
      case "MASTERCARD": self = .mastercard
      case "UNIONPAY": self = .unionpay
      case "VISA": self = .visa
      case "OTHER": self = .other
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .amex: return "AMEX"
      case .diners: return "DINERS"
      case .discover: return "DISCOVER"
      case .jcb: return "JCB"
      case .mastercard: return "MASTERCARD"
      case .unionpay: return "UNIONPAY"
      case .visa: return "VISA"
      case .other: return "OTHER"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: CreditCardNetwork, rhs: CreditCardNetwork) -> Bool {
    switch (lhs, rhs) {
      case (.amex, .amex): return true
      case (.diners, .diners): return true
      case (.discover, .discover): return true
      case (.jcb, .jcb): return true
      case (.mastercard, .mastercard): return true
      case (.unionpay, .unionpay): return true
      case (.visa, .visa): return true
      case (.other, .other): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct CancelFundingSourceRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(id: GraphQLID) {
    graphQLMap = ["id": id]
  }

  public var id: GraphQLID {
    get {
      return graphQLMap["id"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "id")
    }
  }
}

public struct ChargeServiceFeeForVirtualCardInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(feeReason: FeeReason, causeId: String, amount: UserCurrencyAmountInput) {
    graphQLMap = ["feeReason": feeReason, "causeId": causeId, "amount": amount]
  }

  public var feeReason: FeeReason {
    get {
      return graphQLMap["feeReason"] as! FeeReason
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "feeReason")
    }
  }

  public var causeId: String {
    get {
      return graphQLMap["causeId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "causeId")
    }
  }

  public var amount: UserCurrencyAmountInput {
    get {
      return graphQLMap["amount"] as! UserCurrencyAmountInput
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }
}

public enum FeeReason: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case insufficientFunds
  case fundingAccountClosed
  case fundingDispute
  case virtualCardDispute
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "INSUFFICIENT_FUNDS": self = .insufficientFunds
      case "FUNDING_ACCOUNT_CLOSED": self = .fundingAccountClosed
      case "FUNDING_DISPUTE": self = .fundingDispute
      case "VIRTUAL_CARD_DISPUTE": self = .virtualCardDispute
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .insufficientFunds: return "INSUFFICIENT_FUNDS"
      case .fundingAccountClosed: return "FUNDING_ACCOUNT_CLOSED"
      case .fundingDispute: return "FUNDING_DISPUTE"
      case .virtualCardDispute: return "VIRTUAL_CARD_DISPUTE"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: FeeReason, rhs: FeeReason) -> Bool {
    switch (lhs, rhs) {
      case (.insufficientFunds, .insufficientFunds): return true
      case (.fundingAccountClosed, .fundingAccountClosed): return true
      case (.fundingDispute, .fundingDispute): return true
      case (.virtualCardDispute, .virtualCardDispute): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct UserCurrencyAmountInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(currency: String, amount: Double) {
    graphQLMap = ["currency": currency, "amount": amount]
  }

  public var currency: String {
    get {
      return graphQLMap["currency"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "currency")
    }
  }

  public var amount: Double {
    get {
      return graphQLMap["amount"] as! Double
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }
}

public enum TransactionType: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case pending
  case complete
  case reversal
  case refund
  case decline
  case chargeback
  case fee
  case feeRefund
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "PENDING": self = .pending
      case "COMPLETE": self = .complete
      case "REVERSAL": self = .reversal
      case "REFUND": self = .refund
      case "DECLINE": self = .decline
      case "CHARGEBACK": self = .chargeback
      case "FEE": self = .fee
      case "FEE_REFUND": self = .feeRefund
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .pending: return "PENDING"
      case .complete: return "COMPLETE"
      case .reversal: return "REVERSAL"
      case .refund: return "REFUND"
      case .decline: return "DECLINE"
      case .chargeback: return "CHARGEBACK"
      case .fee: return "FEE"
      case .feeRefund: return "FEE_REFUND"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: TransactionType, rhs: TransactionType) -> Bool {
    switch (lhs, rhs) {
      case (.pending, .pending): return true
      case (.complete, .complete): return true
      case (.reversal, .reversal): return true
      case (.refund, .refund): return true
      case (.decline, .decline): return true
      case (.chargeback, .chargeback): return true
      case (.fee, .fee): return true
      case (.feeRefund, .feeRefund): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct RefundServiceFeeForVirtualCardInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(feeId: String, amount: UserCurrencyAmountInput) {
    graphQLMap = ["feeId": feeId, "amount": amount]
  }

  public var feeId: String {
    get {
      return graphQLMap["feeId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "feeId")
    }
  }

  public var amount: UserCurrencyAmountInput {
    get {
      return graphQLMap["amount"] as! UserCurrencyAmountInput
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }
}

public struct SimulateAuthorizationRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(pan: String, amount: Int, merchantId: GraphQLID, expiry: ExpiryInput, billingAddress: EnteredAddressInput? = nil, csc: String? = nil) {
    graphQLMap = ["pan": pan, "amount": amount, "merchantId": merchantId, "expiry": expiry, "billingAddress": billingAddress, "csc": csc]
  }

  public var pan: String {
    get {
      return graphQLMap["pan"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "pan")
    }
  }

  public var amount: Int {
    get {
      return graphQLMap["amount"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var merchantId: GraphQLID {
    get {
      return graphQLMap["merchantId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "merchantId")
    }
  }

  public var expiry: ExpiryInput {
    get {
      return graphQLMap["expiry"] as! ExpiryInput
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "expiry")
    }
  }

  public var billingAddress: EnteredAddressInput? {
    get {
      return graphQLMap["billingAddress"] as! EnteredAddressInput?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "billingAddress")
    }
  }

  public var csc: String? {
    get {
      return graphQLMap["csc"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "csc")
    }
  }
}

public struct ExpiryInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(mm: Int, yyyy: Int) {
    graphQLMap = ["mm": mm, "yyyy": yyyy]
  }

  public var mm: Int {
    get {
      return graphQLMap["mm"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "mm")
    }
  }

  public var yyyy: Int {
    get {
      return graphQLMap["yyyy"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "yyyy")
    }
  }
}

public struct EnteredAddressInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(addressLine1: String? = nil, addressLine2: String? = nil, city: String? = nil, state: String? = nil, postalCode: String? = nil, country: String? = nil) {
    graphQLMap = ["addressLine1": addressLine1, "addressLine2": addressLine2, "city": city, "state": state, "postalCode": postalCode, "country": country]
  }

  public var addressLine1: String? {
    get {
      return graphQLMap["addressLine1"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "addressLine1")
    }
  }

  public var addressLine2: String? {
    get {
      return graphQLMap["addressLine2"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "addressLine2")
    }
  }

  public var city: String? {
    get {
      return graphQLMap["city"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var state: String? {
    get {
      return graphQLMap["state"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "state")
    }
  }

  public var postalCode: String? {
    get {
      return graphQLMap["postalCode"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postalCode")
    }
  }

  public var country: String? {
    get {
      return graphQLMap["country"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "country")
    }
  }
}

public struct SimulateIncrementalAuthorizationRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(amount: Int, authorizationId: GraphQLID) {
    graphQLMap = ["amount": amount, "authorizationId": authorizationId]
  }

  public var amount: Int {
    get {
      return graphQLMap["amount"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var authorizationId: GraphQLID {
    get {
      return graphQLMap["authorizationId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authorizationId")
    }
  }
}

public struct SimulateReversalRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(amount: Int, authorizationId: GraphQLID) {
    graphQLMap = ["amount": amount, "authorizationId": authorizationId]
  }

  public var amount: Int {
    get {
      return graphQLMap["amount"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var authorizationId: GraphQLID {
    get {
      return graphQLMap["authorizationId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authorizationId")
    }
  }
}

public struct SimulateAuthorizationExpiryRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(authorizationId: GraphQLID) {
    graphQLMap = ["authorizationId": authorizationId]
  }

  public var authorizationId: GraphQLID {
    get {
      return graphQLMap["authorizationId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authorizationId")
    }
  }
}

public struct SimulateRefundRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(amount: Int, debitId: GraphQLID) {
    graphQLMap = ["amount": amount, "debitId": debitId]
  }

  public var amount: Int {
    get {
      return graphQLMap["amount"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var debitId: GraphQLID {
    get {
      return graphQLMap["debitId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "debitId")
    }
  }
}

public struct SimulateDebitRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(amount: Int, authorizationId: GraphQLID) {
    graphQLMap = ["amount": amount, "authorizationId": authorizationId]
  }

  public var amount: Int {
    get {
      return graphQLMap["amount"] as! Int
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "amount")
    }
  }

  public var authorizationId: GraphQLID {
    get {
      return graphQLMap["authorizationId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "authorizationId")
    }
  }
}

public enum AccessRole: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case accepted
  case deleted
  case read
  case readWrite
  case readWriteManage
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ACCEPTED": self = .accepted
      case "DELETED": self = .deleted
      case "READ": self = .read
      case "READ_WRITE": self = .readWrite
      case "READ_WRITE_MANAGE": self = .readWriteManage
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .accepted: return "ACCEPTED"
      case .deleted: return "DELETED"
      case .read: return "READ"
      case .readWrite: return "READ_WRITE"
      case .readWriteManage: return "READ_WRITE_MANAGE"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: AccessRole, rhs: AccessRole) -> Bool {
    switch (lhs, rhs) {
      case (.accepted, .accepted): return true
      case (.deleted, .deleted): return true
      case (.read, .read): return true
      case (.readWrite, .readWrite): return true
      case (.readWriteManage, .readWriteManage): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct GetEntitlementsSetInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String) {
    graphQLMap = ["name": name]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }
}

public struct GetEntitlementsSequenceInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String) {
    graphQLMap = ["name": name]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }
}

public struct GetEntitlementsForUserInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(externalId: String) {
    graphQLMap = ["externalId": externalId]
  }

  public var externalId: String {
    get {
      return graphQLMap["externalId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "externalId")
    }
  }
}

public struct GetEntitlementDefinitionInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(name: String) {
    graphQLMap = ["name": name]
  }

  public var name: String {
    get {
      return graphQLMap["name"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "name")
    }
  }
}

public struct PagingInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(limit: Int? = nil, nextToken: String? = nil) {
    graphQLMap = ["limit": limit, "nextToken": nextToken]
  }

  public var limit: Int? {
    get {
      return graphQLMap["limit"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "limit")
    }
  }

  public var nextToken: String? {
    get {
      return graphQLMap["nextToken"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "nextToken")
    }
  }
}

public struct RetrieveUserBySubInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(sub: String) {
    graphQLMap = ["sub": sub]
  }

  public var sub: String {
    get {
      return graphQLMap["sub"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sub")
    }
  }
}

public struct RetrieveUserByUsernameInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(username: String) {
    graphQLMap = ["username": username]
  }

  public var username: String {
    get {
      return graphQLMap["username"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "username")
    }
  }
}

public struct RetrieveDeviceCheckInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(deviceId: String, type: String) {
    graphQLMap = ["deviceId": deviceId, "type": type]
  }

  public var deviceId: String {
    get {
      return graphQLMap["deviceId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceId")
    }
  }

  public var type: String {
    get {
      return graphQLMap["type"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

public struct RetrieveDeviceCheckKeyMetaDataInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(buildType: String) {
    graphQLMap = ["buildType": buildType]
  }

  public var buildType: String {
    get {
      return graphQLMap["buildType"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "buildType")
    }
  }
}

public struct RetrieveDeviceRegistrationStatusInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(deviceId: String, type: String) {
    graphQLMap = ["deviceId": deviceId, "type": type]
  }

  public var deviceId: String {
    get {
      return graphQLMap["deviceId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "deviceId")
    }
  }

  public var type: String {
    get {
      return graphQLMap["type"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "type")
    }
  }
}

public struct GetIdentityVerificationStatusRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ownerToLookup: String) {
    graphQLMap = ["ownerToLookup": ownerToLookup]
  }

  public var ownerToLookup: String {
    get {
      return graphQLMap["ownerToLookup"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ownerToLookup")
    }
  }
}

public struct VerifiedIdentityMatchRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(ownerToCompare: String, firstName: String? = nil, lastName: String? = nil, address: String? = nil, city: String? = nil, state: String? = nil, postalCode: String? = nil, country: String, dateOfBirth: String? = nil) {
    graphQLMap = ["ownerToCompare": ownerToCompare, "firstName": firstName, "lastName": lastName, "address": address, "city": city, "state": state, "postalCode": postalCode, "country": country, "dateOfBirth": dateOfBirth]
  }

  public var ownerToCompare: String {
    get {
      return graphQLMap["ownerToCompare"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "ownerToCompare")
    }
  }

  public var firstName: String? {
    get {
      return graphQLMap["firstName"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "firstName")
    }
  }

  public var lastName: String? {
    get {
      return graphQLMap["lastName"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "lastName")
    }
  }

  public var address: String? {
    get {
      return graphQLMap["address"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "address")
    }
  }

  public var city: String? {
    get {
      return graphQLMap["city"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "city")
    }
  }

  public var state: String? {
    get {
      return graphQLMap["state"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "state")
    }
  }

  public var postalCode: String? {
    get {
      return graphQLMap["postalCode"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "postalCode")
    }
  }

  public var country: String {
    get {
      return graphQLMap["country"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "country")
    }
  }

  public var dateOfBirth: String? {
    get {
      return graphQLMap["dateOfBirth"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "dateOfBirth")
    }
  }
}

public struct ListDevicesInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(userId: String) {
    graphQLMap = ["userId": userId]
  }

  public var userId: String {
    get {
      return graphQLMap["userId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }
}

public enum ClientEnvType: RawRepresentable, Equatable, JSONDecodable, JSONEncodable {
  public typealias RawValue = String
  case ios
  case android
  case testInbound
  case testOutbound
  case webhook
  /// Auto generated constant for unknown enum values
  case unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "IOS": self = .ios
      case "ANDROID": self = .android
      case "TEST_INBOUND": self = .testInbound
      case "TEST_OUTBOUND": self = .testOutbound
      case "WEBHOOK": self = .webhook
      default: self = .unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .ios: return "IOS"
      case .android: return "ANDROID"
      case .testInbound: return "TEST_INBOUND"
      case .testOutbound: return "TEST_OUTBOUND"
      case .webhook: return "WEBHOOK"
      case .unknown(let value): return value
    }
  }

  public static func == (lhs: ClientEnvType, rhs: ClientEnvType) -> Bool {
    switch (lhs, rhs) {
      case (.ios, .ios): return true
      case (.android, .android): return true
      case (.testInbound, .testInbound): return true
      case (.testOutbound, .testOutbound): return true
      case (.webhook, .webhook): return true
      case (.unknown(let lhsValue), .unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }
}

public struct SearchVirtualCardsTransactionsRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(userId: GraphQLID, last4: String, startDate: String, endDate: String, limit: Int? = nil, nextToken: String? = nil) {
    graphQLMap = ["userId": userId, "last4": last4, "startDate": startDate, "endDate": endDate, "limit": limit, "nextToken": nextToken]
  }

  public var userId: GraphQLID {
    get {
      return graphQLMap["userId"] as! GraphQLID
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "userId")
    }
  }

  public var last4: String {
    get {
      return graphQLMap["last4"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "last4")
    }
  }

  public var startDate: String {
    get {
      return graphQLMap["startDate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "startDate")
    }
  }

  public var endDate: String {
    get {
      return graphQLMap["endDate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "endDate")
    }
  }

  public var limit: Int? {
    get {
      return graphQLMap["limit"] as! Int?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "limit")
    }
  }

  public var nextToken: String? {
    get {
      return graphQLMap["nextToken"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "nextToken")
    }
  }
}

public struct ListVirtualCardsBySudoRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(sudoId: String) {
    graphQLMap = ["sudoId": sudoId]
  }

  public var sudoId: String {
    get {
      return graphQLMap["sudoId"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sudoId")
    }
  }
}

public struct ListVirtualCardsBySubRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(sub: String) {
    graphQLMap = ["sub": sub]
  }

  public var sub: String {
    get {
      return graphQLMap["sub"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sub")
    }
  }
}

public struct ListFundingSourcesBySubRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(sub: String) {
    graphQLMap = ["sub": sub]
  }

  public var sub: String {
    get {
      return graphQLMap["sub"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "sub")
    }
  }
}

public struct GetVirtualCardsActiveRequest: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  public init(startDate: String, endDate: String, timeZone: String? = nil) {
    graphQLMap = ["startDate": startDate, "endDate": endDate, "timeZone": timeZone]
  }

  public var startDate: String {
    get {
      return graphQLMap["startDate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "startDate")
    }
  }

  public var endDate: String {
    get {
      return graphQLMap["endDate"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "endDate")
    }
  }

  public var timeZone: String? {
    get {
      return graphQLMap["timeZone"] as! String?
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timeZone")
    }
  }
}

public final class AddEntitlementsSetMutation: GraphQLMutation {
  public static let operationString =
    "mutation AddEntitlementsSet($input: AddEntitlementsSetInput!) {\n  addEntitlementsSet(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    name\n    description\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n  }\n}"

  public var input: AddEntitlementsSetInput

  public init(input: AddEntitlementsSetInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addEntitlementsSet", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(AddEntitlementsSet.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(addEntitlementsSet: AddEntitlementsSet) {
      self.init(snapshot: ["__typename": "Mutation", "addEntitlementsSet": addEntitlementsSet.snapshot])
    }

    public var addEntitlementsSet: AddEntitlementsSet {
      get {
        return AddEntitlementsSet(snapshot: snapshot["addEntitlementsSet"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "addEntitlementsSet")
      }
    }

    public struct AddEntitlementsSet: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSet"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, name: String, description: String? = nil, entitlements: [Entitlement]) {
        self.init(snapshot: ["__typename": "EntitlementsSet", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "name": name, "description": description, "entitlements": entitlements.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class SetEntitlementsSetMutation: GraphQLMutation {
  public static let operationString =
    "mutation SetEntitlementsSet($input: SetEntitlementsSetInput!) {\n  setEntitlementsSet(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    name\n    description\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n  }\n}"

  public var input: SetEntitlementsSetInput

  public init(input: SetEntitlementsSetInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("setEntitlementsSet", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SetEntitlementsSet.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(setEntitlementsSet: SetEntitlementsSet) {
      self.init(snapshot: ["__typename": "Mutation", "setEntitlementsSet": setEntitlementsSet.snapshot])
    }

    public var setEntitlementsSet: SetEntitlementsSet {
      get {
        return SetEntitlementsSet(snapshot: snapshot["setEntitlementsSet"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "setEntitlementsSet")
      }
    }

    public struct SetEntitlementsSet: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSet"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, name: String, description: String? = nil, entitlements: [Entitlement]) {
        self.init(snapshot: ["__typename": "EntitlementsSet", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "name": name, "description": description, "entitlements": entitlements.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class RemoveEntitlementsSetMutation: GraphQLMutation {
  public static let operationString =
    "mutation RemoveEntitlementsSet($input: RemoveEntitlementsSetInput!) {\n  removeEntitlementsSet(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    name\n    description\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n  }\n}"

  public var input: RemoveEntitlementsSetInput

  public init(input: RemoveEntitlementsSetInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeEntitlementsSet", arguments: ["input": GraphQLVariable("input")], type: .object(RemoveEntitlementsSet.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(removeEntitlementsSet: RemoveEntitlementsSet? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "removeEntitlementsSet": removeEntitlementsSet.flatMap { $0.snapshot }])
    }

    public var removeEntitlementsSet: RemoveEntitlementsSet? {
      get {
        return (snapshot["removeEntitlementsSet"] as? Snapshot).flatMap { RemoveEntitlementsSet(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "removeEntitlementsSet")
      }
    }

    public struct RemoveEntitlementsSet: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSet"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, name: String, description: String? = nil, entitlements: [Entitlement]) {
        self.init(snapshot: ["__typename": "EntitlementsSet", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "name": name, "description": description, "entitlements": entitlements.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class AddEntitlementsSequenceMutation: GraphQLMutation {
  public static let operationString =
    "mutation AddEntitlementsSequence($input: AddEntitlementsSequenceInput!) {\n  addEntitlementsSequence(input: $input) {\n    __typename\n    name\n    description\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    transitions {\n      __typename\n      entitlementsSetName\n      duration\n    }\n  }\n}"

  public var input: AddEntitlementsSequenceInput

  public init(input: AddEntitlementsSequenceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addEntitlementsSequence", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(AddEntitlementsSequence.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(addEntitlementsSequence: AddEntitlementsSequence) {
      self.init(snapshot: ["__typename": "Mutation", "addEntitlementsSequence": addEntitlementsSequence.snapshot])
    }

    public var addEntitlementsSequence: AddEntitlementsSequence {
      get {
        return AddEntitlementsSequence(snapshot: snapshot["addEntitlementsSequence"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "addEntitlementsSequence")
      }
    }

    public struct AddEntitlementsSequence: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSequence"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("transitions", type: .nonNull(.list(.nonNull(.object(Transition.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(name: String, description: String? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, transitions: [Transition]) {
        self.init(snapshot: ["__typename": "EntitlementsSequence", "name": name, "description": description, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "transitions": transitions.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var transitions: [Transition] {
        get {
          return (snapshot["transitions"] as! [Snapshot]).map { Transition(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "transitions")
        }
      }

      public struct Transition: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementsSequenceTransition"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("entitlementsSetName", type: .nonNull(.scalar(String.self))),
          GraphQLField("duration", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(entitlementsSetName: String, duration: String? = nil) {
          self.init(snapshot: ["__typename": "EntitlementsSequenceTransition", "entitlementsSetName": entitlementsSetName, "duration": duration])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var entitlementsSetName: String {
          get {
            return snapshot["entitlementsSetName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var duration: String? {
          get {
            return snapshot["duration"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "duration")
          }
        }
      }
    }
  }
}

public final class SetEntitlementsSequenceMutation: GraphQLMutation {
  public static let operationString =
    "mutation SetEntitlementsSequence($input: SetEntitlementsSequenceInput!) {\n  setEntitlementsSequence(input: $input) {\n    __typename\n    name\n    description\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    transitions {\n      __typename\n      entitlementsSetName\n      duration\n    }\n  }\n}"

  public var input: SetEntitlementsSequenceInput

  public init(input: SetEntitlementsSequenceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("setEntitlementsSequence", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SetEntitlementsSequence.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(setEntitlementsSequence: SetEntitlementsSequence) {
      self.init(snapshot: ["__typename": "Mutation", "setEntitlementsSequence": setEntitlementsSequence.snapshot])
    }

    public var setEntitlementsSequence: SetEntitlementsSequence {
      get {
        return SetEntitlementsSequence(snapshot: snapshot["setEntitlementsSequence"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "setEntitlementsSequence")
      }
    }

    public struct SetEntitlementsSequence: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSequence"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("transitions", type: .nonNull(.list(.nonNull(.object(Transition.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(name: String, description: String? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, transitions: [Transition]) {
        self.init(snapshot: ["__typename": "EntitlementsSequence", "name": name, "description": description, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "transitions": transitions.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var transitions: [Transition] {
        get {
          return (snapshot["transitions"] as! [Snapshot]).map { Transition(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "transitions")
        }
      }

      public struct Transition: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementsSequenceTransition"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("entitlementsSetName", type: .nonNull(.scalar(String.self))),
          GraphQLField("duration", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(entitlementsSetName: String, duration: String? = nil) {
          self.init(snapshot: ["__typename": "EntitlementsSequenceTransition", "entitlementsSetName": entitlementsSetName, "duration": duration])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var entitlementsSetName: String {
          get {
            return snapshot["entitlementsSetName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var duration: String? {
          get {
            return snapshot["duration"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "duration")
          }
        }
      }
    }
  }
}

public final class RemoveEntitlementsSequenceMutation: GraphQLMutation {
  public static let operationString =
    "mutation RemoveEntitlementsSequence($input: RemoveEntitlementsSequenceInput!) {\n  removeEntitlementsSequence(input: $input) {\n    __typename\n    name\n    description\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    transitions {\n      __typename\n      entitlementsSetName\n      duration\n    }\n  }\n}"

  public var input: RemoveEntitlementsSequenceInput

  public init(input: RemoveEntitlementsSequenceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeEntitlementsSequence", arguments: ["input": GraphQLVariable("input")], type: .object(RemoveEntitlementsSequence.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(removeEntitlementsSequence: RemoveEntitlementsSequence? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "removeEntitlementsSequence": removeEntitlementsSequence.flatMap { $0.snapshot }])
    }

    public var removeEntitlementsSequence: RemoveEntitlementsSequence? {
      get {
        return (snapshot["removeEntitlementsSequence"] as? Snapshot).flatMap { RemoveEntitlementsSequence(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "removeEntitlementsSequence")
      }
    }

    public struct RemoveEntitlementsSequence: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSequence"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("transitions", type: .nonNull(.list(.nonNull(.object(Transition.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(name: String, description: String? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, transitions: [Transition]) {
        self.init(snapshot: ["__typename": "EntitlementsSequence", "name": name, "description": description, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "transitions": transitions.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var transitions: [Transition] {
        get {
          return (snapshot["transitions"] as! [Snapshot]).map { Transition(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "transitions")
        }
      }

      public struct Transition: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementsSequenceTransition"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("entitlementsSetName", type: .nonNull(.scalar(String.self))),
          GraphQLField("duration", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(entitlementsSetName: String, duration: String? = nil) {
          self.init(snapshot: ["__typename": "EntitlementsSequenceTransition", "entitlementsSetName": entitlementsSetName, "duration": duration])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var entitlementsSetName: String {
          get {
            return snapshot["entitlementsSetName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var duration: String? {
          get {
            return snapshot["duration"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "duration")
          }
        }
      }
    }
  }
}

public final class ApplyEntitlementsSetToUsersMutation: GraphQLMutation {
  public static let operationString =
    "mutation ApplyEntitlementsSetToUsers($input: ApplyEntitlementsSetToUsersInput!) {\n  applyEntitlementsSetToUsers(input: $input) {\n    __typename\n    ... on ExternalUserEntitlements {\n      createdAtEpochMs\n      updatedAtEpochMs\n      version\n      externalId\n      owner\n      accountState\n      entitlementsSetName\n      entitlementsSequenceName\n      entitlements {\n        __typename\n        name\n        description\n        value\n      }\n      expendableEntitlements {\n        __typename\n        name\n        description\n        value\n      }\n      transitionsRelativeToEpochMs\n    }\n    ... on ExternalUserEntitlementsError {\n      error\n    }\n  }\n}"

  public var input: ApplyEntitlementsSetToUsersInput

  public init(input: ApplyEntitlementsSetToUsersInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("applyEntitlementsSetToUsers", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.list(.nonNull(.object(ApplyEntitlementsSetToUser.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(applyEntitlementsSetToUsers: [ApplyEntitlementsSetToUser]) {
      self.init(snapshot: ["__typename": "Mutation", "applyEntitlementsSetToUsers": applyEntitlementsSetToUsers.map { $0.snapshot }])
    }

    public var applyEntitlementsSetToUsers: [ApplyEntitlementsSetToUser] {
      get {
        return (snapshot["applyEntitlementsSetToUsers"] as! [Snapshot]).map { ApplyEntitlementsSetToUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "applyEntitlementsSetToUsers")
      }
    }

    public struct ApplyEntitlementsSetToUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalUserEntitlements", "ExternalUserEntitlementsError"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["ExternalUserEntitlements": AsExternalUserEntitlements.selections, "ExternalUserEntitlementsError": AsExternalUserEntitlementsError.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeExternalUserEntitlements(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [AsExternalUserEntitlements.Entitlement], expendableEntitlements: [AsExternalUserEntitlements.ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) -> ApplyEntitlementsSetToUser {
        return ApplyEntitlementsSetToUser(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
      }

      public static func makeExternalUserEntitlementsError(error: String) -> ApplyEntitlementsSetToUser {
        return ApplyEntitlementsSetToUser(snapshot: ["__typename": "ExternalUserEntitlementsError", "error": error])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asExternalUserEntitlements: AsExternalUserEntitlements? {
        get {
          if !AsExternalUserEntitlements.possibleTypes.contains(__typename) { return nil }
          return AsExternalUserEntitlements(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsExternalUserEntitlements: GraphQLSelectionSet {
        public static let possibleTypes = ["ExternalUserEntitlements"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("version", type: .nonNull(.scalar(Double.self))),
          GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("accountState", type: .scalar(AccountStates.self)),
          GraphQLField("entitlementsSetName", type: .scalar(String.self)),
          GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
          GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
          GraphQLField("expendableEntitlements", type: .nonNull(.list(.nonNull(.object(ExpendableEntitlement.selections))))),
          GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [Entitlement], expendableEntitlements: [ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) {
          self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var version: Double {
          get {
            return snapshot["version"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var externalId: String {
          get {
            return snapshot["externalId"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "externalId")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var accountState: AccountStates? {
          get {
            return snapshot["accountState"] as? AccountStates
          }
          set {
            snapshot.updateValue(newValue, forKey: "accountState")
          }
        }

        public var entitlementsSetName: String? {
          get {
            return snapshot["entitlementsSetName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var entitlementsSequenceName: String? {
          get {
            return snapshot["entitlementsSequenceName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
          }
        }

        public var entitlements: [Entitlement] {
          get {
            return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
          }
        }

        public var expendableEntitlements: [ExpendableEntitlement] {
          get {
            return (snapshot["expendableEntitlements"] as! [Snapshot]).map { ExpendableEntitlement(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "expendableEntitlements")
          }
        }

        public var transitionsRelativeToEpochMs: Double? {
          get {
            return snapshot["transitionsRelativeToEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
          }
        }

        public struct Entitlement: GraphQLSelectionSet {
          public static let possibleTypes = ["Entitlement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(name: String, description: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var description: String? {
            get {
              return snapshot["description"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "description")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }

        public struct ExpendableEntitlement: GraphQLSelectionSet {
          public static let possibleTypes = ["Entitlement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(name: String, description: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var description: String? {
            get {
              return snapshot["description"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "description")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }
      }

      public var asExternalUserEntitlementsError: AsExternalUserEntitlementsError? {
        get {
          if !AsExternalUserEntitlementsError.possibleTypes.contains(__typename) { return nil }
          return AsExternalUserEntitlementsError(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsExternalUserEntitlementsError: GraphQLSelectionSet {
        public static let possibleTypes = ["ExternalUserEntitlementsError"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("error", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(error: String) {
          self.init(snapshot: ["__typename": "ExternalUserEntitlementsError", "error": error])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var error: String {
          get {
            return snapshot["error"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "error")
          }
        }
      }
    }
  }
}

public final class ApplyEntitlementsSetToUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation ApplyEntitlementsSetToUser($input: ApplyEntitlementsSetToUserInput!) {\n  applyEntitlementsSetToUser(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    externalId\n    owner\n    accountState\n    entitlementsSetName\n    entitlementsSequenceName\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n    expendableEntitlements {\n      __typename\n      name\n      description\n      value\n    }\n    transitionsRelativeToEpochMs\n  }\n}"

  public var input: ApplyEntitlementsSetToUserInput

  public init(input: ApplyEntitlementsSetToUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("applyEntitlementsSetToUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ApplyEntitlementsSetToUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(applyEntitlementsSetToUser: ApplyEntitlementsSetToUser) {
      self.init(snapshot: ["__typename": "Mutation", "applyEntitlementsSetToUser": applyEntitlementsSetToUser.snapshot])
    }

    public var applyEntitlementsSetToUser: ApplyEntitlementsSetToUser {
      get {
        return ApplyEntitlementsSetToUser(snapshot: snapshot["applyEntitlementsSetToUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "applyEntitlementsSetToUser")
      }
    }

    public struct ApplyEntitlementsSetToUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalUserEntitlements"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Double.self))),
        GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("accountState", type: .scalar(AccountStates.self)),
        GraphQLField("entitlementsSetName", type: .scalar(String.self)),
        GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
        GraphQLField("expendableEntitlements", type: .nonNull(.list(.nonNull(.object(ExpendableEntitlement.selections))))),
        GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [Entitlement], expendableEntitlements: [ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) {
        self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Double {
        get {
          return snapshot["version"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var externalId: String {
        get {
          return snapshot["externalId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "externalId")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var accountState: AccountStates? {
        get {
          return snapshot["accountState"] as? AccountStates
        }
        set {
          snapshot.updateValue(newValue, forKey: "accountState")
        }
      }

      public var entitlementsSetName: String? {
        get {
          return snapshot["entitlementsSetName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSetName")
        }
      }

      public var entitlementsSequenceName: String? {
        get {
          return snapshot["entitlementsSequenceName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public var expendableEntitlements: [ExpendableEntitlement] {
        get {
          return (snapshot["expendableEntitlements"] as! [Snapshot]).map { ExpendableEntitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "expendableEntitlements")
        }
      }

      public var transitionsRelativeToEpochMs: Double? {
        get {
          return snapshot["transitionsRelativeToEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }

      public struct ExpendableEntitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class ApplyEntitlementsSequenceToUsersMutation: GraphQLMutation {
  public static let operationString =
    "mutation ApplyEntitlementsSequenceToUsers($input: ApplyEntitlementsSequenceToUsersInput!) {\n  applyEntitlementsSequenceToUsers(input: $input) {\n    __typename\n    ... on ExternalUserEntitlements {\n      createdAtEpochMs\n      updatedAtEpochMs\n      version\n      externalId\n      owner\n      accountState\n      entitlementsSetName\n      entitlementsSequenceName\n      entitlements {\n        __typename\n        name\n        description\n        value\n      }\n      expendableEntitlements {\n        __typename\n        name\n        description\n        value\n      }\n      transitionsRelativeToEpochMs\n    }\n    ... on ExternalUserEntitlementsError {\n      error\n    }\n  }\n}"

  public var input: ApplyEntitlementsSequenceToUsersInput

  public init(input: ApplyEntitlementsSequenceToUsersInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("applyEntitlementsSequenceToUsers", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.list(.nonNull(.object(ApplyEntitlementsSequenceToUser.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(applyEntitlementsSequenceToUsers: [ApplyEntitlementsSequenceToUser]) {
      self.init(snapshot: ["__typename": "Mutation", "applyEntitlementsSequenceToUsers": applyEntitlementsSequenceToUsers.map { $0.snapshot }])
    }

    public var applyEntitlementsSequenceToUsers: [ApplyEntitlementsSequenceToUser] {
      get {
        return (snapshot["applyEntitlementsSequenceToUsers"] as! [Snapshot]).map { ApplyEntitlementsSequenceToUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "applyEntitlementsSequenceToUsers")
      }
    }

    public struct ApplyEntitlementsSequenceToUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalUserEntitlements", "ExternalUserEntitlementsError"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["ExternalUserEntitlements": AsExternalUserEntitlements.selections, "ExternalUserEntitlementsError": AsExternalUserEntitlementsError.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeExternalUserEntitlements(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [AsExternalUserEntitlements.Entitlement], expendableEntitlements: [AsExternalUserEntitlements.ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) -> ApplyEntitlementsSequenceToUser {
        return ApplyEntitlementsSequenceToUser(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
      }

      public static func makeExternalUserEntitlementsError(error: String) -> ApplyEntitlementsSequenceToUser {
        return ApplyEntitlementsSequenceToUser(snapshot: ["__typename": "ExternalUserEntitlementsError", "error": error])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asExternalUserEntitlements: AsExternalUserEntitlements? {
        get {
          if !AsExternalUserEntitlements.possibleTypes.contains(__typename) { return nil }
          return AsExternalUserEntitlements(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsExternalUserEntitlements: GraphQLSelectionSet {
        public static let possibleTypes = ["ExternalUserEntitlements"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("version", type: .nonNull(.scalar(Double.self))),
          GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("accountState", type: .scalar(AccountStates.self)),
          GraphQLField("entitlementsSetName", type: .scalar(String.self)),
          GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
          GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
          GraphQLField("expendableEntitlements", type: .nonNull(.list(.nonNull(.object(ExpendableEntitlement.selections))))),
          GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [Entitlement], expendableEntitlements: [ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) {
          self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var version: Double {
          get {
            return snapshot["version"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var externalId: String {
          get {
            return snapshot["externalId"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "externalId")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var accountState: AccountStates? {
          get {
            return snapshot["accountState"] as? AccountStates
          }
          set {
            snapshot.updateValue(newValue, forKey: "accountState")
          }
        }

        public var entitlementsSetName: String? {
          get {
            return snapshot["entitlementsSetName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var entitlementsSequenceName: String? {
          get {
            return snapshot["entitlementsSequenceName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
          }
        }

        public var entitlements: [Entitlement] {
          get {
            return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
          }
        }

        public var expendableEntitlements: [ExpendableEntitlement] {
          get {
            return (snapshot["expendableEntitlements"] as! [Snapshot]).map { ExpendableEntitlement(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "expendableEntitlements")
          }
        }

        public var transitionsRelativeToEpochMs: Double? {
          get {
            return snapshot["transitionsRelativeToEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
          }
        }

        public struct Entitlement: GraphQLSelectionSet {
          public static let possibleTypes = ["Entitlement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(name: String, description: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var description: String? {
            get {
              return snapshot["description"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "description")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }

        public struct ExpendableEntitlement: GraphQLSelectionSet {
          public static let possibleTypes = ["Entitlement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(name: String, description: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var description: String? {
            get {
              return snapshot["description"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "description")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }
      }

      public var asExternalUserEntitlementsError: AsExternalUserEntitlementsError? {
        get {
          if !AsExternalUserEntitlementsError.possibleTypes.contains(__typename) { return nil }
          return AsExternalUserEntitlementsError(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsExternalUserEntitlementsError: GraphQLSelectionSet {
        public static let possibleTypes = ["ExternalUserEntitlementsError"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("error", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(error: String) {
          self.init(snapshot: ["__typename": "ExternalUserEntitlementsError", "error": error])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var error: String {
          get {
            return snapshot["error"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "error")
          }
        }
      }
    }
  }
}

public final class ApplyEntitlementsSequenceToUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation ApplyEntitlementsSequenceToUser($input: ApplyEntitlementsSequenceToUserInput!) {\n  applyEntitlementsSequenceToUser(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    externalId\n    owner\n    accountState\n    entitlementsSetName\n    entitlementsSequenceName\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n    expendableEntitlements {\n      __typename\n      name\n      description\n      value\n    }\n    transitionsRelativeToEpochMs\n  }\n}"

  public var input: ApplyEntitlementsSequenceToUserInput

  public init(input: ApplyEntitlementsSequenceToUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("applyEntitlementsSequenceToUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ApplyEntitlementsSequenceToUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(applyEntitlementsSequenceToUser: ApplyEntitlementsSequenceToUser) {
      self.init(snapshot: ["__typename": "Mutation", "applyEntitlementsSequenceToUser": applyEntitlementsSequenceToUser.snapshot])
    }

    public var applyEntitlementsSequenceToUser: ApplyEntitlementsSequenceToUser {
      get {
        return ApplyEntitlementsSequenceToUser(snapshot: snapshot["applyEntitlementsSequenceToUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "applyEntitlementsSequenceToUser")
      }
    }

    public struct ApplyEntitlementsSequenceToUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalUserEntitlements"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Double.self))),
        GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("accountState", type: .scalar(AccountStates.self)),
        GraphQLField("entitlementsSetName", type: .scalar(String.self)),
        GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
        GraphQLField("expendableEntitlements", type: .nonNull(.list(.nonNull(.object(ExpendableEntitlement.selections))))),
        GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [Entitlement], expendableEntitlements: [ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) {
        self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Double {
        get {
          return snapshot["version"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var externalId: String {
        get {
          return snapshot["externalId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "externalId")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var accountState: AccountStates? {
        get {
          return snapshot["accountState"] as? AccountStates
        }
        set {
          snapshot.updateValue(newValue, forKey: "accountState")
        }
      }

      public var entitlementsSetName: String? {
        get {
          return snapshot["entitlementsSetName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSetName")
        }
      }

      public var entitlementsSequenceName: String? {
        get {
          return snapshot["entitlementsSequenceName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public var expendableEntitlements: [ExpendableEntitlement] {
        get {
          return (snapshot["expendableEntitlements"] as! [Snapshot]).map { ExpendableEntitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "expendableEntitlements")
        }
      }

      public var transitionsRelativeToEpochMs: Double? {
        get {
          return snapshot["transitionsRelativeToEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }

      public struct ExpendableEntitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class ApplyEntitlementsToUsersMutation: GraphQLMutation {
  public static let operationString =
    "mutation ApplyEntitlementsToUsers($input: ApplyEntitlementsToUsersInput!) {\n  applyEntitlementsToUsers(input: $input) {\n    __typename\n    ... on ExternalUserEntitlements {\n      createdAtEpochMs\n      updatedAtEpochMs\n      version\n      externalId\n      owner\n      accountState\n      entitlementsSetName\n      entitlementsSequenceName\n      entitlements {\n        __typename\n        name\n        description\n        value\n      }\n      expendableEntitlements {\n        __typename\n        name\n        description\n        value\n      }\n      transitionsRelativeToEpochMs\n    }\n    ... on ExternalUserEntitlementsError {\n      error\n    }\n  }\n}"

  public var input: ApplyEntitlementsToUsersInput

  public init(input: ApplyEntitlementsToUsersInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("applyEntitlementsToUsers", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.list(.nonNull(.object(ApplyEntitlementsToUser.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(applyEntitlementsToUsers: [ApplyEntitlementsToUser]) {
      self.init(snapshot: ["__typename": "Mutation", "applyEntitlementsToUsers": applyEntitlementsToUsers.map { $0.snapshot }])
    }

    public var applyEntitlementsToUsers: [ApplyEntitlementsToUser] {
      get {
        return (snapshot["applyEntitlementsToUsers"] as! [Snapshot]).map { ApplyEntitlementsToUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "applyEntitlementsToUsers")
      }
    }

    public struct ApplyEntitlementsToUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalUserEntitlements", "ExternalUserEntitlementsError"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["ExternalUserEntitlements": AsExternalUserEntitlements.selections, "ExternalUserEntitlementsError": AsExternalUserEntitlementsError.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeExternalUserEntitlements(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [AsExternalUserEntitlements.Entitlement], expendableEntitlements: [AsExternalUserEntitlements.ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) -> ApplyEntitlementsToUser {
        return ApplyEntitlementsToUser(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
      }

      public static func makeExternalUserEntitlementsError(error: String) -> ApplyEntitlementsToUser {
        return ApplyEntitlementsToUser(snapshot: ["__typename": "ExternalUserEntitlementsError", "error": error])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asExternalUserEntitlements: AsExternalUserEntitlements? {
        get {
          if !AsExternalUserEntitlements.possibleTypes.contains(__typename) { return nil }
          return AsExternalUserEntitlements(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsExternalUserEntitlements: GraphQLSelectionSet {
        public static let possibleTypes = ["ExternalUserEntitlements"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("version", type: .nonNull(.scalar(Double.self))),
          GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("accountState", type: .scalar(AccountStates.self)),
          GraphQLField("entitlementsSetName", type: .scalar(String.self)),
          GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
          GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
          GraphQLField("expendableEntitlements", type: .nonNull(.list(.nonNull(.object(ExpendableEntitlement.selections))))),
          GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [Entitlement], expendableEntitlements: [ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) {
          self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var version: Double {
          get {
            return snapshot["version"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var externalId: String {
          get {
            return snapshot["externalId"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "externalId")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var accountState: AccountStates? {
          get {
            return snapshot["accountState"] as? AccountStates
          }
          set {
            snapshot.updateValue(newValue, forKey: "accountState")
          }
        }

        public var entitlementsSetName: String? {
          get {
            return snapshot["entitlementsSetName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var entitlementsSequenceName: String? {
          get {
            return snapshot["entitlementsSequenceName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
          }
        }

        public var entitlements: [Entitlement] {
          get {
            return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
          }
        }

        public var expendableEntitlements: [ExpendableEntitlement] {
          get {
            return (snapshot["expendableEntitlements"] as! [Snapshot]).map { ExpendableEntitlement(snapshot: $0) }
          }
          set {
            snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "expendableEntitlements")
          }
        }

        public var transitionsRelativeToEpochMs: Double? {
          get {
            return snapshot["transitionsRelativeToEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
          }
        }

        public struct Entitlement: GraphQLSelectionSet {
          public static let possibleTypes = ["Entitlement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(name: String, description: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var description: String? {
            get {
              return snapshot["description"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "description")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }

        public struct ExpendableEntitlement: GraphQLSelectionSet {
          public static let possibleTypes = ["Entitlement"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(name: String, description: String? = nil, value: Int) {
            self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var name: String {
            get {
              return snapshot["name"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "name")
            }
          }

          public var description: String? {
            get {
              return snapshot["description"] as? String
            }
            set {
              snapshot.updateValue(newValue, forKey: "description")
            }
          }

          public var value: Int {
            get {
              return snapshot["value"]! as! Int
            }
            set {
              snapshot.updateValue(newValue, forKey: "value")
            }
          }
        }
      }

      public var asExternalUserEntitlementsError: AsExternalUserEntitlementsError? {
        get {
          if !AsExternalUserEntitlementsError.possibleTypes.contains(__typename) { return nil }
          return AsExternalUserEntitlementsError(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsExternalUserEntitlementsError: GraphQLSelectionSet {
        public static let possibleTypes = ["ExternalUserEntitlementsError"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("error", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(error: String) {
          self.init(snapshot: ["__typename": "ExternalUserEntitlementsError", "error": error])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var error: String {
          get {
            return snapshot["error"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "error")
          }
        }
      }
    }
  }
}

public final class ApplyEntitlementsToUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation ApplyEntitlementsToUser($input: ApplyEntitlementsToUserInput!) {\n  applyEntitlementsToUser(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    externalId\n    owner\n    accountState\n    entitlementsSetName\n    entitlementsSequenceName\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n    expendableEntitlements {\n      __typename\n      name\n      description\n      value\n    }\n    transitionsRelativeToEpochMs\n  }\n}"

  public var input: ApplyEntitlementsToUserInput

  public init(input: ApplyEntitlementsToUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("applyEntitlementsToUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ApplyEntitlementsToUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(applyEntitlementsToUser: ApplyEntitlementsToUser) {
      self.init(snapshot: ["__typename": "Mutation", "applyEntitlementsToUser": applyEntitlementsToUser.snapshot])
    }

    public var applyEntitlementsToUser: ApplyEntitlementsToUser {
      get {
        return ApplyEntitlementsToUser(snapshot: snapshot["applyEntitlementsToUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "applyEntitlementsToUser")
      }
    }

    public struct ApplyEntitlementsToUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalUserEntitlements"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Double.self))),
        GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("accountState", type: .scalar(AccountStates.self)),
        GraphQLField("entitlementsSetName", type: .scalar(String.self)),
        GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
        GraphQLField("expendableEntitlements", type: .nonNull(.list(.nonNull(.object(ExpendableEntitlement.selections))))),
        GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [Entitlement], expendableEntitlements: [ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) {
        self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Double {
        get {
          return snapshot["version"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var externalId: String {
        get {
          return snapshot["externalId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "externalId")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var accountState: AccountStates? {
        get {
          return snapshot["accountState"] as? AccountStates
        }
        set {
          snapshot.updateValue(newValue, forKey: "accountState")
        }
      }

      public var entitlementsSetName: String? {
        get {
          return snapshot["entitlementsSetName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSetName")
        }
      }

      public var entitlementsSequenceName: String? {
        get {
          return snapshot["entitlementsSequenceName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public var expendableEntitlements: [ExpendableEntitlement] {
        get {
          return (snapshot["expendableEntitlements"] as! [Snapshot]).map { ExpendableEntitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "expendableEntitlements")
        }
      }

      public var transitionsRelativeToEpochMs: Double? {
        get {
          return snapshot["transitionsRelativeToEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }

      public struct ExpendableEntitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class ApplyExpendableEntitlementsToUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation ApplyExpendableEntitlementsToUser($input: ApplyExpendableEntitlementsToUserInput!) {\n  applyExpendableEntitlementsToUser(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    externalId\n    owner\n    accountState\n    entitlementsSetName\n    entitlementsSequenceName\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n    expendableEntitlements {\n      __typename\n      name\n      description\n      value\n    }\n    transitionsRelativeToEpochMs\n  }\n}"

  public var input: ApplyExpendableEntitlementsToUserInput

  public init(input: ApplyExpendableEntitlementsToUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("applyExpendableEntitlementsToUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ApplyExpendableEntitlementsToUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(applyExpendableEntitlementsToUser: ApplyExpendableEntitlementsToUser) {
      self.init(snapshot: ["__typename": "Mutation", "applyExpendableEntitlementsToUser": applyExpendableEntitlementsToUser.snapshot])
    }

    public var applyExpendableEntitlementsToUser: ApplyExpendableEntitlementsToUser {
      get {
        return ApplyExpendableEntitlementsToUser(snapshot: snapshot["applyExpendableEntitlementsToUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "applyExpendableEntitlementsToUser")
      }
    }

    public struct ApplyExpendableEntitlementsToUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalUserEntitlements"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Double.self))),
        GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .scalar(String.self)),
        GraphQLField("accountState", type: .scalar(AccountStates.self)),
        GraphQLField("entitlementsSetName", type: .scalar(String.self)),
        GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
        GraphQLField("expendableEntitlements", type: .nonNull(.list(.nonNull(.object(ExpendableEntitlement.selections))))),
        GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, entitlements: [Entitlement], expendableEntitlements: [ExpendableEntitlement], transitionsRelativeToEpochMs: Double? = nil) {
        self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "entitlements": entitlements.map { $0.snapshot }, "expendableEntitlements": expendableEntitlements.map { $0.snapshot }, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Double {
        get {
          return snapshot["version"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var externalId: String {
        get {
          return snapshot["externalId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "externalId")
        }
      }

      public var owner: String? {
        get {
          return snapshot["owner"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var accountState: AccountStates? {
        get {
          return snapshot["accountState"] as? AccountStates
        }
        set {
          snapshot.updateValue(newValue, forKey: "accountState")
        }
      }

      public var entitlementsSetName: String? {
        get {
          return snapshot["entitlementsSetName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSetName")
        }
      }

      public var entitlementsSequenceName: String? {
        get {
          return snapshot["entitlementsSequenceName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public var expendableEntitlements: [ExpendableEntitlement] {
        get {
          return (snapshot["expendableEntitlements"] as! [Snapshot]).map { ExpendableEntitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "expendableEntitlements")
        }
      }

      public var transitionsRelativeToEpochMs: Double? {
        get {
          return snapshot["transitionsRelativeToEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }

      public struct ExpendableEntitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class RemoveEntitledUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation RemoveEntitledUser($input: RemoveEntitledUserInput!) {\n  removeEntitledUser(input: $input) {\n    __typename\n    externalId\n  }\n}"

  public var input: RemoveEntitledUserInput

  public init(input: RemoveEntitledUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("removeEntitledUser", arguments: ["input": GraphQLVariable("input")], type: .object(RemoveEntitledUser.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(removeEntitledUser: RemoveEntitledUser? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "removeEntitledUser": removeEntitledUser.flatMap { $0.snapshot }])
    }

    @available(*, deprecated, message: "This interface will be removed in future versions")
    public var removeEntitledUser: RemoveEntitledUser? {
      get {
        return (snapshot["removeEntitledUser"] as? Snapshot).flatMap { RemoveEntitledUser(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "removeEntitledUser")
      }
    }

    public struct RemoveEntitledUser: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitledUser"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(externalId: String) {
        self.init(snapshot: ["__typename": "EntitledUser", "externalId": externalId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var externalId: String {
        get {
          return snapshot["externalId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "externalId")
        }
      }
    }
  }
}

public final class ExpireEncryptedBlobMutation: GraphQLMutation {
  public static let operationString =
    "mutation ExpireEncryptedBlob($input: ExpireEncryptedBlobRequest!) {\n  expireEncryptedBlob(input: $input)\n}"

  public var input: ExpireEncryptedBlobRequest

  public init(input: ExpireEncryptedBlobRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("expireEncryptedBlob", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.scalar(GraphQLID.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(expireEncryptedBlob: GraphQLID) {
      self.init(snapshot: ["__typename": "Mutation", "expireEncryptedBlob": expireEncryptedBlob])
    }

    public var expireEncryptedBlob: GraphQLID {
      get {
        return snapshot["expireEncryptedBlob"]! as! GraphQLID
      }
      set {
        snapshot.updateValue(newValue, forKey: "expireEncryptedBlob")
      }
    }
  }
}

public final class DeleteUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteUser($input: DeleteUserInput!) {\n  deleteUser(input: $input) {\n    __typename\n    success\n  }\n}"

  public var input: DeleteUserInput

  public init(input: DeleteUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(DeleteUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteUser: DeleteUser) {
      self.init(snapshot: ["__typename": "Mutation", "deleteUser": deleteUser.snapshot])
    }

    public var deleteUser: DeleteUser {
      get {
        return DeleteUser(snapshot: snapshot["deleteUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "deleteUser")
      }
    }

    public struct DeleteUser: GraphQLSelectionSet {
      public static let possibleTypes = ["DeleteUser"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(success: Bool) {
        self.init(snapshot: ["__typename": "DeleteUser", "success": success])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
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

public final class ResetUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation ResetUser($input: ResetUserInput!) {\n  resetUser(input: $input) {\n    __typename\n    success\n  }\n}"

  public var input: ResetUserInput

  public init(input: ResetUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("resetUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ResetUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(resetUser: ResetUser) {
      self.init(snapshot: ["__typename": "Mutation", "resetUser": resetUser.snapshot])
    }

    public var resetUser: ResetUser {
      get {
        return ResetUser(snapshot: snapshot["resetUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "resetUser")
      }
    }

    public struct ResetUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ResetUser"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(success: Bool) {
        self.init(snapshot: ["__typename": "ResetUser", "success": success])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
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

public final class DisableUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation DisableUser($input: DisableUserInput!) {\n  disableUser(input: $input) {\n    __typename\n    success\n  }\n}"

  public var input: DisableUserInput

  public init(input: DisableUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("disableUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(DisableUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(disableUser: DisableUser) {
      self.init(snapshot: ["__typename": "Mutation", "disableUser": disableUser.snapshot])
    }

    public var disableUser: DisableUser {
      get {
        return DisableUser(snapshot: snapshot["disableUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "disableUser")
      }
    }

    public struct DisableUser: GraphQLSelectionSet {
      public static let possibleTypes = ["DisableUser"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(success: Bool) {
        self.init(snapshot: ["__typename": "DisableUser", "success": success])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
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

public final class EnableUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation EnableUser($input: EnableUserInput!) {\n  enableUser(input: $input) {\n    __typename\n    success\n  }\n}"

  public var input: EnableUserInput

  public init(input: EnableUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("enableUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(EnableUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(enableUser: EnableUser) {
      self.init(snapshot: ["__typename": "Mutation", "enableUser": enableUser.snapshot])
    }

    public var enableUser: EnableUser {
      get {
        return EnableUser(snapshot: snapshot["enableUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "enableUser")
      }
    }

    public struct EnableUser: GraphQLSelectionSet {
      public static let possibleTypes = ["EnableUser"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(success: Bool) {
        self.init(snapshot: ["__typename": "EnableUser", "success": success])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
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

public final class ResetDeviceCheckStatusMutation: GraphQLMutation {
  public static let operationString =
    "mutation ResetDeviceCheckStatus($input: DeviceCheckInput!) {\n  resetDeviceCheckStatus(input: $input) {\n    __typename\n    bit0\n    bit1\n    lastUpdatedTime\n  }\n}"

  public var input: DeviceCheckInput

  public init(input: DeviceCheckInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("resetDeviceCheckStatus", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ResetDeviceCheckStatus.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(resetDeviceCheckStatus: ResetDeviceCheckStatus) {
      self.init(snapshot: ["__typename": "Mutation", "resetDeviceCheckStatus": resetDeviceCheckStatus.snapshot])
    }

    public var resetDeviceCheckStatus: ResetDeviceCheckStatus {
      get {
        return ResetDeviceCheckStatus(snapshot: snapshot["resetDeviceCheckStatus"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "resetDeviceCheckStatus")
      }
    }

    public struct ResetDeviceCheckStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["DeviceCheckStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bit0", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("bit1", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("lastUpdatedTime", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(bit0: Bool, bit1: Bool, lastUpdatedTime: String) {
        self.init(snapshot: ["__typename": "DeviceCheckStatus", "bit0": bit0, "bit1": bit1, "lastUpdatedTime": lastUpdatedTime])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bit0: Bool {
        get {
          return snapshot["bit0"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "bit0")
        }
      }

      public var bit1: Bool {
        get {
          return snapshot["bit1"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "bit1")
        }
      }

      public var lastUpdatedTime: String {
        get {
          return snapshot["lastUpdatedTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastUpdatedTime")
        }
      }
    }
  }
}

public final class WhitelistDeviceMutation: GraphQLMutation {
  public static let operationString =
    "mutation WhitelistDevice($input: WhitelistDeviceInput!) {\n  whitelistDevice(input: $input) {\n    __typename\n    deviceId\n    expiry\n  }\n}"

  public var input: WhitelistDeviceInput

  public init(input: WhitelistDeviceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("whitelistDevice", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(WhitelistDevice.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(whitelistDevice: WhitelistDevice) {
      self.init(snapshot: ["__typename": "Mutation", "whitelistDevice": whitelistDevice.snapshot])
    }

    public var whitelistDevice: WhitelistDevice {
      get {
        return WhitelistDevice(snapshot: snapshot["whitelistDevice"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "whitelistDevice")
      }
    }

    public struct WhitelistDevice: GraphQLSelectionSet {
      public static let possibleTypes = ["WhitelistDeviceStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("deviceId", type: .nonNull(.scalar(String.self))),
        GraphQLField("expiry", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(deviceId: String, expiry: String? = nil) {
        self.init(snapshot: ["__typename": "WhitelistDeviceStatus", "deviceId": deviceId, "expiry": expiry])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var deviceId: String {
        get {
          return snapshot["deviceId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "deviceId")
        }
      }

      public var expiry: String? {
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

public final class UploadDeviceCheckKeyMutation: GraphQLMutation {
  public static let operationString =
    "mutation UploadDeviceCheckKey($input: DeviceCheckKeyInput!) {\n  uploadDeviceCheckKey(input: $input) {\n    __typename\n    success\n  }\n}"

  public var input: DeviceCheckKeyInput

  public init(input: DeviceCheckKeyInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadDeviceCheckKey", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(UploadDeviceCheckKey.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(uploadDeviceCheckKey: UploadDeviceCheckKey) {
      self.init(snapshot: ["__typename": "Mutation", "uploadDeviceCheckKey": uploadDeviceCheckKey.snapshot])
    }

    public var uploadDeviceCheckKey: UploadDeviceCheckKey {
      get {
        return UploadDeviceCheckKey(snapshot: snapshot["uploadDeviceCheckKey"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "uploadDeviceCheckKey")
      }
    }

    public struct UploadDeviceCheckKey: GraphQLSelectionSet {
      public static let possibleTypes = ["UploadDeviceCheckKeyStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(success: Bool) {
        self.init(snapshot: ["__typename": "UploadDeviceCheckKeyStatus", "success": success])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
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

public final class UploadPlayIntegrityKeyMutation: GraphQLMutation {
  public static let operationString =
    "mutation UploadPlayIntegrityKey($input: UploadPlayIntegrityKeyInput!) {\n  uploadPlayIntegrityKey(input: $input) {\n    __typename\n    type\n    project_id\n    private_key_id\n    client_id\n  }\n}"

  public var input: UploadPlayIntegrityKeyInput

  public init(input: UploadPlayIntegrityKeyInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadPlayIntegrityKey", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(UploadPlayIntegrityKey.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(uploadPlayIntegrityKey: UploadPlayIntegrityKey) {
      self.init(snapshot: ["__typename": "Mutation", "uploadPlayIntegrityKey": uploadPlayIntegrityKey.snapshot])
    }

    public var uploadPlayIntegrityKey: UploadPlayIntegrityKey {
      get {
        return UploadPlayIntegrityKey(snapshot: snapshot["uploadPlayIntegrityKey"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "uploadPlayIntegrityKey")
      }
    }

    public struct UploadPlayIntegrityKey: GraphQLSelectionSet {
      public static let possibleTypes = ["PlayIntegrityKeyMetaData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("project_id", type: .nonNull(.scalar(String.self))),
        GraphQLField("private_key_id", type: .nonNull(.scalar(String.self))),
        GraphQLField("client_id", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(type: String, projectId: String, privateKeyId: String, clientId: String) {
        self.init(snapshot: ["__typename": "PlayIntegrityKeyMetaData", "type": type, "project_id": projectId, "private_key_id": privateKeyId, "client_id": clientId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return snapshot["type"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var projectId: String {
        get {
          return snapshot["project_id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "project_id")
        }
      }

      public var privateKeyId: String {
        get {
          return snapshot["private_key_id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "private_key_id")
        }
      }

      public var clientId: String {
        get {
          return snapshot["client_id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "client_id")
        }
      }
    }
  }
}

public final class UploadSigningCertificateFingerprintMutation: GraphQLMutation {
  public static let operationString =
    "mutation UploadSigningCertificateFingerprint($input: UploadSigningCertificateFingerprintInput!) {\n  uploadSigningCertificateFingerprint(input: $input) {\n    __typename\n    id\n  }\n}"

  public var input: UploadSigningCertificateFingerprintInput

  public init(input: UploadSigningCertificateFingerprintInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadSigningCertificateFingerprint", arguments: ["input": GraphQLVariable("input")], type: .object(UploadSigningCertificateFingerprint.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(uploadSigningCertificateFingerprint: UploadSigningCertificateFingerprint? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "uploadSigningCertificateFingerprint": uploadSigningCertificateFingerprint.flatMap { $0.snapshot }])
    }

    public var uploadSigningCertificateFingerprint: UploadSigningCertificateFingerprint? {
      get {
        return (snapshot["uploadSigningCertificateFingerprint"] as? Snapshot).flatMap { UploadSigningCertificateFingerprint(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "uploadSigningCertificateFingerprint")
      }
    }

    public struct UploadSigningCertificateFingerprint: GraphQLSelectionSet {
      public static let possibleTypes = ["MutateSigningCertificateFingerprintStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: String) {
        self.init(snapshot: ["__typename": "MutateSigningCertificateFingerprintStatus", "id": id])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class DeleteSigningCertificateFingerprintMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteSigningCertificateFingerprint($input: DeleteSigningCertificateFingerprintInput!) {\n  deleteSigningCertificateFingerprint(input: $input) {\n    __typename\n    id\n  }\n}"

  public var input: DeleteSigningCertificateFingerprintInput

  public init(input: DeleteSigningCertificateFingerprintInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteSigningCertificateFingerprint", arguments: ["input": GraphQLVariable("input")], type: .object(DeleteSigningCertificateFingerprint.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteSigningCertificateFingerprint: DeleteSigningCertificateFingerprint? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteSigningCertificateFingerprint": deleteSigningCertificateFingerprint.flatMap { $0.snapshot }])
    }

    public var deleteSigningCertificateFingerprint: DeleteSigningCertificateFingerprint? {
      get {
        return (snapshot["deleteSigningCertificateFingerprint"] as? Snapshot).flatMap { DeleteSigningCertificateFingerprint(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "deleteSigningCertificateFingerprint")
      }
    }

    public struct DeleteSigningCertificateFingerprint: GraphQLSelectionSet {
      public static let possibleTypes = ["MutateSigningCertificateFingerprintStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: String) {
        self.init(snapshot: ["__typename": "MutateSigningCertificateFingerprintStatus", "id": id])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class IssueTestRegistrationKeyMutation: GraphQLMutation {
  public static let operationString =
    "mutation IssueTestRegistrationKey($tag: String) {\n  issueTestRegistrationKey(tag: $tag) {\n    __typename\n    keyId\n    privateKeyData\n    publicKeyData\n    tag\n  }\n}"

  public var tag: String?

  public init(tag: String? = nil) {
    self.tag = tag
  }

  public var variables: GraphQLMap? {
    return ["tag": tag]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("issueTestRegistrationKey", arguments: ["tag": GraphQLVariable("tag")], type: .nonNull(.object(IssueTestRegistrationKey.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(issueTestRegistrationKey: IssueTestRegistrationKey) {
      self.init(snapshot: ["__typename": "Mutation", "issueTestRegistrationKey": issueTestRegistrationKey.snapshot])
    }

    public var issueTestRegistrationKey: IssueTestRegistrationKey {
      get {
        return IssueTestRegistrationKey(snapshot: snapshot["issueTestRegistrationKey"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "issueTestRegistrationKey")
      }
    }

    public struct IssueTestRegistrationKey: GraphQLSelectionSet {
      public static let possibleTypes = ["IssueTestRegistrationKeyResult"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("keyId", type: .nonNull(.scalar(String.self))),
        GraphQLField("privateKeyData", type: .nonNull(.scalar(String.self))),
        GraphQLField("publicKeyData", type: .nonNull(.scalar(String.self))),
        GraphQLField("tag", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(keyId: String, privateKeyData: String, publicKeyData: String, tag: String? = nil) {
        self.init(snapshot: ["__typename": "IssueTestRegistrationKeyResult", "keyId": keyId, "privateKeyData": privateKeyData, "publicKeyData": publicKeyData, "tag": tag])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var keyId: String {
        get {
          return snapshot["keyId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyId")
        }
      }

      public var privateKeyData: String {
        get {
          return snapshot["privateKeyData"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "privateKeyData")
        }
      }

      public var publicKeyData: String {
        get {
          return snapshot["publicKeyData"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "publicKeyData")
        }
      }

      public var tag: String? {
        get {
          return snapshot["tag"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "tag")
        }
      }
    }
  }
}

public final class RevokeTestRegistrationKeyMutation: GraphQLMutation {
  public static let operationString =
    "mutation RevokeTestRegistrationKey($input: RevokeTestRegistrationKeyInput!) {\n  revokeTestRegistrationKey(input: $input) {\n    __typename\n    id\n  }\n}"

  public var input: RevokeTestRegistrationKeyInput

  public init(input: RevokeTestRegistrationKeyInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("revokeTestRegistrationKey", arguments: ["input": GraphQLVariable("input")], type: .object(RevokeTestRegistrationKey.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(revokeTestRegistrationKey: RevokeTestRegistrationKey? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "revokeTestRegistrationKey": revokeTestRegistrationKey.flatMap { $0.snapshot }])
    }

    public var revokeTestRegistrationKey: RevokeTestRegistrationKey? {
      get {
        return (snapshot["revokeTestRegistrationKey"] as? Snapshot).flatMap { RevokeTestRegistrationKey(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "revokeTestRegistrationKey")
      }
    }

    public struct RevokeTestRegistrationKey: GraphQLSelectionSet {
      public static let possibleTypes = ["RevokeTestRegistrationKeyStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: String) {
        self.init(snapshot: ["__typename": "RevokeTestRegistrationKeyStatus", "id": id])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class RevokeTestRegistrationKeyByOwnerMutation: GraphQLMutation {
  public static let operationString =
    "mutation RevokeTestRegistrationKeyByOwner($owner: String!) {\n  revokeTestRegistrationKeyByOwner(owner: $owner) {\n    __typename\n    owner\n  }\n}"

  public var owner: String

  public init(owner: String) {
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("revokeTestRegistrationKeyByOwner", arguments: ["owner": GraphQLVariable("owner")], type: .object(RevokeTestRegistrationKeyByOwner.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(revokeTestRegistrationKeyByOwner: RevokeTestRegistrationKeyByOwner? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "revokeTestRegistrationKeyByOwner": revokeTestRegistrationKeyByOwner.flatMap { $0.snapshot }])
    }

    public var revokeTestRegistrationKeyByOwner: RevokeTestRegistrationKeyByOwner? {
      get {
        return (snapshot["revokeTestRegistrationKeyByOwner"] as? Snapshot).flatMap { RevokeTestRegistrationKeyByOwner(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "revokeTestRegistrationKeyByOwner")
      }
    }

    public struct RevokeTestRegistrationKeyByOwner: GraphQLSelectionSet {
      public static let possibleTypes = ["RevokeTestRegistrationKeyByOwnerStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(owner: String) {
        self.init(snapshot: ["__typename": "RevokeTestRegistrationKeyByOwnerStatus", "owner": owner])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var owner: String {
        get {
          return snapshot["owner"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }
    }
  }
}

public final class UploadTrustedIssuerKeyMutation: GraphQLMutation {
  public static let operationString =
    "mutation UploadTrustedIssuerKey($input: UploadTrustedIssuerKeyInput!) {\n  uploadTrustedIssuerKey(input: $input) {\n    __typename\n    id\n    issuer\n    label\n    key\n    createdAtEpochMs\n  }\n}"

  public var input: UploadTrustedIssuerKeyInput

  public init(input: UploadTrustedIssuerKeyInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadTrustedIssuerKey", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(UploadTrustedIssuerKey.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(uploadTrustedIssuerKey: UploadTrustedIssuerKey) {
      self.init(snapshot: ["__typename": "Mutation", "uploadTrustedIssuerKey": uploadTrustedIssuerKey.snapshot])
    }

    public var uploadTrustedIssuerKey: UploadTrustedIssuerKey {
      get {
        return UploadTrustedIssuerKey(snapshot: snapshot["uploadTrustedIssuerKey"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "uploadTrustedIssuerKey")
      }
    }

    public struct UploadTrustedIssuerKey: GraphQLSelectionSet {
      public static let possibleTypes = ["TrustedIssuerKey"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        GraphQLField("label", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: String, issuer: String, label: String, key: String, createdAtEpochMs: Double) {
        self.init(snapshot: ["__typename": "TrustedIssuerKey", "id": id, "issuer": issuer, "label": label, "key": key, "createdAtEpochMs": createdAtEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var issuer: String {
        get {
          return snapshot["issuer"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "issuer")
        }
      }

      public var label: String {
        get {
          return snapshot["label"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "label")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }
    }
  }
}

public final class ChangeOwnerMutation: GraphQLMutation {
  public static let operationString =
    "mutation ChangeOwner($input: ChangeOwnerInput!) {\n  changeOwner(input: $input) {\n    __typename\n    success\n  }\n}"

  public var input: ChangeOwnerInput

  public init(input: ChangeOwnerInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("changeOwner", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ChangeOwner.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(changeOwner: ChangeOwner) {
      self.init(snapshot: ["__typename": "Mutation", "changeOwner": changeOwner.snapshot])
    }

    public var changeOwner: ChangeOwner {
      get {
        return ChangeOwner(snapshot: snapshot["changeOwner"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "changeOwner")
      }
    }

    public struct ChangeOwner: GraphQLSelectionSet {
      public static let possibleTypes = ["ChangeOwnerResult"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(success: Bool) {
        self.init(snapshot: ["__typename": "ChangeOwnerResult", "success": success])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
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

public final class ResetIdentityVerificationStatusMutation: GraphQLMutation {
  public static let operationString =
    "mutation ResetIdentityVerificationStatus($input: ResetIdentityVerificationStatusRequest!) {\n  resetIdentityVerificationStatus(input: $input) {\n    __typename\n    resetStatus\n  }\n}"

  public var input: ResetIdentityVerificationStatusRequest

  public init(input: ResetIdentityVerificationStatusRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("resetIdentityVerificationStatus", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ResetIdentityVerificationStatus.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(resetIdentityVerificationStatus: ResetIdentityVerificationStatus) {
      self.init(snapshot: ["__typename": "Mutation", "resetIdentityVerificationStatus": resetIdentityVerificationStatus.snapshot])
    }

    public var resetIdentityVerificationStatus: ResetIdentityVerificationStatus {
      get {
        return ResetIdentityVerificationStatus(snapshot: snapshot["resetIdentityVerificationStatus"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "resetIdentityVerificationStatus")
      }
    }

    public struct ResetIdentityVerificationStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["ResetIdentityVerificationStatusResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("resetStatus", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(resetStatus: Bool) {
        self.init(snapshot: ["__typename": "ResetIdentityVerificationStatusResponse", "resetStatus": resetStatus])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var resetStatus: Bool {
        get {
          return snapshot["resetStatus"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "resetStatus")
        }
      }
    }
  }
}

public final class SetIdentityDocumentInfoMutation: GraphQLMutation {
  public static let operationString =
    "mutation SetIdentityDocumentInfo($input: SetIdentityDocumentInfoRequest!) {\n  setIdentityDocumentInfo(input: $input) {\n    __typename\n    updateStatus\n  }\n}"

  public var input: SetIdentityDocumentInfoRequest

  public init(input: SetIdentityDocumentInfoRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("setIdentityDocumentInfo", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SetIdentityDocumentInfo.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(setIdentityDocumentInfo: SetIdentityDocumentInfo) {
      self.init(snapshot: ["__typename": "Mutation", "setIdentityDocumentInfo": setIdentityDocumentInfo.snapshot])
    }

    public var setIdentityDocumentInfo: SetIdentityDocumentInfo {
      get {
        return SetIdentityDocumentInfo(snapshot: snapshot["setIdentityDocumentInfo"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "setIdentityDocumentInfo")
      }
    }

    public struct SetIdentityDocumentInfo: GraphQLSelectionSet {
      public static let possibleTypes = ["SetIdentityDocumentInfoResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("updateStatus", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(updateStatus: Bool) {
        self.init(snapshot: ["__typename": "SetIdentityDocumentInfoResponse", "updateStatus": updateStatus])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var updateStatus: Bool {
        get {
          return snapshot["updateStatus"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "updateStatus")
        }
      }
    }
  }
}

public final class AssistIdentityVerificationMutation: GraphQLMutation {
  public static let operationString =
    "mutation AssistIdentityVerification($input: AssistIdentityVerificationRequest!) {\n  assistIdentityVerification(input: $input) {\n    __typename\n    assistStatus\n  }\n}"

  public var input: AssistIdentityVerificationRequest

  public init(input: AssistIdentityVerificationRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("assistIdentityVerification", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(AssistIdentityVerification.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(assistIdentityVerification: AssistIdentityVerification) {
      self.init(snapshot: ["__typename": "Mutation", "assistIdentityVerification": assistIdentityVerification.snapshot])
    }

    public var assistIdentityVerification: AssistIdentityVerification {
      get {
        return AssistIdentityVerification(snapshot: snapshot["assistIdentityVerification"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "assistIdentityVerification")
      }
    }

    public struct AssistIdentityVerification: GraphQLSelectionSet {
      public static let possibleTypes = ["AssistIdentityVerificationResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("assistStatus", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(assistStatus: Bool) {
        self.init(snapshot: ["__typename": "AssistIdentityVerificationResponse", "assistStatus": assistStatus])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var assistStatus: Bool {
        get {
          return snapshot["assistStatus"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "assistStatus")
        }
      }
    }
  }
}

public final class ConfigureNotificationProviderMutation: GraphQLMutation {
  public static let operationString =
    "mutation ConfigureNotificationProvider($input: NotificationProviderInput) {\n  configureNotificationProvider(input: $input)\n}"

  public var input: NotificationProviderInput?

  public init(input: NotificationProviderInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("configureNotificationProvider", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(configureNotificationProvider: Bool? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "configureNotificationProvider": configureNotificationProvider])
    }

    public var configureNotificationProvider: Bool? {
      get {
        return snapshot["configureNotificationProvider"] as? Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "configureNotificationProvider")
      }
    }
  }
}

public final class UseNotificationProviderMutation: GraphQLMutation {
  public static let operationString =
    "mutation UseNotificationProvider($input: UseNotificationProviderInput) {\n  useNotificationProvider(input: $input)\n}"

  public var input: UseNotificationProviderInput?

  public init(input: UseNotificationProviderInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("useNotificationProvider", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(useNotificationProvider: Bool? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "useNotificationProvider": useNotificationProvider])
    }

    public var useNotificationProvider: Bool? {
      get {
        return snapshot["useNotificationProvider"] as? Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "useNotificationProvider")
      }
    }
  }
}

public final class UpdateProviderCredentialsMutation: GraphQLMutation {
  public static let operationString =
    "mutation UpdateProviderCredentials($input: NotificationProviderInput) {\n  updateProviderCredentials(input: $input)\n}"

  public var input: NotificationProviderInput?

  public init(input: NotificationProviderInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("updateProviderCredentials", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(updateProviderCredentials: Bool? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "updateProviderCredentials": updateProviderCredentials])
    }

    public var updateProviderCredentials: Bool? {
      get {
        return snapshot["updateProviderCredentials"] as? Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "updateProviderCredentials")
      }
    }
  }
}

public final class DeleteNotificationProviderMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeleteNotificationProvider($input: DeleteNotificationProviderInput) {\n  deleteNotificationProvider(input: $input)\n}"

  public var input: DeleteNotificationProviderInput?

  public init(input: DeleteNotificationProviderInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deleteNotificationProvider", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deleteNotificationProvider: Bool? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deleteNotificationProvider": deleteNotificationProvider])
    }

    public var deleteNotificationProvider: Bool? {
      get {
        return snapshot["deleteNotificationProvider"] as? Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "deleteNotificationProvider")
      }
    }
  }
}

public final class DeregisterAppOnDeviceMutation: GraphQLMutation {
  public static let operationString =
    "mutation DeregisterAppOnDevice($input: DeregisterAppOnDeviceInput) {\n  deregisterAppOnDevice(input: $input)\n}"

  public var input: DeregisterAppOnDeviceInput?

  public init(input: DeregisterAppOnDeviceInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("deregisterAppOnDevice", arguments: ["input": GraphQLVariable("input")], type: .scalar(Bool.self)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(deregisterAppOnDevice: Bool? = nil) {
      self.init(snapshot: ["__typename": "Mutation", "deregisterAppOnDevice": deregisterAppOnDevice])
    }

    public var deregisterAppOnDevice: Bool? {
      get {
        return snapshot["deregisterAppOnDevice"] as? Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "deregisterAppOnDevice")
      }
    }
  }
}

public final class UploadSudoOwnershipProofPublicKeyMutation: GraphQLMutation {
  public static let operationString =
    "mutation UploadSudoOwnershipProofPublicKey($input: UploadSudoOwnershipProofPublicKeyInput!) {\n  uploadSudoOwnershipProofPublicKey(input: $input) {\n    __typename\n    issuer\n    kid\n    key\n  }\n}"

  public var input: UploadSudoOwnershipProofPublicKeyInput

  public init(input: UploadSudoOwnershipProofPublicKeyInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("uploadSudoOwnershipProofPublicKey", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(UploadSudoOwnershipProofPublicKey.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(uploadSudoOwnershipProofPublicKey: UploadSudoOwnershipProofPublicKey) {
      self.init(snapshot: ["__typename": "Mutation", "uploadSudoOwnershipProofPublicKey": uploadSudoOwnershipProofPublicKey.snapshot])
    }

    public var uploadSudoOwnershipProofPublicKey: UploadSudoOwnershipProofPublicKey {
      get {
        return UploadSudoOwnershipProofPublicKey(snapshot: snapshot["uploadSudoOwnershipProofPublicKey"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "uploadSudoOwnershipProofPublicKey")
      }
    }

    public struct UploadSudoOwnershipProofPublicKey: GraphQLSelectionSet {
      public static let possibleTypes = ["SudoOwnershipProofPublicKey"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        GraphQLField("kid", type: .nonNull(.scalar(String.self))),
        GraphQLField("key", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(issuer: String, kid: String, key: String) {
        self.init(snapshot: ["__typename": "SudoOwnershipProofPublicKey", "issuer": issuer, "kid": kid, "key": key])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var issuer: String {
        get {
          return snapshot["issuer"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "issuer")
        }
      }

      public var kid: String {
        get {
          return snapshot["kid"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "kid")
        }
      }

      public var key: String {
        get {
          return snapshot["key"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "key")
        }
      }
    }
  }
}

public final class ResetSecureVaultUserMutation: GraphQLMutation {
  public static let operationString =
    "mutation ResetSecureVaultUser($sub: String!) {\n  resetSecureVaultUser(sub: $sub)\n}"

  public var sub: String

  public init(sub: String) {
    self.sub = sub
  }

  public var variables: GraphQLMap? {
    return ["sub": sub]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("resetSecureVaultUser", arguments: ["sub": GraphQLVariable("sub")], type: .nonNull(.scalar(Bool.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(resetSecureVaultUser: Bool) {
      self.init(snapshot: ["__typename": "Mutation", "resetSecureVaultUser": resetSecureVaultUser])
    }

    public var resetSecureVaultUser: Bool {
      get {
        return snapshot["resetSecureVaultUser"]! as! Bool
      }
      set {
        snapshot.updateValue(newValue, forKey: "resetSecureVaultUser")
      }
    }
  }
}

public final class AcceptPendingFundingSourceMutation: GraphQLMutation {
  public static let operationString =
    "mutation AcceptPendingFundingSource($input: AcceptPendingFundingSourceRequest!) {\n  acceptPendingFundingSource(input: $input) {\n    __typename\n    ... on CreditCardFundingSource {\n      id\n      owner\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      state\n      currency\n      fingerprint\n      last4\n      cardType\n      network\n    }\n    ... on BankAccountFundingSource {\n      id\n      owner\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      state\n      currency\n      fingerprint\n      bankAccountType\n      authorization {\n        __typename\n        data\n        signature\n        algorithm\n        keyId\n        content\n        contentType\n        language\n      }\n    }\n  }\n}"

  public var input: AcceptPendingFundingSourceRequest

  public init(input: AcceptPendingFundingSourceRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("acceptPendingFundingSource", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(AcceptPendingFundingSource.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(acceptPendingFundingSource: AcceptPendingFundingSource) {
      self.init(snapshot: ["__typename": "Mutation", "acceptPendingFundingSource": acceptPendingFundingSource.snapshot])
    }

    public var acceptPendingFundingSource: AcceptPendingFundingSource {
      get {
        return AcceptPendingFundingSource(snapshot: snapshot["acceptPendingFundingSource"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "acceptPendingFundingSource")
      }
    }

    public struct AcceptPendingFundingSource: GraphQLSelectionSet {
      public static let possibleTypes = ["CreditCardFundingSource", "BankAccountFundingSource"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["CreditCardFundingSource": AsCreditCardFundingSource.selections, "BankAccountFundingSource": AsBankAccountFundingSource.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeCreditCardFundingSource(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, last4: String, cardType: CardType, network: CreditCardNetwork) -> AcceptPendingFundingSource {
        return AcceptPendingFundingSource(snapshot: ["__typename": "CreditCardFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "last4": last4, "cardType": cardType, "network": network])
      }

      public static func makeBankAccountFundingSource(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, bankAccountType: BankAccountType, authorization: AsBankAccountFundingSource.Authorization) -> AcceptPendingFundingSource {
        return AcceptPendingFundingSource(snapshot: ["__typename": "BankAccountFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "bankAccountType": bankAccountType, "authorization": authorization.snapshot])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asCreditCardFundingSource: AsCreditCardFundingSource? {
        get {
          if !AsCreditCardFundingSource.possibleTypes.contains(__typename) { return nil }
          return AsCreditCardFundingSource(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsCreditCardFundingSource: GraphQLSelectionSet {
        public static let possibleTypes = ["CreditCardFundingSource"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("state", type: .nonNull(.scalar(FundingSourceState.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("fingerprint", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("last4", type: .nonNull(.scalar(String.self))),
          GraphQLField("cardType", type: .nonNull(.scalar(CardType.self))),
          GraphQLField("network", type: .nonNull(.scalar(CreditCardNetwork.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, last4: String, cardType: CardType, network: CreditCardNetwork) {
          self.init(snapshot: ["__typename": "CreditCardFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "last4": last4, "cardType": cardType, "network": network])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var state: FundingSourceState {
          get {
            return snapshot["state"]! as! FundingSourceState
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var fingerprint: GraphQLID {
          get {
            return snapshot["fingerprint"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fingerprint")
          }
        }

        public var last4: String {
          get {
            return snapshot["last4"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "last4")
          }
        }

        public var cardType: CardType {
          get {
            return snapshot["cardType"]! as! CardType
          }
          set {
            snapshot.updateValue(newValue, forKey: "cardType")
          }
        }

        public var network: CreditCardNetwork {
          get {
            return snapshot["network"]! as! CreditCardNetwork
          }
          set {
            snapshot.updateValue(newValue, forKey: "network")
          }
        }
      }

      public var asBankAccountFundingSource: AsBankAccountFundingSource? {
        get {
          if !AsBankAccountFundingSource.possibleTypes.contains(__typename) { return nil }
          return AsBankAccountFundingSource(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsBankAccountFundingSource: GraphQLSelectionSet {
        public static let possibleTypes = ["BankAccountFundingSource"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("state", type: .nonNull(.scalar(FundingSourceState.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("fingerprint", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("bankAccountType", type: .nonNull(.scalar(BankAccountType.self))),
          GraphQLField("authorization", type: .nonNull(.object(Authorization.selections))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, bankAccountType: BankAccountType, authorization: Authorization) {
          self.init(snapshot: ["__typename": "BankAccountFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "bankAccountType": bankAccountType, "authorization": authorization.snapshot])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var state: FundingSourceState {
          get {
            return snapshot["state"]! as! FundingSourceState
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var fingerprint: GraphQLID {
          get {
            return snapshot["fingerprint"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fingerprint")
          }
        }

        public var bankAccountType: BankAccountType {
          get {
            return snapshot["bankAccountType"]! as! BankAccountType
          }
          set {
            snapshot.updateValue(newValue, forKey: "bankAccountType")
          }
        }

        public var authorization: Authorization {
          get {
            return Authorization(snapshot: snapshot["authorization"]! as! Snapshot)
          }
          set {
            snapshot.updateValue(newValue.snapshot, forKey: "authorization")
          }
        }

        public struct Authorization: GraphQLSelectionSet {
          public static let possibleTypes = ["SignedAuthorizationText"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("data", type: .nonNull(.scalar(String.self))),
            GraphQLField("signature", type: .nonNull(.scalar(String.self))),
            GraphQLField("algorithm", type: .nonNull(.scalar(String.self))),
            GraphQLField("keyId", type: .nonNull(.scalar(String.self))),
            GraphQLField("content", type: .nonNull(.scalar(String.self))),
            GraphQLField("contentType", type: .nonNull(.scalar(String.self))),
            GraphQLField("language", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(data: String, signature: String, algorithm: String, keyId: String, content: String, contentType: String, language: String) {
            self.init(snapshot: ["__typename": "SignedAuthorizationText", "data": data, "signature": signature, "algorithm": algorithm, "keyId": keyId, "content": content, "contentType": contentType, "language": language])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var data: String {
            get {
              return snapshot["data"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "data")
            }
          }

          public var signature: String {
            get {
              return snapshot["signature"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "signature")
            }
          }

          public var algorithm: String {
            get {
              return snapshot["algorithm"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "algorithm")
            }
          }

          public var keyId: String {
            get {
              return snapshot["keyId"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "keyId")
            }
          }

          public var content: String {
            get {
              return snapshot["content"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "content")
            }
          }

          public var contentType: String {
            get {
              return snapshot["contentType"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "contentType")
            }
          }

          public var language: String {
            get {
              return snapshot["language"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "language")
            }
          }
        }
      }
    }
  }
}

public final class CancelFundingSourceMutation: GraphQLMutation {
  public static let operationString =
    "mutation CancelFundingSource($input: CancelFundingSourceRequest!) {\n  cancelFundingSource(input: $input) {\n    __typename\n    ... on CreditCardFundingSource {\n      id\n      owner\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      state\n      currency\n      fingerprint\n      last4\n      cardType\n      network\n    }\n    ... on BankAccountFundingSource {\n      id\n      owner\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      state\n      currency\n      fingerprint\n      bankAccountType\n      authorization {\n        __typename\n        data\n        signature\n        algorithm\n        keyId\n        content\n        contentType\n        language\n      }\n    }\n  }\n}"

  public var input: CancelFundingSourceRequest

  public init(input: CancelFundingSourceRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("cancelFundingSource", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(CancelFundingSource.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(cancelFundingSource: CancelFundingSource) {
      self.init(snapshot: ["__typename": "Mutation", "cancelFundingSource": cancelFundingSource.snapshot])
    }

    public var cancelFundingSource: CancelFundingSource {
      get {
        return CancelFundingSource(snapshot: snapshot["cancelFundingSource"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "cancelFundingSource")
      }
    }

    public struct CancelFundingSource: GraphQLSelectionSet {
      public static let possibleTypes = ["CreditCardFundingSource", "BankAccountFundingSource"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["CreditCardFundingSource": AsCreditCardFundingSource.selections, "BankAccountFundingSource": AsBankAccountFundingSource.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeCreditCardFundingSource(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, last4: String, cardType: CardType, network: CreditCardNetwork) -> CancelFundingSource {
        return CancelFundingSource(snapshot: ["__typename": "CreditCardFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "last4": last4, "cardType": cardType, "network": network])
      }

      public static func makeBankAccountFundingSource(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, bankAccountType: BankAccountType, authorization: AsBankAccountFundingSource.Authorization) -> CancelFundingSource {
        return CancelFundingSource(snapshot: ["__typename": "BankAccountFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "bankAccountType": bankAccountType, "authorization": authorization.snapshot])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asCreditCardFundingSource: AsCreditCardFundingSource? {
        get {
          if !AsCreditCardFundingSource.possibleTypes.contains(__typename) { return nil }
          return AsCreditCardFundingSource(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsCreditCardFundingSource: GraphQLSelectionSet {
        public static let possibleTypes = ["CreditCardFundingSource"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("state", type: .nonNull(.scalar(FundingSourceState.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("fingerprint", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("last4", type: .nonNull(.scalar(String.self))),
          GraphQLField("cardType", type: .nonNull(.scalar(CardType.self))),
          GraphQLField("network", type: .nonNull(.scalar(CreditCardNetwork.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, last4: String, cardType: CardType, network: CreditCardNetwork) {
          self.init(snapshot: ["__typename": "CreditCardFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "last4": last4, "cardType": cardType, "network": network])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var state: FundingSourceState {
          get {
            return snapshot["state"]! as! FundingSourceState
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var fingerprint: GraphQLID {
          get {
            return snapshot["fingerprint"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fingerprint")
          }
        }

        public var last4: String {
          get {
            return snapshot["last4"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "last4")
          }
        }

        public var cardType: CardType {
          get {
            return snapshot["cardType"]! as! CardType
          }
          set {
            snapshot.updateValue(newValue, forKey: "cardType")
          }
        }

        public var network: CreditCardNetwork {
          get {
            return snapshot["network"]! as! CreditCardNetwork
          }
          set {
            snapshot.updateValue(newValue, forKey: "network")
          }
        }
      }

      public var asBankAccountFundingSource: AsBankAccountFundingSource? {
        get {
          if !AsBankAccountFundingSource.possibleTypes.contains(__typename) { return nil }
          return AsBankAccountFundingSource(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsBankAccountFundingSource: GraphQLSelectionSet {
        public static let possibleTypes = ["BankAccountFundingSource"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("state", type: .nonNull(.scalar(FundingSourceState.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("fingerprint", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("bankAccountType", type: .nonNull(.scalar(BankAccountType.self))),
          GraphQLField("authorization", type: .nonNull(.object(Authorization.selections))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, bankAccountType: BankAccountType, authorization: Authorization) {
          self.init(snapshot: ["__typename": "BankAccountFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "bankAccountType": bankAccountType, "authorization": authorization.snapshot])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var state: FundingSourceState {
          get {
            return snapshot["state"]! as! FundingSourceState
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var fingerprint: GraphQLID {
          get {
            return snapshot["fingerprint"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fingerprint")
          }
        }

        public var bankAccountType: BankAccountType {
          get {
            return snapshot["bankAccountType"]! as! BankAccountType
          }
          set {
            snapshot.updateValue(newValue, forKey: "bankAccountType")
          }
        }

        public var authorization: Authorization {
          get {
            return Authorization(snapshot: snapshot["authorization"]! as! Snapshot)
          }
          set {
            snapshot.updateValue(newValue.snapshot, forKey: "authorization")
          }
        }

        public struct Authorization: GraphQLSelectionSet {
          public static let possibleTypes = ["SignedAuthorizationText"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("data", type: .nonNull(.scalar(String.self))),
            GraphQLField("signature", type: .nonNull(.scalar(String.self))),
            GraphQLField("algorithm", type: .nonNull(.scalar(String.self))),
            GraphQLField("keyId", type: .nonNull(.scalar(String.self))),
            GraphQLField("content", type: .nonNull(.scalar(String.self))),
            GraphQLField("contentType", type: .nonNull(.scalar(String.self))),
            GraphQLField("language", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(data: String, signature: String, algorithm: String, keyId: String, content: String, contentType: String, language: String) {
            self.init(snapshot: ["__typename": "SignedAuthorizationText", "data": data, "signature": signature, "algorithm": algorithm, "keyId": keyId, "content": content, "contentType": contentType, "language": language])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var data: String {
            get {
              return snapshot["data"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "data")
            }
          }

          public var signature: String {
            get {
              return snapshot["signature"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "signature")
            }
          }

          public var algorithm: String {
            get {
              return snapshot["algorithm"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "algorithm")
            }
          }

          public var keyId: String {
            get {
              return snapshot["keyId"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "keyId")
            }
          }

          public var content: String {
            get {
              return snapshot["content"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "content")
            }
          }

          public var contentType: String {
            get {
              return snapshot["contentType"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "contentType")
            }
          }

          public var language: String {
            get {
              return snapshot["language"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "language")
            }
          }
        }
      }
    }
  }
}

public final class ChargeServiceFeeForVirtualCardMutation: GraphQLMutation {
  public static let operationString =
    "mutation ChargeServiceFeeForVirtualCard($input: ChargeServiceFeeForVirtualCardInput) {\n  chargeServiceFeeForVirtualCard(input: $input) {\n    __typename\n    id\n    owner\n    createdAtEpochMs\n    updatedAtEpochMs\n    type\n    transactedAtEpochMs\n    billedAmount {\n      __typename\n      currency\n      amount\n    }\n    transactedAmount {\n      __typename\n      currency\n      amount\n    }\n    merchant {\n      __typename\n      id\n      mcc\n      country\n      city\n      state\n      postalCode\n    }\n    declineReason\n    feeReason\n    causeId\n    feeId\n    detail {\n      __typename\n      fundingSourceId\n      fundingSourceLast4\n      fundingSourceNetwork\n    }\n  }\n}"

  public var input: ChargeServiceFeeForVirtualCardInput?

  public init(input: ChargeServiceFeeForVirtualCardInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("chargeServiceFeeForVirtualCard", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ChargeServiceFeeForVirtualCard.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(chargeServiceFeeForVirtualCard: ChargeServiceFeeForVirtualCard) {
      self.init(snapshot: ["__typename": "Mutation", "chargeServiceFeeForVirtualCard": chargeServiceFeeForVirtualCard.snapshot])
    }

    public var chargeServiceFeeForVirtualCard: ChargeServiceFeeForVirtualCard {
      get {
        return ChargeServiceFeeForVirtualCard(snapshot: snapshot["chargeServiceFeeForVirtualCard"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "chargeServiceFeeForVirtualCard")
      }
    }

    public struct ChargeServiceFeeForVirtualCard: GraphQLSelectionSet {
      public static let possibleTypes = ["Transaction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("type", type: .nonNull(.scalar(TransactionType.self))),
        GraphQLField("transactedAtEpochMs", type: .nonNull(.scalar(String.self))),
        GraphQLField("billedAmount", type: .nonNull(.object(BilledAmount.selections))),
        GraphQLField("transactedAmount", type: .nonNull(.object(TransactedAmount.selections))),
        GraphQLField("merchant", type: .object(Merchant.selections)),
        GraphQLField("declineReason", type: .scalar(String.self)),
        GraphQLField("feeReason", type: .scalar(FeeReason.self)),
        GraphQLField("causeId", type: .scalar(String.self)),
        GraphQLField("feeId", type: .scalar(String.self)),
        GraphQLField("detail", type: .list(.nonNull(.object(Detail.selections)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, owner: GraphQLID, createdAtEpochMs: Double, updatedAtEpochMs: Double, type: TransactionType, transactedAtEpochMs: String, billedAmount: BilledAmount, transactedAmount: TransactedAmount, merchant: Merchant? = nil, declineReason: String? = nil, feeReason: FeeReason? = nil, causeId: String? = nil, feeId: String? = nil, detail: [Detail]? = nil) {
        self.init(snapshot: ["__typename": "Transaction", "id": id, "owner": owner, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "type": type, "transactedAtEpochMs": transactedAtEpochMs, "billedAmount": billedAmount.snapshot, "transactedAmount": transactedAmount.snapshot, "merchant": merchant.flatMap { $0.snapshot }, "declineReason": declineReason, "feeReason": feeReason, "causeId": causeId, "feeId": feeId, "detail": detail.flatMap { $0.map { $0.snapshot } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var type: TransactionType {
        get {
          return snapshot["type"]! as! TransactionType
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var transactedAtEpochMs: String {
        get {
          return snapshot["transactedAtEpochMs"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "transactedAtEpochMs")
        }
      }

      public var billedAmount: BilledAmount {
        get {
          return BilledAmount(snapshot: snapshot["billedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billedAmount")
        }
      }

      public var transactedAmount: TransactedAmount {
        get {
          return TransactedAmount(snapshot: snapshot["transactedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "transactedAmount")
        }
      }

      public var merchant: Merchant? {
        get {
          return (snapshot["merchant"] as? Snapshot).flatMap { Merchant(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "merchant")
        }
      }

      public var declineReason: String? {
        get {
          return snapshot["declineReason"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "declineReason")
        }
      }

      public var feeReason: FeeReason? {
        get {
          return snapshot["feeReason"] as? FeeReason
        }
        set {
          snapshot.updateValue(newValue, forKey: "feeReason")
        }
      }

      public var causeId: String? {
        get {
          return snapshot["causeId"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "causeId")
        }
      }

      public var feeId: String? {
        get {
          return snapshot["feeId"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "feeId")
        }
      }

      public var detail: [Detail]? {
        get {
          return (snapshot["detail"] as? [Snapshot]).flatMap { $0.map { Detail(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.snapshot } }, forKey: "detail")
        }
      }

      public struct BilledAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["UserCurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Double) {
          self.init(snapshot: ["__typename": "UserCurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Double {
          get {
            return snapshot["amount"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }

      public struct TransactedAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["UserCurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Double) {
          self.init(snapshot: ["__typename": "UserCurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Double {
          get {
            return snapshot["amount"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }

      public struct Merchant: GraphQLSelectionSet {
        public static let possibleTypes = ["Merchant"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("mcc", type: .nonNull(.scalar(String.self))),
          GraphQLField("country", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .scalar(String.self)),
          GraphQLField("state", type: .scalar(String.self)),
          GraphQLField("postalCode", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, mcc: String, country: String, city: String? = nil, state: String? = nil, postalCode: String? = nil) {
          self.init(snapshot: ["__typename": "Merchant", "id": id, "mcc": mcc, "country": country, "city": city, "state": state, "postalCode": postalCode])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var mcc: String {
          get {
            return snapshot["mcc"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "mcc")
          }
        }

        public var country: String {
          get {
            return snapshot["country"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "country")
          }
        }

        public var city: String? {
          get {
            return snapshot["city"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var state: String? {
          get {
            return snapshot["state"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var postalCode: String? {
          get {
            return snapshot["postalCode"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "postalCode")
          }
        }
      }

      public struct Detail: GraphQLSelectionSet {
        public static let possibleTypes = ["TransactionDetail"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("fundingSourceId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("fundingSourceLast4", type: .nonNull(.scalar(String.self))),
          GraphQLField("fundingSourceNetwork", type: .nonNull(.scalar(CreditCardNetwork.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(fundingSourceId: GraphQLID, fundingSourceLast4: String, fundingSourceNetwork: CreditCardNetwork) {
          self.init(snapshot: ["__typename": "TransactionDetail", "fundingSourceId": fundingSourceId, "fundingSourceLast4": fundingSourceLast4, "fundingSourceNetwork": fundingSourceNetwork])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fundingSourceId: GraphQLID {
          get {
            return snapshot["fundingSourceId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fundingSourceId")
          }
        }

        public var fundingSourceLast4: String {
          get {
            return snapshot["fundingSourceLast4"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "fundingSourceLast4")
          }
        }

        public var fundingSourceNetwork: CreditCardNetwork {
          get {
            return snapshot["fundingSourceNetwork"]! as! CreditCardNetwork
          }
          set {
            snapshot.updateValue(newValue, forKey: "fundingSourceNetwork")
          }
        }
      }
    }
  }
}

public final class RefundServiceFeeForVirtualCardMutation: GraphQLMutation {
  public static let operationString =
    "mutation RefundServiceFeeForVirtualCard($input: RefundServiceFeeForVirtualCardInput) {\n  refundServiceFeeForVirtualCard(input: $input) {\n    __typename\n    id\n    owner\n    createdAtEpochMs\n    updatedAtEpochMs\n    type\n    transactedAtEpochMs\n    billedAmount {\n      __typename\n      currency\n      amount\n    }\n    transactedAmount {\n      __typename\n      currency\n      amount\n    }\n    merchant {\n      __typename\n      id\n      mcc\n      country\n      city\n      state\n      postalCode\n    }\n    declineReason\n    feeReason\n    causeId\n    feeId\n    detail {\n      __typename\n      fundingSourceId\n      fundingSourceLast4\n      fundingSourceNetwork\n    }\n  }\n}"

  public var input: RefundServiceFeeForVirtualCardInput?

  public init(input: RefundServiceFeeForVirtualCardInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("refundServiceFeeForVirtualCard", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(RefundServiceFeeForVirtualCard.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(refundServiceFeeForVirtualCard: RefundServiceFeeForVirtualCard) {
      self.init(snapshot: ["__typename": "Mutation", "refundServiceFeeForVirtualCard": refundServiceFeeForVirtualCard.snapshot])
    }

    public var refundServiceFeeForVirtualCard: RefundServiceFeeForVirtualCard {
      get {
        return RefundServiceFeeForVirtualCard(snapshot: snapshot["refundServiceFeeForVirtualCard"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "refundServiceFeeForVirtualCard")
      }
    }

    public struct RefundServiceFeeForVirtualCard: GraphQLSelectionSet {
      public static let possibleTypes = ["Transaction"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("type", type: .nonNull(.scalar(TransactionType.self))),
        GraphQLField("transactedAtEpochMs", type: .nonNull(.scalar(String.self))),
        GraphQLField("billedAmount", type: .nonNull(.object(BilledAmount.selections))),
        GraphQLField("transactedAmount", type: .nonNull(.object(TransactedAmount.selections))),
        GraphQLField("merchant", type: .object(Merchant.selections)),
        GraphQLField("declineReason", type: .scalar(String.self)),
        GraphQLField("feeReason", type: .scalar(FeeReason.self)),
        GraphQLField("causeId", type: .scalar(String.self)),
        GraphQLField("feeId", type: .scalar(String.self)),
        GraphQLField("detail", type: .list(.nonNull(.object(Detail.selections)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, owner: GraphQLID, createdAtEpochMs: Double, updatedAtEpochMs: Double, type: TransactionType, transactedAtEpochMs: String, billedAmount: BilledAmount, transactedAmount: TransactedAmount, merchant: Merchant? = nil, declineReason: String? = nil, feeReason: FeeReason? = nil, causeId: String? = nil, feeId: String? = nil, detail: [Detail]? = nil) {
        self.init(snapshot: ["__typename": "Transaction", "id": id, "owner": owner, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "type": type, "transactedAtEpochMs": transactedAtEpochMs, "billedAmount": billedAmount.snapshot, "transactedAmount": transactedAmount.snapshot, "merchant": merchant.flatMap { $0.snapshot }, "declineReason": declineReason, "feeReason": feeReason, "causeId": causeId, "feeId": feeId, "detail": detail.flatMap { $0.map { $0.snapshot } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var type: TransactionType {
        get {
          return snapshot["type"]! as! TransactionType
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var transactedAtEpochMs: String {
        get {
          return snapshot["transactedAtEpochMs"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "transactedAtEpochMs")
        }
      }

      public var billedAmount: BilledAmount {
        get {
          return BilledAmount(snapshot: snapshot["billedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billedAmount")
        }
      }

      public var transactedAmount: TransactedAmount {
        get {
          return TransactedAmount(snapshot: snapshot["transactedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "transactedAmount")
        }
      }

      public var merchant: Merchant? {
        get {
          return (snapshot["merchant"] as? Snapshot).flatMap { Merchant(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue?.snapshot, forKey: "merchant")
        }
      }

      public var declineReason: String? {
        get {
          return snapshot["declineReason"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "declineReason")
        }
      }

      public var feeReason: FeeReason? {
        get {
          return snapshot["feeReason"] as? FeeReason
        }
        set {
          snapshot.updateValue(newValue, forKey: "feeReason")
        }
      }

      public var causeId: String? {
        get {
          return snapshot["causeId"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "causeId")
        }
      }

      public var feeId: String? {
        get {
          return snapshot["feeId"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "feeId")
        }
      }

      public var detail: [Detail]? {
        get {
          return (snapshot["detail"] as? [Snapshot]).flatMap { $0.map { Detail(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.snapshot } }, forKey: "detail")
        }
      }

      public struct BilledAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["UserCurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Double) {
          self.init(snapshot: ["__typename": "UserCurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Double {
          get {
            return snapshot["amount"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }

      public struct TransactedAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["UserCurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Double) {
          self.init(snapshot: ["__typename": "UserCurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Double {
          get {
            return snapshot["amount"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }

      public struct Merchant: GraphQLSelectionSet {
        public static let possibleTypes = ["Merchant"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("mcc", type: .nonNull(.scalar(String.self))),
          GraphQLField("country", type: .nonNull(.scalar(String.self))),
          GraphQLField("city", type: .scalar(String.self)),
          GraphQLField("state", type: .scalar(String.self)),
          GraphQLField("postalCode", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, mcc: String, country: String, city: String? = nil, state: String? = nil, postalCode: String? = nil) {
          self.init(snapshot: ["__typename": "Merchant", "id": id, "mcc": mcc, "country": country, "city": city, "state": state, "postalCode": postalCode])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var mcc: String {
          get {
            return snapshot["mcc"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "mcc")
          }
        }

        public var country: String {
          get {
            return snapshot["country"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "country")
          }
        }

        public var city: String? {
          get {
            return snapshot["city"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "city")
          }
        }

        public var state: String? {
          get {
            return snapshot["state"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var postalCode: String? {
          get {
            return snapshot["postalCode"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "postalCode")
          }
        }
      }

      public struct Detail: GraphQLSelectionSet {
        public static let possibleTypes = ["TransactionDetail"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("fundingSourceId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("fundingSourceLast4", type: .nonNull(.scalar(String.self))),
          GraphQLField("fundingSourceNetwork", type: .nonNull(.scalar(CreditCardNetwork.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(fundingSourceId: GraphQLID, fundingSourceLast4: String, fundingSourceNetwork: CreditCardNetwork) {
          self.init(snapshot: ["__typename": "TransactionDetail", "fundingSourceId": fundingSourceId, "fundingSourceLast4": fundingSourceLast4, "fundingSourceNetwork": fundingSourceNetwork])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fundingSourceId: GraphQLID {
          get {
            return snapshot["fundingSourceId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fundingSourceId")
          }
        }

        public var fundingSourceLast4: String {
          get {
            return snapshot["fundingSourceLast4"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "fundingSourceLast4")
          }
        }

        public var fundingSourceNetwork: CreditCardNetwork {
          get {
            return snapshot["fundingSourceNetwork"]! as! CreditCardNetwork
          }
          set {
            snapshot.updateValue(newValue, forKey: "fundingSourceNetwork")
          }
        }
      }
    }
  }
}

public final class SimulateAuthorizationMutation: GraphQLMutation {
  public static let operationString =
    "mutation SimulateAuthorization($input: SimulateAuthorizationRequest!) {\n  simulateAuthorization(input: $input) {\n    __typename\n    id\n    approved\n    billedAmount {\n      __typename\n      currency\n      amount\n    }\n    declineReason\n    createdAtEpochMs\n    updatedAtEpochMs\n    billed {\n      __typename\n      currency\n      amount\n    }\n    authorizationCode\n  }\n}"

  public var input: SimulateAuthorizationRequest

  public init(input: SimulateAuthorizationRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("simulateAuthorization", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SimulateAuthorization.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(simulateAuthorization: SimulateAuthorization) {
      self.init(snapshot: ["__typename": "Mutation", "simulateAuthorization": simulateAuthorization.snapshot])
    }

    public var simulateAuthorization: SimulateAuthorization {
      get {
        return SimulateAuthorization(snapshot: snapshot["simulateAuthorization"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "simulateAuthorization")
      }
    }

    public struct SimulateAuthorization: GraphQLSelectionSet {
      public static let possibleTypes = ["SimulateAuthorizationResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("approved", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("billedAmount", type: .nonNull(.object(BilledAmount.selections))),
        GraphQLField("declineReason", type: .scalar(String.self)),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("billed", type: .nonNull(.object(Billed.selections))),
        GraphQLField("authorizationCode", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, approved: Bool, billedAmount: BilledAmount, declineReason: String? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, billed: Billed, authorizationCode: String? = nil) {
        self.init(snapshot: ["__typename": "SimulateAuthorizationResponse", "id": id, "approved": approved, "billedAmount": billedAmount.snapshot, "declineReason": declineReason, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "billed": billed.snapshot, "authorizationCode": authorizationCode])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var approved: Bool {
        get {
          return snapshot["approved"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "approved")
        }
      }

      public var billedAmount: BilledAmount {
        get {
          return BilledAmount(snapshot: snapshot["billedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billedAmount")
        }
      }

      public var declineReason: String? {
        get {
          return snapshot["declineReason"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "declineReason")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var billed: Billed {
        get {
          return Billed(snapshot: snapshot["billed"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billed")
        }
      }

      public var authorizationCode: String? {
        get {
          return snapshot["authorizationCode"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "authorizationCode")
        }
      }

      public struct BilledAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["CurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Int) {
          self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Int {
          get {
            return snapshot["amount"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }

      public struct Billed: GraphQLSelectionSet {
        public static let possibleTypes = ["CurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Int) {
          self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Int {
          get {
            return snapshot["amount"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }
    }
  }
}

public final class SimulateIncrementalAuthorizationMutation: GraphQLMutation {
  public static let operationString =
    "mutation SimulateIncrementalAuthorization($input: SimulateIncrementalAuthorizationRequest!) {\n  simulateIncrementalAuthorization(input: $input) {\n    __typename\n    id\n    approved\n    billedAmount {\n      __typename\n      currency\n      amount\n    }\n    declineReason\n    createdAtEpochMs\n    updatedAtEpochMs\n    billed {\n      __typename\n      currency\n      amount\n    }\n    authorizationCode\n  }\n}"

  public var input: SimulateIncrementalAuthorizationRequest

  public init(input: SimulateIncrementalAuthorizationRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("simulateIncrementalAuthorization", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SimulateIncrementalAuthorization.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(simulateIncrementalAuthorization: SimulateIncrementalAuthorization) {
      self.init(snapshot: ["__typename": "Mutation", "simulateIncrementalAuthorization": simulateIncrementalAuthorization.snapshot])
    }

    public var simulateIncrementalAuthorization: SimulateIncrementalAuthorization {
      get {
        return SimulateIncrementalAuthorization(snapshot: snapshot["simulateIncrementalAuthorization"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "simulateIncrementalAuthorization")
      }
    }

    public struct SimulateIncrementalAuthorization: GraphQLSelectionSet {
      public static let possibleTypes = ["SimulateAuthorizationResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("approved", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("billedAmount", type: .nonNull(.object(BilledAmount.selections))),
        GraphQLField("declineReason", type: .scalar(String.self)),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("billed", type: .nonNull(.object(Billed.selections))),
        GraphQLField("authorizationCode", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, approved: Bool, billedAmount: BilledAmount, declineReason: String? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, billed: Billed, authorizationCode: String? = nil) {
        self.init(snapshot: ["__typename": "SimulateAuthorizationResponse", "id": id, "approved": approved, "billedAmount": billedAmount.snapshot, "declineReason": declineReason, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "billed": billed.snapshot, "authorizationCode": authorizationCode])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var approved: Bool {
        get {
          return snapshot["approved"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "approved")
        }
      }

      public var billedAmount: BilledAmount {
        get {
          return BilledAmount(snapshot: snapshot["billedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billedAmount")
        }
      }

      public var declineReason: String? {
        get {
          return snapshot["declineReason"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "declineReason")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var billed: Billed {
        get {
          return Billed(snapshot: snapshot["billed"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billed")
        }
      }

      public var authorizationCode: String? {
        get {
          return snapshot["authorizationCode"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "authorizationCode")
        }
      }

      public struct BilledAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["CurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Int) {
          self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Int {
          get {
            return snapshot["amount"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }

      public struct Billed: GraphQLSelectionSet {
        public static let possibleTypes = ["CurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Int) {
          self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Int {
          get {
            return snapshot["amount"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }
    }
  }
}

public final class SimulateReversalMutation: GraphQLMutation {
  public static let operationString =
    "mutation SimulateReversal($input: SimulateReversalRequest!) {\n  simulateReversal(input: $input) {\n    __typename\n    id\n    billedAmount {\n      __typename\n      currency\n      amount\n    }\n    createdAtEpochMs\n    updatedAtEpochMs\n  }\n}"

  public var input: SimulateReversalRequest

  public init(input: SimulateReversalRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("simulateReversal", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SimulateReversal.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(simulateReversal: SimulateReversal) {
      self.init(snapshot: ["__typename": "Mutation", "simulateReversal": simulateReversal.snapshot])
    }

    public var simulateReversal: SimulateReversal {
      get {
        return SimulateReversal(snapshot: snapshot["simulateReversal"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "simulateReversal")
      }
    }

    public struct SimulateReversal: GraphQLSelectionSet {
      public static let possibleTypes = ["SimulateReversalResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("billedAmount", type: .nonNull(.object(BilledAmount.selections))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, billedAmount: BilledAmount, createdAtEpochMs: Double, updatedAtEpochMs: Double) {
        self.init(snapshot: ["__typename": "SimulateReversalResponse", "id": id, "billedAmount": billedAmount.snapshot, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var billedAmount: BilledAmount {
        get {
          return BilledAmount(snapshot: snapshot["billedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billedAmount")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public struct BilledAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["CurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Int) {
          self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Int {
          get {
            return snapshot["amount"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }
    }
  }
}

public final class SimulateAuthorizationExpiryMutation: GraphQLMutation {
  public static let operationString =
    "mutation SimulateAuthorizationExpiry($input: SimulateAuthorizationExpiryRequest!) {\n  simulateAuthorizationExpiry(input: $input) {\n    __typename\n    id\n    createdAtEpochMs\n    updatedAtEpochMs\n  }\n}"

  public var input: SimulateAuthorizationExpiryRequest

  public init(input: SimulateAuthorizationExpiryRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("simulateAuthorizationExpiry", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SimulateAuthorizationExpiry.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(simulateAuthorizationExpiry: SimulateAuthorizationExpiry) {
      self.init(snapshot: ["__typename": "Mutation", "simulateAuthorizationExpiry": simulateAuthorizationExpiry.snapshot])
    }

    public var simulateAuthorizationExpiry: SimulateAuthorizationExpiry {
      get {
        return SimulateAuthorizationExpiry(snapshot: snapshot["simulateAuthorizationExpiry"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "simulateAuthorizationExpiry")
      }
    }

    public struct SimulateAuthorizationExpiry: GraphQLSelectionSet {
      public static let possibleTypes = ["SimulateAuthorizationExpiryResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, createdAtEpochMs: Double, updatedAtEpochMs: Double) {
        self.init(snapshot: ["__typename": "SimulateAuthorizationExpiryResponse", "id": id, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }
    }
  }
}

public final class SimulateRefundMutation: GraphQLMutation {
  public static let operationString =
    "mutation SimulateRefund($input: SimulateRefundRequest!) {\n  simulateRefund(input: $input) {\n    __typename\n    id\n    billedAmount {\n      __typename\n      currency\n      amount\n    }\n    createdAtEpochMs\n    updatedAtEpochMs\n  }\n}"

  public var input: SimulateRefundRequest

  public init(input: SimulateRefundRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("simulateRefund", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SimulateRefund.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(simulateRefund: SimulateRefund) {
      self.init(snapshot: ["__typename": "Mutation", "simulateRefund": simulateRefund.snapshot])
    }

    public var simulateRefund: SimulateRefund {
      get {
        return SimulateRefund(snapshot: snapshot["simulateRefund"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "simulateRefund")
      }
    }

    public struct SimulateRefund: GraphQLSelectionSet {
      public static let possibleTypes = ["SimulateRefundResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("billedAmount", type: .nonNull(.object(BilledAmount.selections))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, billedAmount: BilledAmount, createdAtEpochMs: Double, updatedAtEpochMs: Double) {
        self.init(snapshot: ["__typename": "SimulateRefundResponse", "id": id, "billedAmount": billedAmount.snapshot, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var billedAmount: BilledAmount {
        get {
          return BilledAmount(snapshot: snapshot["billedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billedAmount")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public struct BilledAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["CurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Int) {
          self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Int {
          get {
            return snapshot["amount"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }
    }
  }
}

public final class SimulateDebitMutation: GraphQLMutation {
  public static let operationString =
    "mutation SimulateDebit($input: SimulateDebitRequest!) {\n  simulateDebit(input: $input) {\n    __typename\n    id\n    billedAmount {\n      __typename\n      currency\n      amount\n    }\n    createdAtEpochMs\n    updatedAtEpochMs\n  }\n}"

  public var input: SimulateDebitRequest

  public init(input: SimulateDebitRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("simulateDebit", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SimulateDebit.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(simulateDebit: SimulateDebit) {
      self.init(snapshot: ["__typename": "Mutation", "simulateDebit": simulateDebit.snapshot])
    }

    public var simulateDebit: SimulateDebit {
      get {
        return SimulateDebit(snapshot: snapshot["simulateDebit"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "simulateDebit")
      }
    }

    public struct SimulateDebit: GraphQLSelectionSet {
      public static let possibleTypes = ["SimulateDebitResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("billedAmount", type: .nonNull(.object(BilledAmount.selections))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, billedAmount: BilledAmount, createdAtEpochMs: Double, updatedAtEpochMs: Double) {
        self.init(snapshot: ["__typename": "SimulateDebitResponse", "id": id, "billedAmount": billedAmount.snapshot, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var billedAmount: BilledAmount {
        get {
          return BilledAmount(snapshot: snapshot["billedAmount"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "billedAmount")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public struct BilledAmount: GraphQLSelectionSet {
        public static let possibleTypes = ["CurrencyAmount"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(currency: String, amount: Int) {
          self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var amount: Int {
          get {
            return snapshot["amount"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "amount")
          }
        }
      }
    }
  }
}

public final class ListDistributedVaultsBySubQuery: GraphQLQuery {
  public static let operationString =
    "query ListDistributedVaultsBySub($owner: ID!, $limit: Int, $nextToken: String) {\n  listDistributedVaultsBySub(owner: $owner, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      owner\n      blobFormat\n      encryptionMethod\n    }\n    nextToken\n  }\n}"

  public var owner: GraphQLID
  public var limit: Int?
  public var nextToken: String?

  public init(owner: GraphQLID, limit: Int? = nil, nextToken: String? = nil) {
    self.owner = owner
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["owner": owner, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listDistributedVaultsBySub", arguments: ["owner": GraphQLVariable("owner"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .nonNull(.object(ListDistributedVaultsBySub.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listDistributedVaultsBySub: ListDistributedVaultsBySub) {
      self.init(snapshot: ["__typename": "Query", "listDistributedVaultsBySub": listDistributedVaultsBySub.snapshot])
    }

    public var listDistributedVaultsBySub: ListDistributedVaultsBySub {
      get {
        return ListDistributedVaultsBySub(snapshot: snapshot["listDistributedVaultsBySub"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listDistributedVaultsBySub")
      }
    }

    public struct ListDistributedVaultsBySub: GraphQLSelectionSet {
      public static let possibleTypes = ["DistributedVaultMetadataConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "DistributedVaultMetadataConnection", "items": items.map { $0.snapshot }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (snapshot["items"] as! [Snapshot]).map { Item(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["DistributedVaultMetadata"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
          GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blobFormat: String, encryptionMethod: String) {
          self.init(snapshot: ["__typename": "DistributedVaultMetadata", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var blobFormat: String {
          get {
            return snapshot["blobFormat"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "blobFormat")
          }
        }

        public var encryptionMethod: String {
          get {
            return snapshot["encryptionMethod"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "encryptionMethod")
          }
        }
      }
    }
  }
}

public final class ListDistributedVaultMembersQuery: GraphQLQuery {
  public static let operationString =
    "query ListDistributedVaultMembers($vaultId: ID!, $limit: Int, $nextToken: String) {\n  listDistributedVaultMembers(\n    vaultId: $vaultId\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      vaultId\n      accessRole\n      publicKey\n      owner\n    }\n    nextToken\n  }\n}"

  public var vaultId: GraphQLID
  public var limit: Int?
  public var nextToken: String?

  public init(vaultId: GraphQLID, limit: Int? = nil, nextToken: String? = nil) {
    self.vaultId = vaultId
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["vaultId": vaultId, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listDistributedVaultMembers", arguments: ["vaultId": GraphQLVariable("vaultId"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .nonNull(.object(ListDistributedVaultMember.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listDistributedVaultMembers: ListDistributedVaultMember) {
      self.init(snapshot: ["__typename": "Query", "listDistributedVaultMembers": listDistributedVaultMembers.snapshot])
    }

    public var listDistributedVaultMembers: ListDistributedVaultMember {
      get {
        return ListDistributedVaultMember(snapshot: snapshot["listDistributedVaultMembers"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listDistributedVaultMembers")
      }
    }

    public struct ListDistributedVaultMember: GraphQLSelectionSet {
      public static let possibleTypes = ["DistributedVaultMemberMetadataConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "DistributedVaultMemberMetadataConnection", "items": items.map { $0.snapshot }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (snapshot["items"] as! [Snapshot]).map { Item(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["DistributedVaultMemberMetadata"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("vaultId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("accessRole", type: .nonNull(.scalar(AccessRole.self))),
          GraphQLField("publicKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, vaultId: GraphQLID, accessRole: AccessRole, publicKey: String, owner: GraphQLID) {
          self.init(snapshot: ["__typename": "DistributedVaultMemberMetadata", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "vaultId": vaultId, "accessRole": accessRole, "publicKey": publicKey, "owner": owner])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var vaultId: GraphQLID {
          get {
            return snapshot["vaultId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "vaultId")
          }
        }

        public var accessRole: AccessRole {
          get {
            return snapshot["accessRole"]! as! AccessRole
          }
          set {
            snapshot.updateValue(newValue, forKey: "accessRole")
          }
        }

        public var publicKey: String {
          get {
            return snapshot["publicKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "publicKey")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }
      }
    }
  }
}

public final class ListUserEmailAddressesQuery: GraphQLQuery {
  public static let operationString =
    "query ListUserEmailAddresses($sub: String!) {\n  listUserEmailAddresses(sub: $sub) {\n    __typename\n    id\n    owner\n    owners {\n      __typename\n      id\n      issuer\n    }\n    identityId\n    keyRingId\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    lastReceivedAtEpochMs\n    emailAddress\n    size\n    folders {\n      __typename\n      id\n      owner\n      emailAddressId\n      folderName\n      size\n      unseenCount\n      ttl\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n    }\n  }\n}"

  public var sub: String

  public init(sub: String) {
    self.sub = sub
  }

  public var variables: GraphQLMap? {
    return ["sub": sub]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listUserEmailAddresses", arguments: ["sub": GraphQLVariable("sub")], type: .nonNull(.list(.nonNull(.object(ListUserEmailAddress.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listUserEmailAddresses: [ListUserEmailAddress]) {
      self.init(snapshot: ["__typename": "Query", "listUserEmailAddresses": listUserEmailAddresses.map { $0.snapshot }])
    }

    public var listUserEmailAddresses: [ListUserEmailAddress] {
      get {
        return (snapshot["listUserEmailAddresses"] as! [Snapshot]).map { ListUserEmailAddress(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "listUserEmailAddresses")
      }
    }

    public struct ListUserEmailAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["EmailAddress"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
        GraphQLField("identityId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("keyRingId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("lastReceivedAtEpochMs", type: .scalar(Double.self)),
        GraphQLField("emailAddress", type: .nonNull(.scalar(String.self))),
        GraphQLField("size", type: .nonNull(.scalar(Double.self))),
        GraphQLField("folders", type: .nonNull(.list(.nonNull(.object(Folder.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, owner: GraphQLID, owners: [Owner], identityId: GraphQLID, keyRingId: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, lastReceivedAtEpochMs: Double? = nil, emailAddress: String, size: Double, folders: [Folder]) {
        self.init(snapshot: ["__typename": "EmailAddress", "id": id, "owner": owner, "owners": owners.map { $0.snapshot }, "identityId": identityId, "keyRingId": keyRingId, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "lastReceivedAtEpochMs": lastReceivedAtEpochMs, "emailAddress": emailAddress, "size": size, "folders": folders.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public var identityId: GraphQLID {
        get {
          return snapshot["identityId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "identityId")
        }
      }

      public var keyRingId: GraphQLID {
        get {
          return snapshot["keyRingId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyRingId")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var lastReceivedAtEpochMs: Double? {
        get {
          return snapshot["lastReceivedAtEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReceivedAtEpochMs")
        }
      }

      public var emailAddress: String {
        get {
          return snapshot["emailAddress"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "emailAddress")
        }
      }

      public var size: Double {
        get {
          return snapshot["size"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "size")
        }
      }

      public var folders: [Folder] {
        get {
          return (snapshot["folders"] as! [Snapshot]).map { Folder(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "folders")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }

      public struct Folder: GraphQLSelectionSet {
        public static let possibleTypes = ["EmailFolder"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("emailAddressId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("folderName", type: .nonNull(.scalar(String.self))),
          GraphQLField("size", type: .nonNull(.scalar(Double.self))),
          GraphQLField("unseenCount", type: .nonNull(.scalar(Double.self))),
          GraphQLField("ttl", type: .scalar(Double.self)),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, emailAddressId: GraphQLID, folderName: String, size: Double, unseenCount: Double, ttl: Double? = nil, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double) {
          self.init(snapshot: ["__typename": "EmailFolder", "id": id, "owner": owner, "emailAddressId": emailAddressId, "folderName": folderName, "size": size, "unseenCount": unseenCount, "ttl": ttl, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var emailAddressId: GraphQLID {
          get {
            return snapshot["emailAddressId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "emailAddressId")
          }
        }

        public var folderName: String {
          get {
            return snapshot["folderName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "folderName")
          }
        }

        public var size: Double {
          get {
            return snapshot["size"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "size")
          }
        }

        public var unseenCount: Double {
          get {
            return snapshot["unseenCount"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "unseenCount")
          }
        }

        public var ttl: Double? {
          get {
            return snapshot["ttl"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "ttl")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }
      }
    }
  }
}

public final class GetEmailAddressMetadataByEmailAddressQuery: GraphQLQuery {
  public static let operationString =
    "query GetEmailAddressMetadataByEmailAddress($emailAddress: String!) {\n  getEmailAddressMetadataByEmailAddress(emailAddress: $emailAddress) {\n    __typename\n    id\n    owner\n    owners {\n      __typename\n      id\n      issuer\n    }\n    identityId\n    keyRingId\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    lastReceivedAtEpochMs\n    emailAddress\n    size\n    folders {\n      __typename\n      id\n      owner\n      emailAddressId\n      folderName\n      size\n      unseenCount\n      ttl\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n    }\n  }\n}"

  public var emailAddress: String

  public init(emailAddress: String) {
    self.emailAddress = emailAddress
  }

  public var variables: GraphQLMap? {
    return ["emailAddress": emailAddress]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEmailAddressMetadataByEmailAddress", arguments: ["emailAddress": GraphQLVariable("emailAddress")], type: .object(GetEmailAddressMetadataByEmailAddress.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEmailAddressMetadataByEmailAddress: GetEmailAddressMetadataByEmailAddress? = nil) {
      self.init(snapshot: ["__typename": "Query", "getEmailAddressMetadataByEmailAddress": getEmailAddressMetadataByEmailAddress.flatMap { $0.snapshot }])
    }

    public var getEmailAddressMetadataByEmailAddress: GetEmailAddressMetadataByEmailAddress? {
      get {
        return (snapshot["getEmailAddressMetadataByEmailAddress"] as? Snapshot).flatMap { GetEmailAddressMetadataByEmailAddress(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getEmailAddressMetadataByEmailAddress")
      }
    }

    public struct GetEmailAddressMetadataByEmailAddress: GraphQLSelectionSet {
      public static let possibleTypes = ["EmailAddress"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
        GraphQLField("identityId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("keyRingId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("lastReceivedAtEpochMs", type: .scalar(Double.self)),
        GraphQLField("emailAddress", type: .nonNull(.scalar(String.self))),
        GraphQLField("size", type: .nonNull(.scalar(Double.self))),
        GraphQLField("folders", type: .nonNull(.list(.nonNull(.object(Folder.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, owner: GraphQLID, owners: [Owner], identityId: GraphQLID, keyRingId: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, lastReceivedAtEpochMs: Double? = nil, emailAddress: String, size: Double, folders: [Folder]) {
        self.init(snapshot: ["__typename": "EmailAddress", "id": id, "owner": owner, "owners": owners.map { $0.snapshot }, "identityId": identityId, "keyRingId": keyRingId, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "lastReceivedAtEpochMs": lastReceivedAtEpochMs, "emailAddress": emailAddress, "size": size, "folders": folders.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public var identityId: GraphQLID {
        get {
          return snapshot["identityId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "identityId")
        }
      }

      public var keyRingId: GraphQLID {
        get {
          return snapshot["keyRingId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyRingId")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var lastReceivedAtEpochMs: Double? {
        get {
          return snapshot["lastReceivedAtEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastReceivedAtEpochMs")
        }
      }

      public var emailAddress: String {
        get {
          return snapshot["emailAddress"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "emailAddress")
        }
      }

      public var size: Double {
        get {
          return snapshot["size"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "size")
        }
      }

      public var folders: [Folder] {
        get {
          return (snapshot["folders"] as! [Snapshot]).map { Folder(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "folders")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }

      public struct Folder: GraphQLSelectionSet {
        public static let possibleTypes = ["EmailFolder"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("emailAddressId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("folderName", type: .nonNull(.scalar(String.self))),
          GraphQLField("size", type: .nonNull(.scalar(Double.self))),
          GraphQLField("unseenCount", type: .nonNull(.scalar(Double.self))),
          GraphQLField("ttl", type: .scalar(Double.self)),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, emailAddressId: GraphQLID, folderName: String, size: Double, unseenCount: Double, ttl: Double? = nil, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double) {
          self.init(snapshot: ["__typename": "EmailFolder", "id": id, "owner": owner, "emailAddressId": emailAddressId, "folderName": folderName, "size": size, "unseenCount": unseenCount, "ttl": ttl, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var emailAddressId: GraphQLID {
          get {
            return snapshot["emailAddressId"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "emailAddressId")
          }
        }

        public var folderName: String {
          get {
            return snapshot["folderName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "folderName")
          }
        }

        public var size: Double {
          get {
            return snapshot["size"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "size")
          }
        }

        public var unseenCount: Double {
          get {
            return snapshot["unseenCount"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "unseenCount")
          }
        }

        public var ttl: Double? {
          get {
            return snapshot["ttl"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "ttl")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }
      }
    }
  }
}

public final class GetEntitlementsSetQuery: GraphQLQuery {
  public static let operationString =
    "query GetEntitlementsSet($input: GetEntitlementsSetInput!) {\n  getEntitlementsSet(input: $input) {\n    __typename\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    name\n    description\n    entitlements {\n      __typename\n      name\n      description\n      value\n    }\n  }\n}"

  public var input: GetEntitlementsSetInput

  public init(input: GetEntitlementsSetInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEntitlementsSet", arguments: ["input": GraphQLVariable("input")], type: .object(GetEntitlementsSet.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEntitlementsSet: GetEntitlementsSet? = nil) {
      self.init(snapshot: ["__typename": "Query", "getEntitlementsSet": getEntitlementsSet.flatMap { $0.snapshot }])
    }

    public var getEntitlementsSet: GetEntitlementsSet? {
      get {
        return (snapshot["getEntitlementsSet"] as? Snapshot).flatMap { GetEntitlementsSet(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getEntitlementsSet")
      }
    }

    public struct GetEntitlementsSet: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSet"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("entitlements", type: .nonNull(.list(.nonNull(.object(Entitlement.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, name: String, description: String? = nil, entitlements: [Entitlement]) {
        self.init(snapshot: ["__typename": "EntitlementsSet", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "name": name, "description": description, "entitlements": entitlements.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var entitlements: [Entitlement] {
        get {
          return (snapshot["entitlements"] as! [Snapshot]).map { Entitlement(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "entitlements")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["Entitlement"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, value: Int) {
          self.init(snapshot: ["__typename": "Entitlement", "name": name, "description": description, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class ListEntitlementsSetsQuery: GraphQLQuery {
  public static let operationString =
    "query ListEntitlementsSets($nextToken: String) {\n  listEntitlementsSets(nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      createdAtEpochMs\n      updatedAtEpochMs\n      version\n      name\n      description\n    }\n    nextToken\n  }\n}"

  public var nextToken: String?

  public init(nextToken: String? = nil) {
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEntitlementsSets", arguments: ["nextToken": GraphQLVariable("nextToken")], type: .nonNull(.object(ListEntitlementsSet.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEntitlementsSets: ListEntitlementsSet) {
      self.init(snapshot: ["__typename": "Query", "listEntitlementsSets": listEntitlementsSets.snapshot])
    }

    public var listEntitlementsSets: ListEntitlementsSet {
      get {
        return ListEntitlementsSet(snapshot: snapshot["listEntitlementsSets"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listEntitlementsSets")
      }
    }

    public struct ListEntitlementsSet: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSetsConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "EntitlementsSetsConnection", "items": items.map { $0.snapshot }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (snapshot["items"] as! [Snapshot]).map { Item(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementsSet"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, name: String, description: String? = nil) {
          self.init(snapshot: ["__typename": "EntitlementsSet", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "name": name, "description": description])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }
      }
    }
  }
}

public final class GetEntitlementsSequenceQuery: GraphQLQuery {
  public static let operationString =
    "query GetEntitlementsSequence($input: GetEntitlementsSequenceInput!) {\n  getEntitlementsSequence(input: $input) {\n    __typename\n    name\n    description\n    createdAtEpochMs\n    updatedAtEpochMs\n    version\n    transitions {\n      __typename\n      entitlementsSetName\n      duration\n    }\n  }\n}"

  public var input: GetEntitlementsSequenceInput

  public init(input: GetEntitlementsSequenceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEntitlementsSequence", arguments: ["input": GraphQLVariable("input")], type: .object(GetEntitlementsSequence.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEntitlementsSequence: GetEntitlementsSequence? = nil) {
      self.init(snapshot: ["__typename": "Query", "getEntitlementsSequence": getEntitlementsSequence.flatMap { $0.snapshot }])
    }

    public var getEntitlementsSequence: GetEntitlementsSequence? {
      get {
        return (snapshot["getEntitlementsSequence"] as? Snapshot).flatMap { GetEntitlementsSequence(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getEntitlementsSequence")
      }
    }

    public struct GetEntitlementsSequence: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSequence"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("transitions", type: .nonNull(.list(.nonNull(.object(Transition.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(name: String, description: String? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int, transitions: [Transition]) {
        self.init(snapshot: ["__typename": "EntitlementsSequence", "name": name, "description": description, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "transitions": transitions.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var transitions: [Transition] {
        get {
          return (snapshot["transitions"] as! [Snapshot]).map { Transition(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "transitions")
        }
      }

      public struct Transition: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementsSequenceTransition"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("entitlementsSetName", type: .nonNull(.scalar(String.self))),
          GraphQLField("duration", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(entitlementsSetName: String, duration: String? = nil) {
          self.init(snapshot: ["__typename": "EntitlementsSequenceTransition", "entitlementsSetName": entitlementsSetName, "duration": duration])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var entitlementsSetName: String {
          get {
            return snapshot["entitlementsSetName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var duration: String? {
          get {
            return snapshot["duration"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "duration")
          }
        }
      }
    }
  }
}

public final class ListEntitlementsSequencesQuery: GraphQLQuery {
  public static let operationString =
    "query ListEntitlementsSequences($nextToken: String) {\n  listEntitlementsSequences(nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      name\n      description\n      createdAtEpochMs\n      updatedAtEpochMs\n      version\n    }\n    nextToken\n  }\n}"

  public var nextToken: String?

  public init(nextToken: String? = nil) {
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEntitlementsSequences", arguments: ["nextToken": GraphQLVariable("nextToken")], type: .nonNull(.object(ListEntitlementsSequence.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEntitlementsSequences: ListEntitlementsSequence) {
      self.init(snapshot: ["__typename": "Query", "listEntitlementsSequences": listEntitlementsSequences.snapshot])
    }

    public var listEntitlementsSequences: ListEntitlementsSequence {
      get {
        return ListEntitlementsSequence(snapshot: snapshot["listEntitlementsSequences"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listEntitlementsSequences")
      }
    }

    public struct ListEntitlementsSequence: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementsSequencesConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "EntitlementsSequencesConnection", "items": items.map { $0.snapshot }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (snapshot["items"] as! [Snapshot]).map { Item(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementsSequence"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Int) {
          self.init(snapshot: ["__typename": "EntitlementsSequence", "name": name, "description": description, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }
      }
    }
  }
}

public final class GetEntitlementsForUserQuery: GraphQLQuery {
  public static let operationString =
    "query GetEntitlementsForUser($input: GetEntitlementsForUserInput!) {\n  getEntitlementsForUser(input: $input) {\n    __typename\n    entitlements {\n      __typename\n      createdAtEpochMs\n      updatedAtEpochMs\n      version\n      externalId\n      owner\n      accountState\n      entitlementsSetName\n      entitlementsSequenceName\n      transitionsRelativeToEpochMs\n    }\n    consumption {\n      __typename\n      name\n      value\n      consumed\n      available\n      firstConsumedAtEpochMs\n      lastConsumedAtEpochMs\n    }\n  }\n}"

  public var input: GetEntitlementsForUserInput

  public init(input: GetEntitlementsForUserInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEntitlementsForUser", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(GetEntitlementsForUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEntitlementsForUser: GetEntitlementsForUser) {
      self.init(snapshot: ["__typename": "Query", "getEntitlementsForUser": getEntitlementsForUser.snapshot])
    }

    public var getEntitlementsForUser: GetEntitlementsForUser {
      get {
        return GetEntitlementsForUser(snapshot: snapshot["getEntitlementsForUser"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "getEntitlementsForUser")
      }
    }

    public struct GetEntitlementsForUser: GraphQLSelectionSet {
      public static let possibleTypes = ["ExternalEntitlementsConsumption"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("entitlements", type: .nonNull(.object(Entitlement.selections))),
        GraphQLField("consumption", type: .nonNull(.list(.nonNull(.object(Consumption.selections))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(entitlements: Entitlement, consumption: [Consumption]) {
        self.init(snapshot: ["__typename": "ExternalEntitlementsConsumption", "entitlements": entitlements.snapshot, "consumption": consumption.map { $0.snapshot }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var entitlements: Entitlement {
        get {
          return Entitlement(snapshot: snapshot["entitlements"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "entitlements")
        }
      }

      public var consumption: [Consumption] {
        get {
          return (snapshot["consumption"] as! [Snapshot]).map { Consumption(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "consumption")
        }
      }

      public struct Entitlement: GraphQLSelectionSet {
        public static let possibleTypes = ["ExternalUserEntitlements"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("version", type: .nonNull(.scalar(Double.self))),
          GraphQLField("externalId", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .scalar(String.self)),
          GraphQLField("accountState", type: .scalar(AccountStates.self)),
          GraphQLField("entitlementsSetName", type: .scalar(String.self)),
          GraphQLField("entitlementsSequenceName", type: .scalar(String.self)),
          GraphQLField("transitionsRelativeToEpochMs", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(createdAtEpochMs: Double, updatedAtEpochMs: Double, version: Double, externalId: String, owner: String? = nil, accountState: AccountStates? = nil, entitlementsSetName: String? = nil, entitlementsSequenceName: String? = nil, transitionsRelativeToEpochMs: Double? = nil) {
          self.init(snapshot: ["__typename": "ExternalUserEntitlements", "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "version": version, "externalId": externalId, "owner": owner, "accountState": accountState, "entitlementsSetName": entitlementsSetName, "entitlementsSequenceName": entitlementsSequenceName, "transitionsRelativeToEpochMs": transitionsRelativeToEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var version: Double {
          get {
            return snapshot["version"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var externalId: String {
          get {
            return snapshot["externalId"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "externalId")
          }
        }

        public var owner: String? {
          get {
            return snapshot["owner"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var accountState: AccountStates? {
          get {
            return snapshot["accountState"] as? AccountStates
          }
          set {
            snapshot.updateValue(newValue, forKey: "accountState")
          }
        }

        public var entitlementsSetName: String? {
          get {
            return snapshot["entitlementsSetName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSetName")
          }
        }

        public var entitlementsSequenceName: String? {
          get {
            return snapshot["entitlementsSequenceName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "entitlementsSequenceName")
          }
        }

        public var transitionsRelativeToEpochMs: Double? {
          get {
            return snapshot["transitionsRelativeToEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "transitionsRelativeToEpochMs")
          }
        }
      }

      public struct Consumption: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementConsumption"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("value", type: .nonNull(.scalar(Int.self))),
          GraphQLField("consumed", type: .nonNull(.scalar(Int.self))),
          GraphQLField("available", type: .nonNull(.scalar(Int.self))),
          GraphQLField("firstConsumedAtEpochMs", type: .scalar(Double.self)),
          GraphQLField("lastConsumedAtEpochMs", type: .scalar(Double.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, value: Int, consumed: Int, available: Int, firstConsumedAtEpochMs: Double? = nil, lastConsumedAtEpochMs: Double? = nil) {
          self.init(snapshot: ["__typename": "EntitlementConsumption", "name": name, "value": value, "consumed": consumed, "available": available, "firstConsumedAtEpochMs": firstConsumedAtEpochMs, "lastConsumedAtEpochMs": lastConsumedAtEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var value: Int {
          get {
            return snapshot["value"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }

        public var consumed: Int {
          get {
            return snapshot["consumed"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "consumed")
          }
        }

        public var available: Int {
          get {
            return snapshot["available"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "available")
          }
        }

        public var firstConsumedAtEpochMs: Double? {
          get {
            return snapshot["firstConsumedAtEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "firstConsumedAtEpochMs")
          }
        }

        public var lastConsumedAtEpochMs: Double? {
          get {
            return snapshot["lastConsumedAtEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastConsumedAtEpochMs")
          }
        }
      }
    }
  }
}

public final class GetEntitlementDefinitionQuery: GraphQLQuery {
  public static let operationString =
    "query GetEntitlementDefinition($input: GetEntitlementDefinitionInput!) {\n  getEntitlementDefinition(input: $input) {\n    __typename\n    name\n    description\n    type\n    expendable\n  }\n}"

  public var input: GetEntitlementDefinitionInput

  public init(input: GetEntitlementDefinitionInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getEntitlementDefinition", arguments: ["input": GraphQLVariable("input")], type: .object(GetEntitlementDefinition.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getEntitlementDefinition: GetEntitlementDefinition? = nil) {
      self.init(snapshot: ["__typename": "Query", "getEntitlementDefinition": getEntitlementDefinition.flatMap { $0.snapshot }])
    }

    public var getEntitlementDefinition: GetEntitlementDefinition? {
      get {
        return (snapshot["getEntitlementDefinition"] as? Snapshot).flatMap { GetEntitlementDefinition(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "getEntitlementDefinition")
      }
    }

    public struct GetEntitlementDefinition: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementDefinition"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("description", type: .scalar(String.self)),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("expendable", type: .nonNull(.scalar(Bool.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(name: String, description: String? = nil, type: String, expendable: Bool) {
        self.init(snapshot: ["__typename": "EntitlementDefinition", "name": name, "description": description, "type": type, "expendable": expendable])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var description: String? {
        get {
          return snapshot["description"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var type: String {
        get {
          return snapshot["type"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var expendable: Bool {
        get {
          return snapshot["expendable"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "expendable")
        }
      }
    }
  }
}

public final class ListEntitlementDefinitionsQuery: GraphQLQuery {
  public static let operationString =
    "query ListEntitlementDefinitions($limit: Int, $nextToken: String) {\n  listEntitlementDefinitions(limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      name\n      description\n      type\n      expendable\n    }\n    nextToken\n  }\n}"

  public var limit: Int?
  public var nextToken: String?

  public init(limit: Int? = nil, nextToken: String? = nil) {
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEntitlementDefinitions", arguments: ["limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .nonNull(.object(ListEntitlementDefinition.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEntitlementDefinitions: ListEntitlementDefinition) {
      self.init(snapshot: ["__typename": "Query", "listEntitlementDefinitions": listEntitlementDefinitions.snapshot])
    }

    public var listEntitlementDefinitions: ListEntitlementDefinition {
      get {
        return ListEntitlementDefinition(snapshot: snapshot["listEntitlementDefinitions"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listEntitlementDefinitions")
      }
    }

    public struct ListEntitlementDefinition: GraphQLSelectionSet {
      public static let possibleTypes = ["EntitlementDefinitionConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "EntitlementDefinitionConnection", "items": items.map { $0.snapshot }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (snapshot["items"] as! [Snapshot]).map { Item(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["EntitlementDefinition"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("type", type: .nonNull(.scalar(String.self))),
          GraphQLField("expendable", type: .nonNull(.scalar(Bool.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, description: String? = nil, type: String, expendable: Bool) {
          self.init(snapshot: ["__typename": "EntitlementDefinition", "name": name, "description": description, "type": type, "expendable": expendable])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var description: String? {
          get {
            return snapshot["description"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "description")
          }
        }

        public var type: String {
          get {
            return snapshot["type"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "type")
          }
        }

        public var expendable: Bool {
          get {
            return snapshot["expendable"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "expendable")
          }
        }
      }
    }
  }
}

public final class GetConfigurationForEncryptedShareServiceQuery: GraphQLQuery {
  public static let operationString =
    "query GetConfigurationForEncryptedShareService {\n  getConfigurationForEncryptedShareService {\n    __typename\n    maxExpiryInMins\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getConfigurationForEncryptedShareService", type: .nonNull(.object(GetConfigurationForEncryptedShareService.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getConfigurationForEncryptedShareService: GetConfigurationForEncryptedShareService) {
      self.init(snapshot: ["__typename": "Query", "getConfigurationForEncryptedShareService": getConfigurationForEncryptedShareService.snapshot])
    }

    public var getConfigurationForEncryptedShareService: GetConfigurationForEncryptedShareService {
      get {
        return GetConfigurationForEncryptedShareService(snapshot: snapshot["getConfigurationForEncryptedShareService"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "getConfigurationForEncryptedShareService")
      }
    }

    public struct GetConfigurationForEncryptedShareService: GraphQLSelectionSet {
      public static let possibleTypes = ["EncryptedShareServiceConfiguration"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("maxExpiryInMins", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(maxExpiryInMins: Int) {
        self.init(snapshot: ["__typename": "EncryptedShareServiceConfiguration", "maxExpiryInMins": maxExpiryInMins])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var maxExpiryInMins: Int {
        get {
          return snapshot["maxExpiryInMins"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "maxExpiryInMins")
        }
      }
    }
  }
}

public final class ListEncryptedBlobMetadataBySubQuery: GraphQLQuery {
  public static let operationString =
    "query ListEncryptedBlobMetadataBySub($owner: ID!, $limit: Int, $nextToken: String) {\n  listEncryptedBlobMetadataBySub(\n    owner: $owner\n    limit: $limit\n    nextToken: $nextToken\n  ) {\n    __typename\n    items {\n      __typename\n      id\n      owner\n      version\n      accessesRemaining\n      createdAtEpochMs\n      updatedAtEpochMs\n      expiresAtEpochMs\n    }\n    nextToken\n  }\n}"

  public var owner: GraphQLID
  public var limit: Int?
  public var nextToken: String?

  public init(owner: GraphQLID, limit: Int? = nil, nextToken: String? = nil) {
    self.owner = owner
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["owner": owner, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listEncryptedBlobMetadataBySub", arguments: ["owner": GraphQLVariable("owner"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .nonNull(.object(ListEncryptedBlobMetadataBySub.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listEncryptedBlobMetadataBySub: ListEncryptedBlobMetadataBySub) {
      self.init(snapshot: ["__typename": "Query", "listEncryptedBlobMetadataBySub": listEncryptedBlobMetadataBySub.snapshot])
    }

    public var listEncryptedBlobMetadataBySub: ListEncryptedBlobMetadataBySub {
      get {
        return ListEncryptedBlobMetadataBySub(snapshot: snapshot["listEncryptedBlobMetadataBySub"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listEncryptedBlobMetadataBySub")
      }
    }

    public struct ListEncryptedBlobMetadataBySub: GraphQLSelectionSet {
      public static let possibleTypes = ["ListEncryptedBlobMetadataConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ListEncryptedBlobMetadataConnection", "items": items.map { $0.snapshot }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (snapshot["items"] as! [Snapshot]).map { Item(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["EncryptedBlobMetadata"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("accessesRemaining", type: .scalar(Int.self)),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("expiresAtEpochMs", type: .nonNull(.scalar(Double.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, version: Int, accessesRemaining: Int? = nil, createdAtEpochMs: Double, updatedAtEpochMs: Double, expiresAtEpochMs: Double) {
          self.init(snapshot: ["__typename": "EncryptedBlobMetadata", "id": id, "owner": owner, "version": version, "accessesRemaining": accessesRemaining, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "expiresAtEpochMs": expiresAtEpochMs])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var accessesRemaining: Int? {
          get {
            return snapshot["accessesRemaining"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "accessesRemaining")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var expiresAtEpochMs: Double {
          get {
            return snapshot["expiresAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "expiresAtEpochMs")
          }
        }
      }
    }
  }
}

public final class ListUsersQuery: GraphQLQuery {
  public static let operationString =
    "query ListUsers($input: PagingInput) {\n  listUsers(input: $input) {\n    __typename\n    items {\n      __typename\n      username\n      sub\n      registeredDate\n      lastModifiedDate\n      lastAuthDate\n      resetVersion\n      lastResetDate\n      enabled\n      state\n      stateReason\n    }\n    nextToken\n  }\n}"

  public var input: PagingInput?

  public init(input: PagingInput? = nil) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listUsers", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ListUser.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listUsers: ListUser) {
      self.init(snapshot: ["__typename": "Query", "listUsers": listUsers.snapshot])
    }

    public var listUsers: ListUser {
      get {
        return ListUser(snapshot: snapshot["listUsers"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listUsers")
      }
    }

    public struct ListUser: GraphQLSelectionSet {
      public static let possibleTypes = ["Users"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "Users", "items": items.map { $0.flatMap { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["User"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("username", type: .nonNull(.scalar(String.self))),
          GraphQLField("sub", type: .nonNull(.scalar(String.self))),
          GraphQLField("registeredDate", type: .nonNull(.scalar(String.self))),
          GraphQLField("lastModifiedDate", type: .scalar(String.self)),
          GraphQLField("lastAuthDate", type: .scalar(String.self)),
          GraphQLField("resetVersion", type: .scalar(Int.self)),
          GraphQLField("lastResetDate", type: .scalar(String.self)),
          GraphQLField("enabled", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("state", type: .scalar(String.self)),
          GraphQLField("stateReason", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(username: String, sub: String, registeredDate: String, lastModifiedDate: String? = nil, lastAuthDate: String? = nil, resetVersion: Int? = nil, lastResetDate: String? = nil, enabled: Bool, state: String? = nil, stateReason: String? = nil) {
          self.init(snapshot: ["__typename": "User", "username": username, "sub": sub, "registeredDate": registeredDate, "lastModifiedDate": lastModifiedDate, "lastAuthDate": lastAuthDate, "resetVersion": resetVersion, "lastResetDate": lastResetDate, "enabled": enabled, "state": state, "stateReason": stateReason])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var username: String {
          get {
            return snapshot["username"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "username")
          }
        }

        public var sub: String {
          get {
            return snapshot["sub"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "sub")
          }
        }

        public var registeredDate: String {
          get {
            return snapshot["registeredDate"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "registeredDate")
          }
        }

        public var lastModifiedDate: String? {
          get {
            return snapshot["lastModifiedDate"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastModifiedDate")
          }
        }

        public var lastAuthDate: String? {
          get {
            return snapshot["lastAuthDate"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastAuthDate")
          }
        }

        public var resetVersion: Int? {
          get {
            return snapshot["resetVersion"] as? Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "resetVersion")
          }
        }

        public var lastResetDate: String? {
          get {
            return snapshot["lastResetDate"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastResetDate")
          }
        }

        public var enabled: Bool {
          get {
            return snapshot["enabled"]! as! Bool
          }
          set {
            snapshot.updateValue(newValue, forKey: "enabled")
          }
        }

        public var state: String? {
          get {
            return snapshot["state"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var stateReason: String? {
          get {
            return snapshot["stateReason"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "stateReason")
          }
        }
      }
    }
  }
}

public final class RetrieveUserBySubQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveUserBySub($input: RetrieveUserBySubInput!) {\n  retrieveUserBySub(input: $input) {\n    __typename\n    username\n    sub\n    registeredDate\n    lastModifiedDate\n    lastAuthDate\n    resetVersion\n    lastResetDate\n    enabled\n    state\n    stateReason\n    attributes {\n      __typename\n      name\n      value\n    }\n  }\n}"

  public var input: RetrieveUserBySubInput

  public init(input: RetrieveUserBySubInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveUserBySub", arguments: ["input": GraphQLVariable("input")], type: .object(RetrieveUserBySub.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveUserBySub: RetrieveUserBySub? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveUserBySub": retrieveUserBySub.flatMap { $0.snapshot }])
    }

    public var retrieveUserBySub: RetrieveUserBySub? {
      get {
        return (snapshot["retrieveUserBySub"] as? Snapshot).flatMap { RetrieveUserBySub(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveUserBySub")
      }
    }

    public struct RetrieveUserBySub: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("sub", type: .nonNull(.scalar(String.self))),
        GraphQLField("registeredDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("lastModifiedDate", type: .scalar(String.self)),
        GraphQLField("lastAuthDate", type: .scalar(String.self)),
        GraphQLField("resetVersion", type: .scalar(Int.self)),
        GraphQLField("lastResetDate", type: .scalar(String.self)),
        GraphQLField("enabled", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("state", type: .scalar(String.self)),
        GraphQLField("stateReason", type: .scalar(String.self)),
        GraphQLField("attributes", type: .list(.object(Attribute.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(username: String, sub: String, registeredDate: String, lastModifiedDate: String? = nil, lastAuthDate: String? = nil, resetVersion: Int? = nil, lastResetDate: String? = nil, enabled: Bool, state: String? = nil, stateReason: String? = nil, attributes: [Attribute?]? = nil) {
        self.init(snapshot: ["__typename": "User", "username": username, "sub": sub, "registeredDate": registeredDate, "lastModifiedDate": lastModifiedDate, "lastAuthDate": lastAuthDate, "resetVersion": resetVersion, "lastResetDate": lastResetDate, "enabled": enabled, "state": state, "stateReason": stateReason, "attributes": attributes.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var sub: String {
        get {
          return snapshot["sub"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "sub")
        }
      }

      public var registeredDate: String {
        get {
          return snapshot["registeredDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "registeredDate")
        }
      }

      public var lastModifiedDate: String? {
        get {
          return snapshot["lastModifiedDate"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastModifiedDate")
        }
      }

      public var lastAuthDate: String? {
        get {
          return snapshot["lastAuthDate"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastAuthDate")
        }
      }

      public var resetVersion: Int? {
        get {
          return snapshot["resetVersion"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "resetVersion")
        }
      }

      public var lastResetDate: String? {
        get {
          return snapshot["lastResetDate"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastResetDate")
        }
      }

      public var enabled: Bool {
        get {
          return snapshot["enabled"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "enabled")
        }
      }

      public var state: String? {
        get {
          return snapshot["state"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "state")
        }
      }

      public var stateReason: String? {
        get {
          return snapshot["stateReason"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "stateReason")
        }
      }

      public var attributes: [Attribute?]? {
        get {
          return (snapshot["attributes"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Attribute(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "attributes")
        }
      }

      public struct Attribute: GraphQLSelectionSet {
        public static let possibleTypes = ["Attribute"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, value: String) {
          self.init(snapshot: ["__typename": "Attribute", "name": name, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var value: String {
          get {
            return snapshot["value"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class RetrieveUserByUsernameQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveUserByUsername($input: RetrieveUserByUsernameInput!) {\n  retrieveUserByUsername(input: $input) {\n    __typename\n    username\n    sub\n    registeredDate\n    lastModifiedDate\n    lastAuthDate\n    resetVersion\n    lastResetDate\n    enabled\n    state\n    stateReason\n    attributes {\n      __typename\n      name\n      value\n    }\n  }\n}"

  public var input: RetrieveUserByUsernameInput

  public init(input: RetrieveUserByUsernameInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveUserByUsername", arguments: ["input": GraphQLVariable("input")], type: .object(RetrieveUserByUsername.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveUserByUsername: RetrieveUserByUsername? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveUserByUsername": retrieveUserByUsername.flatMap { $0.snapshot }])
    }

    public var retrieveUserByUsername: RetrieveUserByUsername? {
      get {
        return (snapshot["retrieveUserByUsername"] as? Snapshot).flatMap { RetrieveUserByUsername(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveUserByUsername")
      }
    }

    public struct RetrieveUserByUsername: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("username", type: .nonNull(.scalar(String.self))),
        GraphQLField("sub", type: .nonNull(.scalar(String.self))),
        GraphQLField("registeredDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("lastModifiedDate", type: .scalar(String.self)),
        GraphQLField("lastAuthDate", type: .scalar(String.self)),
        GraphQLField("resetVersion", type: .scalar(Int.self)),
        GraphQLField("lastResetDate", type: .scalar(String.self)),
        GraphQLField("enabled", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("state", type: .scalar(String.self)),
        GraphQLField("stateReason", type: .scalar(String.self)),
        GraphQLField("attributes", type: .list(.object(Attribute.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(username: String, sub: String, registeredDate: String, lastModifiedDate: String? = nil, lastAuthDate: String? = nil, resetVersion: Int? = nil, lastResetDate: String? = nil, enabled: Bool, state: String? = nil, stateReason: String? = nil, attributes: [Attribute?]? = nil) {
        self.init(snapshot: ["__typename": "User", "username": username, "sub": sub, "registeredDate": registeredDate, "lastModifiedDate": lastModifiedDate, "lastAuthDate": lastAuthDate, "resetVersion": resetVersion, "lastResetDate": lastResetDate, "enabled": enabled, "state": state, "stateReason": stateReason, "attributes": attributes.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var username: String {
        get {
          return snapshot["username"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "username")
        }
      }

      public var sub: String {
        get {
          return snapshot["sub"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "sub")
        }
      }

      public var registeredDate: String {
        get {
          return snapshot["registeredDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "registeredDate")
        }
      }

      public var lastModifiedDate: String? {
        get {
          return snapshot["lastModifiedDate"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastModifiedDate")
        }
      }

      public var lastAuthDate: String? {
        get {
          return snapshot["lastAuthDate"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastAuthDate")
        }
      }

      public var resetVersion: Int? {
        get {
          return snapshot["resetVersion"] as? Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "resetVersion")
        }
      }

      public var lastResetDate: String? {
        get {
          return snapshot["lastResetDate"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastResetDate")
        }
      }

      public var enabled: Bool {
        get {
          return snapshot["enabled"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "enabled")
        }
      }

      public var state: String? {
        get {
          return snapshot["state"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "state")
        }
      }

      public var stateReason: String? {
        get {
          return snapshot["stateReason"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "stateReason")
        }
      }

      public var attributes: [Attribute?]? {
        get {
          return (snapshot["attributes"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Attribute(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "attributes")
        }
      }

      public struct Attribute: GraphQLSelectionSet {
        public static let possibleTypes = ["Attribute"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("value", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(name: String, value: String) {
          self.init(snapshot: ["__typename": "Attribute", "name": name, "value": value])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return snapshot["name"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "name")
          }
        }

        public var value: String {
          get {
            return snapshot["value"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "value")
          }
        }
      }
    }
  }
}

public final class QueryDeviceCheckStatusQuery: GraphQLQuery {
  public static let operationString =
    "query QueryDeviceCheckStatus($input: DeviceCheckInput!) {\n  queryDeviceCheckStatus(input: $input) {\n    __typename\n    bit0\n    bit1\n    lastUpdatedTime\n  }\n}"

  public var input: DeviceCheckInput

  public init(input: DeviceCheckInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("queryDeviceCheckStatus", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(QueryDeviceCheckStatus.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(queryDeviceCheckStatus: QueryDeviceCheckStatus) {
      self.init(snapshot: ["__typename": "Query", "queryDeviceCheckStatus": queryDeviceCheckStatus.snapshot])
    }

    public var queryDeviceCheckStatus: QueryDeviceCheckStatus {
      get {
        return QueryDeviceCheckStatus(snapshot: snapshot["queryDeviceCheckStatus"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "queryDeviceCheckStatus")
      }
    }

    public struct QueryDeviceCheckStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["DeviceCheckStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bit0", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("bit1", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("lastUpdatedTime", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(bit0: Bool, bit1: Bool, lastUpdatedTime: String) {
        self.init(snapshot: ["__typename": "DeviceCheckStatus", "bit0": bit0, "bit1": bit1, "lastUpdatedTime": lastUpdatedTime])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bit0: Bool {
        get {
          return snapshot["bit0"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "bit0")
        }
      }

      public var bit1: Bool {
        get {
          return snapshot["bit1"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "bit1")
        }
      }

      public var lastUpdatedTime: String {
        get {
          return snapshot["lastUpdatedTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastUpdatedTime")
        }
      }
    }
  }
}

public final class RetrieveDeviceCheckStatusQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveDeviceCheckStatus($input: RetrieveDeviceCheckInput!) {\n  retrieveDeviceCheckStatus(input: $input) {\n    __typename\n    bit0\n    bit1\n    lastUpdatedTime\n  }\n}"

  public var input: RetrieveDeviceCheckInput

  public init(input: RetrieveDeviceCheckInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveDeviceCheckStatus", arguments: ["input": GraphQLVariable("input")], type: .object(RetrieveDeviceCheckStatus.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveDeviceCheckStatus: RetrieveDeviceCheckStatus? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveDeviceCheckStatus": retrieveDeviceCheckStatus.flatMap { $0.snapshot }])
    }

    public var retrieveDeviceCheckStatus: RetrieveDeviceCheckStatus? {
      get {
        return (snapshot["retrieveDeviceCheckStatus"] as? Snapshot).flatMap { RetrieveDeviceCheckStatus(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveDeviceCheckStatus")
      }
    }

    public struct RetrieveDeviceCheckStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["DeviceCheckStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("bit0", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("bit1", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("lastUpdatedTime", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(bit0: Bool, bit1: Bool, lastUpdatedTime: String) {
        self.init(snapshot: ["__typename": "DeviceCheckStatus", "bit0": bit0, "bit1": bit1, "lastUpdatedTime": lastUpdatedTime])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var bit0: Bool {
        get {
          return snapshot["bit0"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "bit0")
        }
      }

      public var bit1: Bool {
        get {
          return snapshot["bit1"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "bit1")
        }
      }

      public var lastUpdatedTime: String {
        get {
          return snapshot["lastUpdatedTime"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastUpdatedTime")
        }
      }
    }
  }
}

public final class RetrieveDeviceCheckKeyMetaDataQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveDeviceCheckKeyMetaData($input: RetrieveDeviceCheckKeyMetaDataInput!) {\n  retrieveDeviceCheckKeyMetaData(input: $input) {\n    __typename\n    issuer\n    keyId\n  }\n}"

  public var input: RetrieveDeviceCheckKeyMetaDataInput

  public init(input: RetrieveDeviceCheckKeyMetaDataInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveDeviceCheckKeyMetaData", arguments: ["input": GraphQLVariable("input")], type: .object(RetrieveDeviceCheckKeyMetaDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveDeviceCheckKeyMetaData: RetrieveDeviceCheckKeyMetaDatum? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveDeviceCheckKeyMetaData": retrieveDeviceCheckKeyMetaData.flatMap { $0.snapshot }])
    }

    public var retrieveDeviceCheckKeyMetaData: RetrieveDeviceCheckKeyMetaDatum? {
      get {
        return (snapshot["retrieveDeviceCheckKeyMetaData"] as? Snapshot).flatMap { RetrieveDeviceCheckKeyMetaDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveDeviceCheckKeyMetaData")
      }
    }

    public struct RetrieveDeviceCheckKeyMetaDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["DeviceCheckKeyMetaData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        GraphQLField("keyId", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(issuer: String, keyId: String) {
        self.init(snapshot: ["__typename": "DeviceCheckKeyMetaData", "issuer": issuer, "keyId": keyId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var issuer: String {
        get {
          return snapshot["issuer"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "issuer")
        }
      }

      public var keyId: String {
        get {
          return snapshot["keyId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyId")
        }
      }
    }
  }
}

public final class RetrievePlayIntegrityKeyMetaDataQuery: GraphQLQuery {
  public static let operationString =
    "query RetrievePlayIntegrityKeyMetaData {\n  retrievePlayIntegrityKeyMetaData {\n    __typename\n    type\n    project_id\n    private_key_id\n    client_id\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrievePlayIntegrityKeyMetaData", type: .object(RetrievePlayIntegrityKeyMetaDatum.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrievePlayIntegrityKeyMetaData: RetrievePlayIntegrityKeyMetaDatum? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrievePlayIntegrityKeyMetaData": retrievePlayIntegrityKeyMetaData.flatMap { $0.snapshot }])
    }

    public var retrievePlayIntegrityKeyMetaData: RetrievePlayIntegrityKeyMetaDatum? {
      get {
        return (snapshot["retrievePlayIntegrityKeyMetaData"] as? Snapshot).flatMap { RetrievePlayIntegrityKeyMetaDatum(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrievePlayIntegrityKeyMetaData")
      }
    }

    public struct RetrievePlayIntegrityKeyMetaDatum: GraphQLSelectionSet {
      public static let possibleTypes = ["PlayIntegrityKeyMetaData"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("project_id", type: .nonNull(.scalar(String.self))),
        GraphQLField("private_key_id", type: .nonNull(.scalar(String.self))),
        GraphQLField("client_id", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(type: String, projectId: String, privateKeyId: String, clientId: String) {
        self.init(snapshot: ["__typename": "PlayIntegrityKeyMetaData", "type": type, "project_id": projectId, "private_key_id": privateKeyId, "client_id": clientId])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var type: String {
        get {
          return snapshot["type"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var projectId: String {
        get {
          return snapshot["project_id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "project_id")
        }
      }

      public var privateKeyId: String {
        get {
          return snapshot["private_key_id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "private_key_id")
        }
      }

      public var clientId: String {
        get {
          return snapshot["client_id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "client_id")
        }
      }
    }
  }
}

public final class RetrieveSigningCertificateFingerprintsQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveSigningCertificateFingerprints {\n  retrieveSigningCertificateFingerprints {\n    __typename\n    items {\n      __typename\n      createdAt\n      fingerprint\n      friendlyName\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveSigningCertificateFingerprints", type: .object(RetrieveSigningCertificateFingerprint.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveSigningCertificateFingerprints: RetrieveSigningCertificateFingerprint? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveSigningCertificateFingerprints": retrieveSigningCertificateFingerprints.flatMap { $0.snapshot }])
    }

    public var retrieveSigningCertificateFingerprints: RetrieveSigningCertificateFingerprint? {
      get {
        return (snapshot["retrieveSigningCertificateFingerprints"] as? Snapshot).flatMap { RetrieveSigningCertificateFingerprint(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveSigningCertificateFingerprints")
      }
    }

    public struct RetrieveSigningCertificateFingerprint: GraphQLSelectionSet {
      public static let possibleTypes = ["SigningCertificateFingerprints"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.object(Item.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]? = nil) {
        self.init(snapshot: ["__typename": "SigningCertificateFingerprints", "items": items.flatMap { $0.map { $0.flatMap { $0.snapshot } } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?]? {
        get {
          return (snapshot["items"] as? [Snapshot?]).flatMap { $0.map { $0.flatMap { Item(snapshot: $0) } } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.flatMap { $0.snapshot } } }, forKey: "items")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["SigningCertificateFingerprint"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("fingerprint", type: .nonNull(.scalar(String.self))),
          GraphQLField("friendlyName", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(createdAt: String, fingerprint: String, friendlyName: String) {
          self.init(snapshot: ["__typename": "SigningCertificateFingerprint", "createdAt": createdAt, "fingerprint": fingerprint, "friendlyName": friendlyName])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var fingerprint: String {
          get {
            return snapshot["fingerprint"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "fingerprint")
          }
        }

        public var friendlyName: String {
          get {
            return snapshot["friendlyName"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "friendlyName")
          }
        }
      }
    }
  }
}

public final class RetrieveDeviceWhitelistStatusQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveDeviceWhitelistStatus($input: WhitelistDeviceInput!) {\n  retrieveDeviceWhitelistStatus(input: $input) {\n    __typename\n    deviceId\n    expiry\n  }\n}"

  public var input: WhitelistDeviceInput

  public init(input: WhitelistDeviceInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveDeviceWhitelistStatus", arguments: ["input": GraphQLVariable("input")], type: .object(RetrieveDeviceWhitelistStatus.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveDeviceWhitelistStatus: RetrieveDeviceWhitelistStatus? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveDeviceWhitelistStatus": retrieveDeviceWhitelistStatus.flatMap { $0.snapshot }])
    }

    public var retrieveDeviceWhitelistStatus: RetrieveDeviceWhitelistStatus? {
      get {
        return (snapshot["retrieveDeviceWhitelistStatus"] as? Snapshot).flatMap { RetrieveDeviceWhitelistStatus(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveDeviceWhitelistStatus")
      }
    }

    public struct RetrieveDeviceWhitelistStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["WhitelistDeviceStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("deviceId", type: .nonNull(.scalar(String.self))),
        GraphQLField("expiry", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(deviceId: String, expiry: String? = nil) {
        self.init(snapshot: ["__typename": "WhitelistDeviceStatus", "deviceId": deviceId, "expiry": expiry])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var deviceId: String {
        get {
          return snapshot["deviceId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "deviceId")
        }
      }

      public var expiry: String? {
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

public final class ListTestRegistrationKeysQuery: GraphQLQuery {
  public static let operationString =
    "query ListTestRegistrationKeys($limit: Int, $nextToken: String) {\n  listTestRegistrationKeys(limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      owner\n      publicKey\n      createdAtEpochMs\n      lastAccessedAtEpochMs\n      tag\n    }\n    nextToken\n  }\n}"

  public var limit: Int?
  public var nextToken: String?

  public init(limit: Int? = nil, nextToken: String? = nil) {
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTestRegistrationKeys", arguments: ["limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListTestRegistrationKey.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTestRegistrationKeys: ListTestRegistrationKey? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTestRegistrationKeys": listTestRegistrationKeys.flatMap { $0.snapshot }])
    }

    public var listTestRegistrationKeys: ListTestRegistrationKey? {
      get {
        return (snapshot["listTestRegistrationKeys"] as? Snapshot).flatMap { ListTestRegistrationKey(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listTestRegistrationKeys")
      }
    }

    public struct ListTestRegistrationKey: GraphQLSelectionSet {
      public static let possibleTypes = ["ListTestRegistrationKeysResult"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.nonNull(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ListTestRegistrationKeysResult", "items": items.flatMap { $0.map { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item]? {
        get {
          return (snapshot["items"] as? [Snapshot]).flatMap { $0.map { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["TestRegistrationKey"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .nonNull(.scalar(String.self))),
          GraphQLField("publicKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAtEpochMs", type: .scalar(Double.self)),
          GraphQLField("lastAccessedAtEpochMs", type: .scalar(Double.self)),
          GraphQLField("tag", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, owner: String, publicKey: String, createdAtEpochMs: Double? = nil, lastAccessedAtEpochMs: Double? = nil, tag: String? = nil) {
          self.init(snapshot: ["__typename": "TestRegistrationKey", "id": id, "owner": owner, "publicKey": publicKey, "createdAtEpochMs": createdAtEpochMs, "lastAccessedAtEpochMs": lastAccessedAtEpochMs, "tag": tag])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: String {
          get {
            return snapshot["owner"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var publicKey: String {
          get {
            return snapshot["publicKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "publicKey")
          }
        }

        public var createdAtEpochMs: Double? {
          get {
            return snapshot["createdAtEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var lastAccessedAtEpochMs: Double? {
          get {
            return snapshot["lastAccessedAtEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastAccessedAtEpochMs")
          }
        }

        public var tag: String? {
          get {
            return snapshot["tag"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "tag")
          }
        }
      }
    }
  }
}

public final class ListTestRegistrationKeysByTagQuery: GraphQLQuery {
  public static let operationString =
    "query ListTestRegistrationKeysByTag($tag: String!, $limit: Int, $nextToken: String) {\n  listTestRegistrationKeysByTag(tag: $tag, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      owner\n      publicKey\n      createdAtEpochMs\n      lastAccessedAtEpochMs\n      tag\n    }\n    nextToken\n  }\n}"

  public var tag: String
  public var limit: Int?
  public var nextToken: String?

  public init(tag: String, limit: Int? = nil, nextToken: String? = nil) {
    self.tag = tag
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["tag": tag, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listTestRegistrationKeysByTag", arguments: ["tag": GraphQLVariable("tag"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListTestRegistrationKeysByTag.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listTestRegistrationKeysByTag: ListTestRegistrationKeysByTag? = nil) {
      self.init(snapshot: ["__typename": "Query", "listTestRegistrationKeysByTag": listTestRegistrationKeysByTag.flatMap { $0.snapshot }])
    }

    public var listTestRegistrationKeysByTag: ListTestRegistrationKeysByTag? {
      get {
        return (snapshot["listTestRegistrationKeysByTag"] as? Snapshot).flatMap { ListTestRegistrationKeysByTag(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listTestRegistrationKeysByTag")
      }
    }

    public struct ListTestRegistrationKeysByTag: GraphQLSelectionSet {
      public static let possibleTypes = ["ListTestRegistrationKeysResult"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.nonNull(.object(Item.selections)))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item]? = nil, nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ListTestRegistrationKeysResult", "items": items.flatMap { $0.map { $0.snapshot } }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item]? {
        get {
          return (snapshot["items"] as? [Snapshot]).flatMap { $0.map { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.snapshot } }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["TestRegistrationKey"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .nonNull(.scalar(String.self))),
          GraphQLField("publicKey", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAtEpochMs", type: .scalar(Double.self)),
          GraphQLField("lastAccessedAtEpochMs", type: .scalar(Double.self)),
          GraphQLField("tag", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, owner: String, publicKey: String, createdAtEpochMs: Double? = nil, lastAccessedAtEpochMs: Double? = nil, tag: String? = nil) {
          self.init(snapshot: ["__typename": "TestRegistrationKey", "id": id, "owner": owner, "publicKey": publicKey, "createdAtEpochMs": createdAtEpochMs, "lastAccessedAtEpochMs": lastAccessedAtEpochMs, "tag": tag])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: String {
          get {
            return snapshot["owner"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var publicKey: String {
          get {
            return snapshot["publicKey"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "publicKey")
          }
        }

        public var createdAtEpochMs: Double? {
          get {
            return snapshot["createdAtEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var lastAccessedAtEpochMs: Double? {
          get {
            return snapshot["lastAccessedAtEpochMs"] as? Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "lastAccessedAtEpochMs")
          }
        }

        public var tag: String? {
          get {
            return snapshot["tag"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "tag")
          }
        }
      }
    }
  }
}

public final class RetrieveTestRegistrationKeyQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveTestRegistrationKey {\n  retrieveTestRegistrationKey {\n    __typename\n    id\n    owner\n    publicKey\n    createdAtEpochMs\n    lastAccessedAtEpochMs\n    tag\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveTestRegistrationKey", type: .object(RetrieveTestRegistrationKey.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveTestRegistrationKey: RetrieveTestRegistrationKey? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveTestRegistrationKey": retrieveTestRegistrationKey.flatMap { $0.snapshot }])
    }

    public var retrieveTestRegistrationKey: RetrieveTestRegistrationKey? {
      get {
        return (snapshot["retrieveTestRegistrationKey"] as? Snapshot).flatMap { RetrieveTestRegistrationKey(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveTestRegistrationKey")
      }
    }

    public struct RetrieveTestRegistrationKey: GraphQLSelectionSet {
      public static let possibleTypes = ["TestRegistrationKey"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .nonNull(.scalar(String.self))),
        GraphQLField("publicKey", type: .nonNull(.scalar(String.self))),
        GraphQLField("createdAtEpochMs", type: .scalar(Double.self)),
        GraphQLField("lastAccessedAtEpochMs", type: .scalar(Double.self)),
        GraphQLField("tag", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: String, owner: String, publicKey: String, createdAtEpochMs: Double? = nil, lastAccessedAtEpochMs: Double? = nil, tag: String? = nil) {
        self.init(snapshot: ["__typename": "TestRegistrationKey", "id": id, "owner": owner, "publicKey": publicKey, "createdAtEpochMs": createdAtEpochMs, "lastAccessedAtEpochMs": lastAccessedAtEpochMs, "tag": tag])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var owner: String {
        get {
          return snapshot["owner"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var publicKey: String {
        get {
          return snapshot["publicKey"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "publicKey")
        }
      }

      public var createdAtEpochMs: Double? {
        get {
          return snapshot["createdAtEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var lastAccessedAtEpochMs: Double? {
        get {
          return snapshot["lastAccessedAtEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastAccessedAtEpochMs")
        }
      }

      public var tag: String? {
        get {
          return snapshot["tag"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "tag")
        }
      }
    }
  }
}

public final class RetrieveDeviceRegistrationStatusQuery: GraphQLQuery {
  public static let operationString =
    "query RetrieveDeviceRegistrationStatus($input: RetrieveDeviceRegistrationStatusInput!) {\n  retrieveDeviceRegistrationStatus(input: $input) {\n    __typename\n    deviceId\n    type\n    hasReachedRegistrationLimit\n    lastUpdatedAt\n  }\n}"

  public var input: RetrieveDeviceRegistrationStatusInput

  public init(input: RetrieveDeviceRegistrationStatusInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("retrieveDeviceRegistrationStatus", arguments: ["input": GraphQLVariable("input")], type: .object(RetrieveDeviceRegistrationStatus.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(retrieveDeviceRegistrationStatus: RetrieveDeviceRegistrationStatus? = nil) {
      self.init(snapshot: ["__typename": "Query", "retrieveDeviceRegistrationStatus": retrieveDeviceRegistrationStatus.flatMap { $0.snapshot }])
    }

    public var retrieveDeviceRegistrationStatus: RetrieveDeviceRegistrationStatus? {
      get {
        return (snapshot["retrieveDeviceRegistrationStatus"] as? Snapshot).flatMap { RetrieveDeviceRegistrationStatus(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "retrieveDeviceRegistrationStatus")
      }
    }

    public struct RetrieveDeviceRegistrationStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["DeviceRegistrationStatus"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("deviceId", type: .nonNull(.scalar(String.self))),
        GraphQLField("type", type: .nonNull(.scalar(String.self))),
        GraphQLField("hasReachedRegistrationLimit", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("lastUpdatedAt", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(deviceId: String, type: String, hasReachedRegistrationLimit: Bool, lastUpdatedAt: String) {
        self.init(snapshot: ["__typename": "DeviceRegistrationStatus", "deviceId": deviceId, "type": type, "hasReachedRegistrationLimit": hasReachedRegistrationLimit, "lastUpdatedAt": lastUpdatedAt])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var deviceId: String {
        get {
          return snapshot["deviceId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "deviceId")
        }
      }

      public var type: String {
        get {
          return snapshot["type"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "type")
        }
      }

      public var hasReachedRegistrationLimit: Bool {
        get {
          return snapshot["hasReachedRegistrationLimit"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "hasReachedRegistrationLimit")
        }
      }

      public var lastUpdatedAt: String {
        get {
          return snapshot["lastUpdatedAt"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastUpdatedAt")
        }
      }
    }
  }
}

public final class GetIdentityVerificationStatusQuery: GraphQLQuery {
  public static let operationString =
    "query GetIdentityVerificationStatus($input: GetIdentityVerificationStatusRequest!) {\n  getIdentityVerificationStatus(input: $input) {\n    __typename\n    owner\n    verified\n    verifiedAtEpochMs\n    verificationMethod\n    requiredVerificationMethod\n    canAttemptVerificationAgain\n    provider\n    providerRequestId\n    providerRequestHistory\n    rawResponse\n    idScanUrl\n    acceptableDocumentTypes\n    verificationLastAttemptedAtEpochMs\n    documentVerificationRawResponse\n    identityMatchProviderRequestHistory\n  }\n}"

  public var input: GetIdentityVerificationStatusRequest

  public init(input: GetIdentityVerificationStatusRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getIdentityVerificationStatus", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(GetIdentityVerificationStatus.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getIdentityVerificationStatus: GetIdentityVerificationStatus) {
      self.init(snapshot: ["__typename": "Query", "getIdentityVerificationStatus": getIdentityVerificationStatus.snapshot])
    }

    public var getIdentityVerificationStatus: GetIdentityVerificationStatus {
      get {
        return GetIdentityVerificationStatus(snapshot: snapshot["getIdentityVerificationStatus"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "getIdentityVerificationStatus")
      }
    }

    public struct GetIdentityVerificationStatus: GraphQLSelectionSet {
      public static let possibleTypes = ["GetIdentityVerificationStatusResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("owner", type: .nonNull(.scalar(String.self))),
        GraphQLField("verified", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("verifiedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("verificationMethod", type: .nonNull(.scalar(String.self))),
        GraphQLField("requiredVerificationMethod", type: .nonNull(.scalar(String.self))),
        GraphQLField("canAttemptVerificationAgain", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("provider", type: .nonNull(.scalar(String.self))),
        GraphQLField("providerRequestId", type: .nonNull(.scalar(String.self))),
        GraphQLField("providerRequestHistory", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
        GraphQLField("rawResponse", type: .nonNull(.scalar(String.self))),
        GraphQLField("idScanUrl", type: .nonNull(.scalar(String.self))),
        GraphQLField("acceptableDocumentTypes", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
        GraphQLField("verificationLastAttemptedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("documentVerificationRawResponse", type: .nonNull(.scalar(String.self))),
        GraphQLField("identityMatchProviderRequestHistory", type: .nonNull(.list(.nonNull(.scalar(String.self))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(owner: String, verified: Bool, verifiedAtEpochMs: Double, verificationMethod: String, requiredVerificationMethod: String, canAttemptVerificationAgain: Bool, provider: String, providerRequestId: String, providerRequestHistory: [String], rawResponse: String, idScanUrl: String, acceptableDocumentTypes: [String], verificationLastAttemptedAtEpochMs: Double, documentVerificationRawResponse: String, identityMatchProviderRequestHistory: [String]) {
        self.init(snapshot: ["__typename": "GetIdentityVerificationStatusResponse", "owner": owner, "verified": verified, "verifiedAtEpochMs": verifiedAtEpochMs, "verificationMethod": verificationMethod, "requiredVerificationMethod": requiredVerificationMethod, "canAttemptVerificationAgain": canAttemptVerificationAgain, "provider": provider, "providerRequestId": providerRequestId, "providerRequestHistory": providerRequestHistory, "rawResponse": rawResponse, "idScanUrl": idScanUrl, "acceptableDocumentTypes": acceptableDocumentTypes, "verificationLastAttemptedAtEpochMs": verificationLastAttemptedAtEpochMs, "documentVerificationRawResponse": documentVerificationRawResponse, "identityMatchProviderRequestHistory": identityMatchProviderRequestHistory])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var owner: String {
        get {
          return snapshot["owner"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var verified: Bool {
        get {
          return snapshot["verified"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "verified")
        }
      }

      public var verifiedAtEpochMs: Double {
        get {
          return snapshot["verifiedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "verifiedAtEpochMs")
        }
      }

      public var verificationMethod: String {
        get {
          return snapshot["verificationMethod"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "verificationMethod")
        }
      }

      public var requiredVerificationMethod: String {
        get {
          return snapshot["requiredVerificationMethod"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "requiredVerificationMethod")
        }
      }

      public var canAttemptVerificationAgain: Bool {
        get {
          return snapshot["canAttemptVerificationAgain"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "canAttemptVerificationAgain")
        }
      }

      public var provider: String {
        get {
          return snapshot["provider"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "provider")
        }
      }

      public var providerRequestId: String {
        get {
          return snapshot["providerRequestId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "providerRequestId")
        }
      }

      public var providerRequestHistory: [String] {
        get {
          return snapshot["providerRequestHistory"]! as! [String]
        }
        set {
          snapshot.updateValue(newValue, forKey: "providerRequestHistory")
        }
      }

      public var rawResponse: String {
        get {
          return snapshot["rawResponse"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "rawResponse")
        }
      }

      public var idScanUrl: String {
        get {
          return snapshot["idScanUrl"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "idScanUrl")
        }
      }

      public var acceptableDocumentTypes: [String] {
        get {
          return snapshot["acceptableDocumentTypes"]! as! [String]
        }
        set {
          snapshot.updateValue(newValue, forKey: "acceptableDocumentTypes")
        }
      }

      public var verificationLastAttemptedAtEpochMs: Double {
        get {
          return snapshot["verificationLastAttemptedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "verificationLastAttemptedAtEpochMs")
        }
      }

      public var documentVerificationRawResponse: String {
        get {
          return snapshot["documentVerificationRawResponse"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "documentVerificationRawResponse")
        }
      }

      public var identityMatchProviderRequestHistory: [String] {
        get {
          return snapshot["identityMatchProviderRequestHistory"]! as! [String]
        }
        set {
          snapshot.updateValue(newValue, forKey: "identityMatchProviderRequestHistory")
        }
      }
    }
  }
}

public final class DoesIdentityMatchVerifiedIdentityQuery: GraphQLQuery {
  public static let operationString =
    "query DoesIdentityMatchVerifiedIdentity($input: VerifiedIdentityMatchRequest!) {\n  doesIdentityMatchVerifiedIdentity(input: $input) {\n    __typename\n    match\n    confidence\n  }\n}"

  public var input: VerifiedIdentityMatchRequest

  public init(input: VerifiedIdentityMatchRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("doesIdentityMatchVerifiedIdentity", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(DoesIdentityMatchVerifiedIdentity.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(doesIdentityMatchVerifiedIdentity: DoesIdentityMatchVerifiedIdentity) {
      self.init(snapshot: ["__typename": "Query", "doesIdentityMatchVerifiedIdentity": doesIdentityMatchVerifiedIdentity.snapshot])
    }

    public var doesIdentityMatchVerifiedIdentity: DoesIdentityMatchVerifiedIdentity {
      get {
        return DoesIdentityMatchVerifiedIdentity(snapshot: snapshot["doesIdentityMatchVerifiedIdentity"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "doesIdentityMatchVerifiedIdentity")
      }
    }

    public struct DoesIdentityMatchVerifiedIdentity: GraphQLSelectionSet {
      public static let possibleTypes = ["VerifiedIdentityMatchResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("match", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("confidence", type: .nonNull(.scalar(Double.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(match: Bool, confidence: Double) {
        self.init(snapshot: ["__typename": "VerifiedIdentityMatchResponse", "match": match, "confidence": confidence])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var match: Bool {
        get {
          return snapshot["match"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "match")
        }
      }

      public var confidence: Double {
        get {
          return snapshot["confidence"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "confidence")
        }
      }
    }
  }
}

public final class ListNotificationProvidersQuery: GraphQLQuery {
  public static let operationString =
    "query ListNotificationProviders {\n  listNotificationProviders {\n    __typename\n    items {\n      __typename\n      bundleId\n      appName\n      platform\n      notificationType\n      expiration\n      createdAt\n      updatedAt\n      providerArn\n    }\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listNotificationProviders", type: .object(ListNotificationProvider.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listNotificationProviders: ListNotificationProvider? = nil) {
      self.init(snapshot: ["__typename": "Query", "listNotificationProviders": listNotificationProviders.flatMap { $0.snapshot }])
    }

    public var listNotificationProviders: ListNotificationProvider? {
      get {
        return (snapshot["listNotificationProviders"] as? Snapshot).flatMap { ListNotificationProvider(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listNotificationProviders")
      }
    }

    public struct ListNotificationProvider: GraphQLSelectionSet {
      public static let possibleTypes = ["ListProvidersOutput"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]) {
        self.init(snapshot: ["__typename": "ListProvidersOutput", "items": items.map { $0.flatMap { $0.snapshot } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["NotificationProvider"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("bundleId", type: .scalar(String.self)),
          GraphQLField("appName", type: .scalar(String.self)),
          GraphQLField("platform", type: .scalar(platformProviderType.self)),
          // GraphQLField("notificationType", type: .scalar(notificationType.self)),
          GraphQLField("expiration", type: .scalar(String.self)),
          GraphQLField("createdAt", type: .scalar(String.self)),
          GraphQLField("updatedAt", type: .scalar(String.self)),
          GraphQLField("providerArn", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(bundleId: String? = nil, appName: String? = nil, platform: platformProviderType? = nil, notificationType: notificationType? = nil, expiration: String? = nil, createdAt: String? = nil, updatedAt: String? = nil, providerArn: String? = nil) {
          self.init(snapshot: ["__typename": "NotificationProvider", "bundleId": bundleId, "appName": appName, "platform": platform, "notificationType": notificationType, "expiration": expiration, "createdAt": createdAt, "updatedAt": updatedAt, "providerArn": providerArn])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var bundleId: String? {
          get {
            return snapshot["bundleId"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bundleId")
          }
        }

        public var appName: String? {
          get {
            return snapshot["appName"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "appName")
          }
        }

        public var platform: platformProviderType? {
          get {
            return snapshot["platform"] as? platformProviderType
          }
          set {
            snapshot.updateValue(newValue, forKey: "platform")
          }
        }

        public var notificationType: notificationType? {
          get {
            return snapshot["notificationType"] as? notificationType
          }
          set {
            snapshot.updateValue(newValue, forKey: "notificationType")
          }
        }

        public var expiration: String? {
          get {
            return snapshot["expiration"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "expiration")
          }
        }

        public var createdAt: String? {
          get {
            return snapshot["createdAt"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String? {
          get {
            return snapshot["updatedAt"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var providerArn: String? {
          get {
            return snapshot["providerArn"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "providerArn")
          }
        }
      }
    }
  }
}

public final class ListDevicesByUserIdQuery: GraphQLQuery {
  public static let operationString =
    "query ListDevicesByUserId($input: ListDevicesInput!) {\n  listDevicesByUserId(input: $input) {\n    __typename\n    items {\n      __typename\n      deviceId\n      userId\n      bundleId\n      clientEnv\n      createdAt\n      updatedAt\n      voipEndpointARN\n      stdEndpointARN\n      notificationSettings\n      locale\n      build\n      version\n    }\n  }\n}"

  public var input: ListDevicesInput

  public init(input: ListDevicesInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listDevicesByUserId", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(ListDevicesByUserId.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listDevicesByUserId: ListDevicesByUserId) {
      self.init(snapshot: ["__typename": "Query", "listDevicesByUserId": listDevicesByUserId.snapshot])
    }

    public var listDevicesByUserId: ListDevicesByUserId {
      get {
        return ListDevicesByUserId(snapshot: snapshot["listDevicesByUserId"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listDevicesByUserId")
      }
    }

    public struct ListDevicesByUserId: GraphQLSelectionSet {
      public static let possibleTypes = ["ListDevicesOutput"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.object(Item.selections)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item?]) {
        self.init(snapshot: ["__typename": "ListDevicesOutput", "items": items.map { $0.flatMap { $0.snapshot } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item?] {
        get {
          return (snapshot["items"] as! [Snapshot?]).map { $0.flatMap { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "items")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["DeviceInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("deviceId", type: .scalar(String.self)),
          GraphQLField("userId", type: .scalar(String.self)),
          GraphQLField("bundleId", type: .scalar(String.self)),
          GraphQLField("clientEnv", type: .scalar(ClientEnvType.self)),
          GraphQLField("createdAt", type: .scalar(String.self)),
          GraphQLField("updatedAt", type: .scalar(String.self)),
          GraphQLField("voipEndpointARN", type: .scalar(String.self)),
          GraphQLField("stdEndpointARN", type: .scalar(String.self)),
          GraphQLField("notificationSettings", type: .scalar(String.self)),
          GraphQLField("locale", type: .scalar(String.self)),
          GraphQLField("build", type: .scalar(String.self)),
          GraphQLField("version", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(deviceId: String? = nil, userId: String? = nil, bundleId: String? = nil, clientEnv: ClientEnvType? = nil, createdAt: String? = nil, updatedAt: String? = nil, voipEndpointArn: String? = nil, stdEndpointArn: String? = nil, notificationSettings: String? = nil, locale: String? = nil, build: String? = nil, version: String? = nil) {
          self.init(snapshot: ["__typename": "DeviceInfo", "deviceId": deviceId, "userId": userId, "bundleId": bundleId, "clientEnv": clientEnv, "createdAt": createdAt, "updatedAt": updatedAt, "voipEndpointARN": voipEndpointArn, "stdEndpointARN": stdEndpointArn, "notificationSettings": notificationSettings, "locale": locale, "build": build, "version": version])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var deviceId: String? {
          get {
            return snapshot["deviceId"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "deviceId")
          }
        }

        public var userId: String? {
          get {
            return snapshot["userId"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "userId")
          }
        }

        public var bundleId: String? {
          get {
            return snapshot["bundleId"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "bundleId")
          }
        }

        public var clientEnv: ClientEnvType? {
          get {
            return snapshot["clientEnv"] as? ClientEnvType
          }
          set {
            snapshot.updateValue(newValue, forKey: "clientEnv")
          }
        }

        public var createdAt: String? {
          get {
            return snapshot["createdAt"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String? {
          get {
            return snapshot["updatedAt"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }

        public var voipEndpointArn: String? {
          get {
            return snapshot["voipEndpointARN"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "voipEndpointARN")
          }
        }

        public var stdEndpointArn: String? {
          get {
            return snapshot["stdEndpointARN"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "stdEndpointARN")
          }
        }

        public var notificationSettings: String? {
          get {
            return snapshot["notificationSettings"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "notificationSettings")
          }
        }

        public var locale: String? {
          get {
            return snapshot["locale"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "locale")
          }
        }

        public var build: String? {
          get {
            return snapshot["build"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "build")
          }
        }

        public var version: String? {
          get {
            return snapshot["version"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }
      }
    }
  }
}

public final class ListUserSudosQuery: GraphQLQuery {
  public static let operationString =
    "query ListUserSudos($owner: String!) {\n  listUserSudos(owner: $owner) {\n    __typename\n    items {\n      __typename\n      id\n      owner\n      createdAt\n      updatedAt\n    }\n  }\n}"

  public var owner: String

  public init(owner: String) {
    self.owner = owner
  }

  public var variables: GraphQLMap? {
    return ["owner": owner]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listUserSudos", arguments: ["owner": GraphQLVariable("owner")], type: .nonNull(.object(ListUserSudo.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listUserSudos: ListUserSudo) {
      self.init(snapshot: ["__typename": "Query", "listUserSudos": listUserSudos.snapshot])
    }

    public var listUserSudos: ListUserSudo {
      get {
        return ListUserSudo(snapshot: snapshot["listUserSudos"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "listUserSudos")
      }
    }

    public struct ListUserSudo: GraphQLSelectionSet {
      public static let possibleTypes = ["Sudos"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .list(.nonNull(.object(Item.selections)))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item]? = nil) {
        self.init(snapshot: ["__typename": "Sudos", "items": items.flatMap { $0.map { $0.snapshot } }])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item]? {
        get {
          return (snapshot["items"] as? [Snapshot]).flatMap { $0.map { Item(snapshot: $0) } }
        }
        set {
          snapshot.updateValue(newValue.flatMap { $0.map { $0.snapshot } }, forKey: "items")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["Sudo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("owner", type: .nonNull(.scalar(String.self))),
          GraphQLField("createdAt", type: .nonNull(.scalar(String.self))),
          GraphQLField("updatedAt", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, owner: String, createdAt: String, updatedAt: String) {
          self.init(snapshot: ["__typename": "Sudo", "id": id, "owner": owner, "createdAt": createdAt, "updatedAt": updatedAt])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: String {
          get {
            return snapshot["owner"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var createdAt: String {
          get {
            return snapshot["createdAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAt")
          }
        }

        public var updatedAt: String {
          get {
            return snapshot["updatedAt"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAt")
          }
        }
      }
    }
  }
}

public final class ListVaultsMetadataOnlyBySubQuery: GraphQLQuery {
  public static let operationString =
    "query ListVaultsMetadataOnlyBySub($sub: String!, $limit: Int, $nextToken: String) {\n  listVaultsMetadataOnlyBySub(sub: $sub, limit: $limit, nextToken: $nextToken) {\n    __typename\n    items {\n      __typename\n      id\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      owner\n      blobFormat\n      encryptionMethod\n    }\n    nextToken\n  }\n}"

  public var sub: String
  public var limit: Int?
  public var nextToken: String?

  public init(sub: String, limit: Int? = nil, nextToken: String? = nil) {
    self.sub = sub
    self.limit = limit
    self.nextToken = nextToken
  }

  public var variables: GraphQLMap? {
    return ["sub": sub, "limit": limit, "nextToken": nextToken]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listVaultsMetadataOnlyBySub", arguments: ["sub": GraphQLVariable("sub"), "limit": GraphQLVariable("limit"), "nextToken": GraphQLVariable("nextToken")], type: .object(ListVaultsMetadataOnlyBySub.selections)),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listVaultsMetadataOnlyBySub: ListVaultsMetadataOnlyBySub? = nil) {
      self.init(snapshot: ["__typename": "Query", "listVaultsMetadataOnlyBySub": listVaultsMetadataOnlyBySub.flatMap { $0.snapshot }])
    }

    public var listVaultsMetadataOnlyBySub: ListVaultsMetadataOnlyBySub? {
      get {
        return (snapshot["listVaultsMetadataOnlyBySub"] as? Snapshot).flatMap { ListVaultsMetadataOnlyBySub(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue?.snapshot, forKey: "listVaultsMetadataOnlyBySub")
      }
    }

    public struct ListVaultsMetadataOnlyBySub: GraphQLSelectionSet {
      public static let possibleTypes = ["ModelVaultMetadataConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("items", type: .nonNull(.list(.nonNull(.object(Item.selections))))),
        GraphQLField("nextToken", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(items: [Item], nextToken: String? = nil) {
        self.init(snapshot: ["__typename": "ModelVaultMetadataConnection", "items": items.map { $0.snapshot }, "nextToken": nextToken])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var items: [Item] {
        get {
          return (snapshot["items"] as! [Snapshot]).map { Item(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "items")
        }
      }

      public var nextToken: String? {
        get {
          return snapshot["nextToken"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "nextToken")
        }
      }

      public struct Item: GraphQLSelectionSet {
        public static let possibleTypes = ["VaultMetadata"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("blobFormat", type: .nonNull(.scalar(String.self))),
          GraphQLField("encryptionMethod", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, owner: GraphQLID, blobFormat: String, encryptionMethod: String) {
          self.init(snapshot: ["__typename": "VaultMetadata", "id": id, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "owner": owner, "blobFormat": blobFormat, "encryptionMethod": encryptionMethod])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var blobFormat: String {
          get {
            return snapshot["blobFormat"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "blobFormat")
          }
        }

        public var encryptionMethod: String {
          get {
            return snapshot["encryptionMethod"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "encryptionMethod")
          }
        }
      }
    }
  }
}

public final class SearchVirtualCardsTransactionsQuery: GraphQLQuery {
  public static let operationString =
    "query SearchVirtualCardsTransactions($input: SearchVirtualCardsTransactionsRequest!) {\n  searchVirtualCardsTransactions(input: $input) {\n    __typename\n    id\n    cardState\n    last4\n    transactions {\n      __typename\n      nextToken\n    }\n  }\n}"

  public var input: SearchVirtualCardsTransactionsRequest

  public init(input: SearchVirtualCardsTransactionsRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("searchVirtualCardsTransactions", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(SearchVirtualCardsTransaction.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(searchVirtualCardsTransactions: SearchVirtualCardsTransaction) {
      self.init(snapshot: ["__typename": "Query", "searchVirtualCardsTransactions": searchVirtualCardsTransactions.snapshot])
    }

    public var searchVirtualCardsTransactions: SearchVirtualCardsTransaction {
      get {
        return SearchVirtualCardsTransaction(snapshot: snapshot["searchVirtualCardsTransactions"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "searchVirtualCardsTransactions")
      }
    }

    public struct SearchVirtualCardsTransaction: GraphQLSelectionSet {
      public static let possibleTypes = ["TransactionResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("cardState", type: .nonNull(.scalar(CardState.self))),
        GraphQLField("last4", type: .nonNull(.scalar(String.self))),
        GraphQLField("transactions", type: .nonNull(.object(Transaction.selections))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, cardState: CardState, last4: String, transactions: Transaction) {
        self.init(snapshot: ["__typename": "TransactionResponse", "id": id, "cardState": cardState, "last4": last4, "transactions": transactions.snapshot])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var cardState: CardState {
        get {
          return snapshot["cardState"]! as! CardState
        }
        set {
          snapshot.updateValue(newValue, forKey: "cardState")
        }
      }

      public var last4: String {
        get {
          return snapshot["last4"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "last4")
        }
      }

      public var transactions: Transaction {
        get {
          return Transaction(snapshot: snapshot["transactions"]! as! Snapshot)
        }
        set {
          snapshot.updateValue(newValue.snapshot, forKey: "transactions")
        }
      }

      public struct Transaction: GraphQLSelectionSet {
        public static let possibleTypes = ["TransactionConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nextToken", type: .scalar(String.self)),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(nextToken: String? = nil) {
          self.init(snapshot: ["__typename": "TransactionConnection", "nextToken": nextToken])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var nextToken: String? {
          get {
            return snapshot["nextToken"] as? String
          }
          set {
            snapshot.updateValue(newValue, forKey: "nextToken")
          }
        }
      }
    }
  }
}

public final class ListVirtualCardsBySudoQuery: GraphQLQuery {
  public static let operationString =
    "query ListVirtualCardsBySudo($input: ListVirtualCardsBySudoRequest!) {\n  listVirtualCardsBySudo(input: $input) {\n    __typename\n    id\n    owner\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    algorithm\n    keyId\n    keyRingId\n    owners {\n      __typename\n      id\n      issuer\n    }\n    fundingSourceId\n    currency\n    state\n    stateReason\n    activeToEpochMs\n    cancelledAtEpochMs\n    last4\n  }\n}"

  public var input: ListVirtualCardsBySudoRequest

  public init(input: ListVirtualCardsBySudoRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listVirtualCardsBySudo", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.list(.nonNull(.object(ListVirtualCardsBySudo.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listVirtualCardsBySudo: [ListVirtualCardsBySudo]) {
      self.init(snapshot: ["__typename": "Query", "listVirtualCardsBySudo": listVirtualCardsBySudo.map { $0.snapshot }])
    }

    public var listVirtualCardsBySudo: [ListVirtualCardsBySudo] {
      get {
        return (snapshot["listVirtualCardsBySudo"] as! [Snapshot]).map { ListVirtualCardsBySudo(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "listVirtualCardsBySudo")
      }
    }

    public struct ListVirtualCardsBySudo: GraphQLSelectionSet {
      public static let possibleTypes = ["VirtualCard"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("algorithm", type: .nonNull(.scalar(String.self))),
        GraphQLField("keyId", type: .nonNull(.scalar(String.self))),
        GraphQLField("keyRingId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
        GraphQLField("fundingSourceId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        GraphQLField("state", type: .nonNull(.scalar(CardState.self))),
        GraphQLField("stateReason", type: .nonNull(.scalar(StateReason.self))),
        GraphQLField("activeToEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("cancelledAtEpochMs", type: .scalar(Double.self)),
        GraphQLField("last4", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, algorithm: String, keyId: String, keyRingId: GraphQLID, owners: [Owner], fundingSourceId: GraphQLID, currency: String, state: CardState, stateReason: StateReason, activeToEpochMs: Double, cancelledAtEpochMs: Double? = nil, last4: String) {
        self.init(snapshot: ["__typename": "VirtualCard", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "algorithm": algorithm, "keyId": keyId, "keyRingId": keyRingId, "owners": owners.map { $0.snapshot }, "fundingSourceId": fundingSourceId, "currency": currency, "state": state, "stateReason": stateReason, "activeToEpochMs": activeToEpochMs, "cancelledAtEpochMs": cancelledAtEpochMs, "last4": last4])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var algorithm: String {
        get {
          return snapshot["algorithm"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "algorithm")
        }
      }

      public var keyId: String {
        get {
          return snapshot["keyId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyId")
        }
      }

      public var keyRingId: GraphQLID {
        get {
          return snapshot["keyRingId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyRingId")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public var fundingSourceId: GraphQLID {
        get {
          return snapshot["fundingSourceId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "fundingSourceId")
        }
      }

      public var currency: String {
        get {
          return snapshot["currency"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "currency")
        }
      }

      public var state: CardState {
        get {
          return snapshot["state"]! as! CardState
        }
        set {
          snapshot.updateValue(newValue, forKey: "state")
        }
      }

      public var stateReason: StateReason {
        get {
          return snapshot["stateReason"]! as! StateReason
        }
        set {
          snapshot.updateValue(newValue, forKey: "stateReason")
        }
      }

      public var activeToEpochMs: Double {
        get {
          return snapshot["activeToEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "activeToEpochMs")
        }
      }

      public var cancelledAtEpochMs: Double? {
        get {
          return snapshot["cancelledAtEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "cancelledAtEpochMs")
        }
      }

      public var last4: String {
        get {
          return snapshot["last4"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "last4")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }
    }
  }
}

public final class ListVirtualCardsBySubQuery: GraphQLQuery {
  public static let operationString =
    "query ListVirtualCardsBySub($input: ListVirtualCardsBySubRequest!) {\n  listVirtualCardsBySub(input: $input) {\n    __typename\n    id\n    owner\n    version\n    createdAtEpochMs\n    updatedAtEpochMs\n    algorithm\n    keyId\n    keyRingId\n    owners {\n      __typename\n      id\n      issuer\n    }\n    fundingSourceId\n    currency\n    state\n    stateReason\n    activeToEpochMs\n    cancelledAtEpochMs\n    last4\n  }\n}"

  public var input: ListVirtualCardsBySubRequest

  public init(input: ListVirtualCardsBySubRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listVirtualCardsBySub", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.list(.nonNull(.object(ListVirtualCardsBySub.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listVirtualCardsBySub: [ListVirtualCardsBySub]) {
      self.init(snapshot: ["__typename": "Query", "listVirtualCardsBySub": listVirtualCardsBySub.map { $0.snapshot }])
    }

    public var listVirtualCardsBySub: [ListVirtualCardsBySub] {
      get {
        return (snapshot["listVirtualCardsBySub"] as! [Snapshot]).map { ListVirtualCardsBySub(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "listVirtualCardsBySub")
      }
    }

    public struct ListVirtualCardsBySub: GraphQLSelectionSet {
      public static let possibleTypes = ["VirtualCard"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("version", type: .nonNull(.scalar(Int.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("algorithm", type: .nonNull(.scalar(String.self))),
        GraphQLField("keyId", type: .nonNull(.scalar(String.self))),
        GraphQLField("keyRingId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("owners", type: .nonNull(.list(.nonNull(.object(Owner.selections))))),
        GraphQLField("fundingSourceId", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        GraphQLField("state", type: .nonNull(.scalar(CardState.self))),
        GraphQLField("stateReason", type: .nonNull(.scalar(StateReason.self))),
        GraphQLField("activeToEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("cancelledAtEpochMs", type: .scalar(Double.self)),
        GraphQLField("last4", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, algorithm: String, keyId: String, keyRingId: GraphQLID, owners: [Owner], fundingSourceId: GraphQLID, currency: String, state: CardState, stateReason: StateReason, activeToEpochMs: Double, cancelledAtEpochMs: Double? = nil, last4: String) {
        self.init(snapshot: ["__typename": "VirtualCard", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "algorithm": algorithm, "keyId": keyId, "keyRingId": keyRingId, "owners": owners.map { $0.snapshot }, "fundingSourceId": fundingSourceId, "currency": currency, "state": state, "stateReason": stateReason, "activeToEpochMs": activeToEpochMs, "cancelledAtEpochMs": cancelledAtEpochMs, "last4": last4])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var owner: GraphQLID {
        get {
          return snapshot["owner"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "owner")
        }
      }

      public var version: Int {
        get {
          return snapshot["version"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "version")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }

      public var algorithm: String {
        get {
          return snapshot["algorithm"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "algorithm")
        }
      }

      public var keyId: String {
        get {
          return snapshot["keyId"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyId")
        }
      }

      public var keyRingId: GraphQLID {
        get {
          return snapshot["keyRingId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "keyRingId")
        }
      }

      public var owners: [Owner] {
        get {
          return (snapshot["owners"] as! [Snapshot]).map { Owner(snapshot: $0) }
        }
        set {
          snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "owners")
        }
      }

      public var fundingSourceId: GraphQLID {
        get {
          return snapshot["fundingSourceId"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "fundingSourceId")
        }
      }

      public var currency: String {
        get {
          return snapshot["currency"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "currency")
        }
      }

      public var state: CardState {
        get {
          return snapshot["state"]! as! CardState
        }
        set {
          snapshot.updateValue(newValue, forKey: "state")
        }
      }

      public var stateReason: StateReason {
        get {
          return snapshot["stateReason"]! as! StateReason
        }
        set {
          snapshot.updateValue(newValue, forKey: "stateReason")
        }
      }

      public var activeToEpochMs: Double {
        get {
          return snapshot["activeToEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "activeToEpochMs")
        }
      }

      public var cancelledAtEpochMs: Double? {
        get {
          return snapshot["cancelledAtEpochMs"] as? Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "cancelledAtEpochMs")
        }
      }

      public var last4: String {
        get {
          return snapshot["last4"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "last4")
        }
      }

      public struct Owner: GraphQLSelectionSet {
        public static let possibleTypes = ["Owner"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("issuer", type: .nonNull(.scalar(String.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: String, issuer: String) {
          self.init(snapshot: ["__typename": "Owner", "id": id, "issuer": issuer])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return snapshot["id"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var issuer: String {
          get {
            return snapshot["issuer"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "issuer")
          }
        }
      }
    }
  }
}

public final class ListFundingSourcesBySubQuery: GraphQLQuery {
  public static let operationString =
    "query ListFundingSourcesBySub($input: ListFundingSourcesBySubRequest!) {\n  listFundingSourcesBySub(input: $input) {\n    __typename\n    ... on CreditCardFundingSource {\n      id\n      owner\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      state\n      currency\n      fingerprint\n      last4\n      cardType\n      network\n    }\n    ... on BankAccountFundingSource {\n      id\n      owner\n      version\n      createdAtEpochMs\n      updatedAtEpochMs\n      state\n      currency\n      fingerprint\n      bankAccountType\n      authorization {\n        __typename\n        data\n        signature\n        algorithm\n        keyId\n        content\n        contentType\n        language\n      }\n    }\n  }\n}"

  public var input: ListFundingSourcesBySubRequest

  public init(input: ListFundingSourcesBySubRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listFundingSourcesBySub", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.list(.nonNull(.object(ListFundingSourcesBySub.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listFundingSourcesBySub: [ListFundingSourcesBySub]) {
      self.init(snapshot: ["__typename": "Query", "listFundingSourcesBySub": listFundingSourcesBySub.map { $0.snapshot }])
    }

    public var listFundingSourcesBySub: [ListFundingSourcesBySub] {
      get {
        return (snapshot["listFundingSourcesBySub"] as! [Snapshot]).map { ListFundingSourcesBySub(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "listFundingSourcesBySub")
      }
    }

    public struct ListFundingSourcesBySub: GraphQLSelectionSet {
      public static let possibleTypes = ["CreditCardFundingSource", "BankAccountFundingSource"]

      public static let selections: [GraphQLSelection] = [
        GraphQLTypeCase(
          variants: ["CreditCardFundingSource": AsCreditCardFundingSource.selections, "BankAccountFundingSource": AsBankAccountFundingSource.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public static func makeCreditCardFundingSource(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, last4: String, cardType: CardType, network: CreditCardNetwork) -> ListFundingSourcesBySub {
        return ListFundingSourcesBySub(snapshot: ["__typename": "CreditCardFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "last4": last4, "cardType": cardType, "network": network])
      }

      public static func makeBankAccountFundingSource(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, bankAccountType: BankAccountType, authorization: AsBankAccountFundingSource.Authorization) -> ListFundingSourcesBySub {
        return ListFundingSourcesBySub(snapshot: ["__typename": "BankAccountFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "bankAccountType": bankAccountType, "authorization": authorization.snapshot])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var asCreditCardFundingSource: AsCreditCardFundingSource? {
        get {
          if !AsCreditCardFundingSource.possibleTypes.contains(__typename) { return nil }
          return AsCreditCardFundingSource(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsCreditCardFundingSource: GraphQLSelectionSet {
        public static let possibleTypes = ["CreditCardFundingSource"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("state", type: .nonNull(.scalar(FundingSourceState.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("fingerprint", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("last4", type: .nonNull(.scalar(String.self))),
          GraphQLField("cardType", type: .nonNull(.scalar(CardType.self))),
          GraphQLField("network", type: .nonNull(.scalar(CreditCardNetwork.self))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, last4: String, cardType: CardType, network: CreditCardNetwork) {
          self.init(snapshot: ["__typename": "CreditCardFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "last4": last4, "cardType": cardType, "network": network])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var state: FundingSourceState {
          get {
            return snapshot["state"]! as! FundingSourceState
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var fingerprint: GraphQLID {
          get {
            return snapshot["fingerprint"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fingerprint")
          }
        }

        public var last4: String {
          get {
            return snapshot["last4"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "last4")
          }
        }

        public var cardType: CardType {
          get {
            return snapshot["cardType"]! as! CardType
          }
          set {
            snapshot.updateValue(newValue, forKey: "cardType")
          }
        }

        public var network: CreditCardNetwork {
          get {
            return snapshot["network"]! as! CreditCardNetwork
          }
          set {
            snapshot.updateValue(newValue, forKey: "network")
          }
        }
      }

      public var asBankAccountFundingSource: AsBankAccountFundingSource? {
        get {
          if !AsBankAccountFundingSource.possibleTypes.contains(__typename) { return nil }
          return AsBankAccountFundingSource(snapshot: snapshot)
        }
        set {
          guard let newValue = newValue else { return }
          snapshot = newValue.snapshot
        }
      }

      public struct AsBankAccountFundingSource: GraphQLSelectionSet {
        public static let possibleTypes = ["BankAccountFundingSource"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("owner", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("version", type: .nonNull(.scalar(Int.self))),
          GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
          GraphQLField("state", type: .nonNull(.scalar(FundingSourceState.self))),
          GraphQLField("currency", type: .nonNull(.scalar(String.self))),
          GraphQLField("fingerprint", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("bankAccountType", type: .nonNull(.scalar(BankAccountType.self))),
          GraphQLField("authorization", type: .nonNull(.object(Authorization.selections))),
        ]

        public var snapshot: Snapshot

        public init(snapshot: Snapshot) {
          self.snapshot = snapshot
        }

        public init(id: GraphQLID, owner: GraphQLID, version: Int, createdAtEpochMs: Double, updatedAtEpochMs: Double, state: FundingSourceState, currency: String, fingerprint: GraphQLID, bankAccountType: BankAccountType, authorization: Authorization) {
          self.init(snapshot: ["__typename": "BankAccountFundingSource", "id": id, "owner": owner, "version": version, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs, "state": state, "currency": currency, "fingerprint": fingerprint, "bankAccountType": bankAccountType, "authorization": authorization.snapshot])
        }

        public var __typename: String {
          get {
            return snapshot["__typename"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: GraphQLID {
          get {
            return snapshot["id"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "id")
          }
        }

        public var owner: GraphQLID {
          get {
            return snapshot["owner"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "owner")
          }
        }

        public var version: Int {
          get {
            return snapshot["version"]! as! Int
          }
          set {
            snapshot.updateValue(newValue, forKey: "version")
          }
        }

        public var createdAtEpochMs: Double {
          get {
            return snapshot["createdAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
          }
        }

        public var updatedAtEpochMs: Double {
          get {
            return snapshot["updatedAtEpochMs"]! as! Double
          }
          set {
            snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
          }
        }

        public var state: FundingSourceState {
          get {
            return snapshot["state"]! as! FundingSourceState
          }
          set {
            snapshot.updateValue(newValue, forKey: "state")
          }
        }

        public var currency: String {
          get {
            return snapshot["currency"]! as! String
          }
          set {
            snapshot.updateValue(newValue, forKey: "currency")
          }
        }

        public var fingerprint: GraphQLID {
          get {
            return snapshot["fingerprint"]! as! GraphQLID
          }
          set {
            snapshot.updateValue(newValue, forKey: "fingerprint")
          }
        }

        public var bankAccountType: BankAccountType {
          get {
            return snapshot["bankAccountType"]! as! BankAccountType
          }
          set {
            snapshot.updateValue(newValue, forKey: "bankAccountType")
          }
        }

        public var authorization: Authorization {
          get {
            return Authorization(snapshot: snapshot["authorization"]! as! Snapshot)
          }
          set {
            snapshot.updateValue(newValue.snapshot, forKey: "authorization")
          }
        }

        public struct Authorization: GraphQLSelectionSet {
          public static let possibleTypes = ["SignedAuthorizationText"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("data", type: .nonNull(.scalar(String.self))),
            GraphQLField("signature", type: .nonNull(.scalar(String.self))),
            GraphQLField("algorithm", type: .nonNull(.scalar(String.self))),
            GraphQLField("keyId", type: .nonNull(.scalar(String.self))),
            GraphQLField("content", type: .nonNull(.scalar(String.self))),
            GraphQLField("contentType", type: .nonNull(.scalar(String.self))),
            GraphQLField("language", type: .nonNull(.scalar(String.self))),
          ]

          public var snapshot: Snapshot

          public init(snapshot: Snapshot) {
            self.snapshot = snapshot
          }

          public init(data: String, signature: String, algorithm: String, keyId: String, content: String, contentType: String, language: String) {
            self.init(snapshot: ["__typename": "SignedAuthorizationText", "data": data, "signature": signature, "algorithm": algorithm, "keyId": keyId, "content": content, "contentType": contentType, "language": language])
          }

          public var __typename: String {
            get {
              return snapshot["__typename"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "__typename")
            }
          }

          public var data: String {
            get {
              return snapshot["data"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "data")
            }
          }

          public var signature: String {
            get {
              return snapshot["signature"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "signature")
            }
          }

          public var algorithm: String {
            get {
              return snapshot["algorithm"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "algorithm")
            }
          }

          public var keyId: String {
            get {
              return snapshot["keyId"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "keyId")
            }
          }

          public var content: String {
            get {
              return snapshot["content"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "content")
            }
          }

          public var contentType: String {
            get {
              return snapshot["contentType"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "contentType")
            }
          }

          public var language: String {
            get {
              return snapshot["language"]! as! String
            }
            set {
              snapshot.updateValue(newValue, forKey: "language")
            }
          }
        }
      }
    }
  }
}

public final class GetVirtualCardsActiveQuery: GraphQLQuery {
  public static let operationString =
    "query GetVirtualCardsActive($input: GetVirtualCardsActiveRequest!) {\n  getVirtualCardsActive(input: $input) {\n    __typename\n    startDate\n    endDate\n    timeZone\n    activeCards\n  }\n}"

  public var input: GetVirtualCardsActiveRequest

  public init(input: GetVirtualCardsActiveRequest) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getVirtualCardsActive", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(GetVirtualCardsActive.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getVirtualCardsActive: GetVirtualCardsActive) {
      self.init(snapshot: ["__typename": "Query", "getVirtualCardsActive": getVirtualCardsActive.snapshot])
    }

    public var getVirtualCardsActive: GetVirtualCardsActive {
      get {
        return GetVirtualCardsActive(snapshot: snapshot["getVirtualCardsActive"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "getVirtualCardsActive")
      }
    }

    public struct GetVirtualCardsActive: GraphQLSelectionSet {
      public static let possibleTypes = ["GetVirtualCardsActiveResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("startDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("endDate", type: .nonNull(.scalar(String.self))),
        GraphQLField("timeZone", type: .nonNull(.scalar(String.self))),
        GraphQLField("activeCards", type: .nonNull(.list(.nonNull(.scalar(Int.self))))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(startDate: String, endDate: String, timeZone: String, activeCards: [Int]) {
        self.init(snapshot: ["__typename": "GetVirtualCardsActiveResponse", "startDate": startDate, "endDate": endDate, "timeZone": timeZone, "activeCards": activeCards])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var startDate: String {
        get {
          return snapshot["startDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "startDate")
        }
      }

      public var endDate: String {
        get {
          return snapshot["endDate"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "endDate")
        }
      }

      public var timeZone: String {
        get {
          return snapshot["timeZone"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "timeZone")
        }
      }

      public var activeCards: [Int] {
        get {
          return snapshot["activeCards"]! as! [Int]
        }
        set {
          snapshot.updateValue(newValue, forKey: "activeCards")
        }
      }
    }
  }
}

public final class ListSimulatorMerchantsQuery: GraphQLQuery {
  public static let operationString =
    "query ListSimulatorMerchants {\n  listSimulatorMerchants {\n    __typename\n    id\n    description\n    name\n    mcc\n    city\n    state\n    postalCode\n    country\n    currency\n    declineAfterAuthorization\n    declineBeforeAuthorization\n    createdAtEpochMs\n    updatedAtEpochMs\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listSimulatorMerchants", type: .nonNull(.list(.nonNull(.object(ListSimulatorMerchant.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listSimulatorMerchants: [ListSimulatorMerchant]) {
      self.init(snapshot: ["__typename": "Query", "listSimulatorMerchants": listSimulatorMerchants.map { $0.snapshot }])
    }

    public var listSimulatorMerchants: [ListSimulatorMerchant] {
      get {
        return (snapshot["listSimulatorMerchants"] as! [Snapshot]).map { ListSimulatorMerchant(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "listSimulatorMerchants")
      }
    }

    public struct ListSimulatorMerchant: GraphQLSelectionSet {
      public static let possibleTypes = ["SimulatorMerchant"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("description", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("mcc", type: .nonNull(.scalar(String.self))),
        GraphQLField("city", type: .nonNull(.scalar(String.self))),
        GraphQLField("state", type: .scalar(String.self)),
        GraphQLField("postalCode", type: .nonNull(.scalar(String.self))),
        GraphQLField("country", type: .nonNull(.scalar(String.self))),
        GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        GraphQLField("declineAfterAuthorization", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("declineBeforeAuthorization", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("createdAtEpochMs", type: .nonNull(.scalar(Double.self))),
        GraphQLField("updatedAtEpochMs", type: .nonNull(.scalar(Double.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: GraphQLID, description: String, name: String, mcc: String, city: String, state: String? = nil, postalCode: String, country: String, currency: String, declineAfterAuthorization: Bool, declineBeforeAuthorization: Bool, createdAtEpochMs: Double, updatedAtEpochMs: Double) {
        self.init(snapshot: ["__typename": "SimulatorMerchant", "id": id, "description": description, "name": name, "mcc": mcc, "city": city, "state": state, "postalCode": postalCode, "country": country, "currency": currency, "declineAfterAuthorization": declineAfterAuthorization, "declineBeforeAuthorization": declineBeforeAuthorization, "createdAtEpochMs": createdAtEpochMs, "updatedAtEpochMs": updatedAtEpochMs])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return snapshot["id"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var description: String {
        get {
          return snapshot["description"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "description")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }

      public var mcc: String {
        get {
          return snapshot["mcc"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "mcc")
        }
      }

      public var city: String {
        get {
          return snapshot["city"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "city")
        }
      }

      public var state: String? {
        get {
          return snapshot["state"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "state")
        }
      }

      public var postalCode: String {
        get {
          return snapshot["postalCode"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "postalCode")
        }
      }

      public var country: String {
        get {
          return snapshot["country"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "country")
        }
      }

      public var currency: String {
        get {
          return snapshot["currency"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "currency")
        }
      }

      public var declineAfterAuthorization: Bool {
        get {
          return snapshot["declineAfterAuthorization"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "declineAfterAuthorization")
        }
      }

      public var declineBeforeAuthorization: Bool {
        get {
          return snapshot["declineBeforeAuthorization"]! as! Bool
        }
        set {
          snapshot.updateValue(newValue, forKey: "declineBeforeAuthorization")
        }
      }

      public var createdAtEpochMs: Double {
        get {
          return snapshot["createdAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "createdAtEpochMs")
        }
      }

      public var updatedAtEpochMs: Double {
        get {
          return snapshot["updatedAtEpochMs"]! as! Double
        }
        set {
          snapshot.updateValue(newValue, forKey: "updatedAtEpochMs")
        }
      }
    }
  }
}

public final class ListSimulatorConversionRatesQuery: GraphQLQuery {
  public static let operationString =
    "query ListSimulatorConversionRates {\n  listSimulatorConversionRates {\n    __typename\n    currency\n    amount\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("listSimulatorConversionRates", type: .nonNull(.list(.nonNull(.object(ListSimulatorConversionRate.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(listSimulatorConversionRates: [ListSimulatorConversionRate]) {
      self.init(snapshot: ["__typename": "Query", "listSimulatorConversionRates": listSimulatorConversionRates.map { $0.snapshot }])
    }

    public var listSimulatorConversionRates: [ListSimulatorConversionRate] {
      get {
        return (snapshot["listSimulatorConversionRates"] as! [Snapshot]).map { ListSimulatorConversionRate(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "listSimulatorConversionRates")
      }
    }

    public struct ListSimulatorConversionRate: GraphQLSelectionSet {
      public static let possibleTypes = ["CurrencyAmount"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("currency", type: .nonNull(.scalar(String.self))),
        GraphQLField("amount", type: .nonNull(.scalar(Int.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(currency: String, amount: Int) {
        self.init(snapshot: ["__typename": "CurrencyAmount", "currency": currency, "amount": amount])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var currency: String {
        get {
          return snapshot["currency"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "currency")
        }
      }

      public var amount: Int {
        get {
          return snapshot["amount"]! as! Int
        }
        set {
          snapshot.updateValue(newValue, forKey: "amount")
        }
      }
    }
  }
}

public final class GetUserInfoQuery: GraphQLQuery {
  public static let operationString =
    "query GetUserInfo($usernames: [String!]!) {\n  getUserInfo(usernames: $usernames) {\n    __typename\n    sub\n    emailAddress\n    firstName\n    lastName\n    profilePicture\n  }\n}"

  public var usernames: [String]

  public init(usernames: [String]) {
    self.usernames = usernames
  }

  public var variables: GraphQLMap? {
    return ["usernames": usernames]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getUserInfo", arguments: ["usernames": GraphQLVariable("usernames")], type: .nonNull(.list(.object(GetUserInfo.selections)))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(getUserInfo: [GetUserInfo?]) {
      self.init(snapshot: ["__typename": "Query", "getUserInfo": getUserInfo.map { $0.flatMap { $0.snapshot } }])
    }

    public var getUserInfo: [GetUserInfo?] {
      get {
        return (snapshot["getUserInfo"] as! [Snapshot?]).map { $0.flatMap { GetUserInfo(snapshot: $0) } }
      }
      set {
        snapshot.updateValue(newValue.map { $0.flatMap { $0.snapshot } }, forKey: "getUserInfo")
      }
    }

    public struct GetUserInfo: GraphQLSelectionSet {
      public static let possibleTypes = ["UserInfo"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("sub", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("emailAddress", type: .nonNull(.scalar(String.self))),
        GraphQLField("firstName", type: .scalar(String.self)),
        GraphQLField("lastName", type: .scalar(String.self)),
        GraphQLField("profilePicture", type: .scalar(String.self)),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(sub: GraphQLID, emailAddress: String, firstName: String? = nil, lastName: String? = nil, profilePicture: String? = nil) {
        self.init(snapshot: ["__typename": "UserInfo", "sub": sub, "emailAddress": emailAddress, "firstName": firstName, "lastName": lastName, "profilePicture": profilePicture])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var sub: GraphQLID {
        get {
          return snapshot["sub"]! as! GraphQLID
        }
        set {
          snapshot.updateValue(newValue, forKey: "sub")
        }
      }

      public var emailAddress: String {
        get {
          return snapshot["emailAddress"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "emailAddress")
        }
      }

      public var firstName: String? {
        get {
          return snapshot["firstName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "firstName")
        }
      }

      public var lastName: String? {
        get {
          return snapshot["lastName"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "lastName")
        }
      }

      public var profilePicture: String? {
        get {
          return snapshot["profilePicture"] as? String
        }
        set {
          snapshot.updateValue(newValue, forKey: "profilePicture")
        }
      }
    }
  }
}

public final class ClientConfigQuery: GraphQLQuery {
  public static let operationString =
    "query ClientConfig {\n  clientConfig\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("clientConfig", type: .nonNull(.scalar(String.self))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(clientConfig: String) {
      self.init(snapshot: ["__typename": "Query", "clientConfig": clientConfig])
    }

    public var clientConfig: String {
      get {
        return snapshot["clientConfig"]! as! String
      }
      set {
        snapshot.updateValue(newValue, forKey: "clientConfig")
      }
    }
  }
}

public final class ServicesQuery: GraphQLQuery {
  public static let operationString =
    "query Services {\n  services {\n    __typename\n    id\n    code\n    name\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("services", type: .nonNull(.list(.nonNull(.object(Service.selections))))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(services: [Service]) {
      self.init(snapshot: ["__typename": "Query", "services": services.map { $0.snapshot }])
    }

    public var services: [Service] {
      get {
        return (snapshot["services"] as! [Snapshot]).map { Service(snapshot: $0) }
      }
      set {
        snapshot.updateValue(newValue.map { $0.snapshot }, forKey: "services")
      }
    }

    public struct Service: GraphQLSelectionSet {
      public static let possibleTypes = ["Service"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(String.self))),
        GraphQLField("code", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(id: String, code: String, name: String) {
        self.init(snapshot: ["__typename": "Service", "id": id, "code": code, "name": name])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: String {
        get {
          return snapshot["id"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "id")
        }
      }

      public var code: String {
        get {
          return snapshot["code"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "code")
        }
      }

      public var name: String {
        get {
          return snapshot["name"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "name")
        }
      }
    }
  }
}

public final class ReportsQuery: GraphQLQuery {
  public static let operationString =
    "query Reports {\n  reports {\n    __typename\n    usersEngagement\n    sudosIdentitiesCreated\n    totalSudosActive\n    dailyPhoneNumbersCreated\n    messagesDailyActivity\n    messagesVolume\n    messagesByCountry\n    virtualCardsDailyProvisioned\n    virtualCardsTotalActiveCards\n    virtualCardsTransactedAmountPerDay\n    virtualCardsTransactedVolumePerDay\n    voiceCallingByCountry\n    voiceCallingDailyActivity\n    voiceCallingDuration\n    voiceCallingVolume\n  }\n}"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("reports", type: .nonNull(.object(Report.selections))),
    ]

    public var snapshot: Snapshot

    public init(snapshot: Snapshot) {
      self.snapshot = snapshot
    }

    public init(reports: Report) {
      self.init(snapshot: ["__typename": "Query", "reports": reports.snapshot])
    }

    public var reports: Report {
      get {
        return Report(snapshot: snapshot["reports"]! as! Snapshot)
      }
      set {
        snapshot.updateValue(newValue.snapshot, forKey: "reports")
      }
    }

    public struct Report: GraphQLSelectionSet {
      public static let possibleTypes = ["Reports"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("usersEngagement", type: .nonNull(.scalar(String.self))),
        GraphQLField("sudosIdentitiesCreated", type: .nonNull(.scalar(String.self))),
        GraphQLField("totalSudosActive", type: .nonNull(.scalar(String.self))),
        GraphQLField("dailyPhoneNumbersCreated", type: .nonNull(.scalar(String.self))),
        GraphQLField("messagesDailyActivity", type: .nonNull(.scalar(String.self))),
        GraphQLField("messagesVolume", type: .nonNull(.scalar(String.self))),
        GraphQLField("messagesByCountry", type: .nonNull(.scalar(String.self))),
        GraphQLField("virtualCardsDailyProvisioned", type: .nonNull(.scalar(String.self))),
        GraphQLField("virtualCardsTotalActiveCards", type: .nonNull(.scalar(String.self))),
        GraphQLField("virtualCardsTransactedAmountPerDay", type: .nonNull(.scalar(String.self))),
        GraphQLField("virtualCardsTransactedVolumePerDay", type: .nonNull(.scalar(String.self))),
        GraphQLField("voiceCallingByCountry", type: .nonNull(.scalar(String.self))),
        GraphQLField("voiceCallingDailyActivity", type: .nonNull(.scalar(String.self))),
        GraphQLField("voiceCallingDuration", type: .nonNull(.scalar(String.self))),
        GraphQLField("voiceCallingVolume", type: .nonNull(.scalar(String.self))),
      ]

      public var snapshot: Snapshot

      public init(snapshot: Snapshot) {
        self.snapshot = snapshot
      }

      public init(usersEngagement: String, sudosIdentitiesCreated: String, totalSudosActive: String, dailyPhoneNumbersCreated: String, messagesDailyActivity: String, messagesVolume: String, messagesByCountry: String, virtualCardsDailyProvisioned: String, virtualCardsTotalActiveCards: String, virtualCardsTransactedAmountPerDay: String, virtualCardsTransactedVolumePerDay: String, voiceCallingByCountry: String, voiceCallingDailyActivity: String, voiceCallingDuration: String, voiceCallingVolume: String) {
        self.init(snapshot: ["__typename": "Reports", "usersEngagement": usersEngagement, "sudosIdentitiesCreated": sudosIdentitiesCreated, "totalSudosActive": totalSudosActive, "dailyPhoneNumbersCreated": dailyPhoneNumbersCreated, "messagesDailyActivity": messagesDailyActivity, "messagesVolume": messagesVolume, "messagesByCountry": messagesByCountry, "virtualCardsDailyProvisioned": virtualCardsDailyProvisioned, "virtualCardsTotalActiveCards": virtualCardsTotalActiveCards, "virtualCardsTransactedAmountPerDay": virtualCardsTransactedAmountPerDay, "virtualCardsTransactedVolumePerDay": virtualCardsTransactedVolumePerDay, "voiceCallingByCountry": voiceCallingByCountry, "voiceCallingDailyActivity": voiceCallingDailyActivity, "voiceCallingDuration": voiceCallingDuration, "voiceCallingVolume": voiceCallingVolume])
      }

      public var __typename: String {
        get {
          return snapshot["__typename"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "__typename")
        }
      }

      public var usersEngagement: String {
        get {
          return snapshot["usersEngagement"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "usersEngagement")
        }
      }

      public var sudosIdentitiesCreated: String {
        get {
          return snapshot["sudosIdentitiesCreated"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "sudosIdentitiesCreated")
        }
      }

      public var totalSudosActive: String {
        get {
          return snapshot["totalSudosActive"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "totalSudosActive")
        }
      }

      public var dailyPhoneNumbersCreated: String {
        get {
          return snapshot["dailyPhoneNumbersCreated"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "dailyPhoneNumbersCreated")
        }
      }

      public var messagesDailyActivity: String {
        get {
          return snapshot["messagesDailyActivity"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "messagesDailyActivity")
        }
      }

      public var messagesVolume: String {
        get {
          return snapshot["messagesVolume"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "messagesVolume")
        }
      }

      public var messagesByCountry: String {
        get {
          return snapshot["messagesByCountry"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "messagesByCountry")
        }
      }

      public var virtualCardsDailyProvisioned: String {
        get {
          return snapshot["virtualCardsDailyProvisioned"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "virtualCardsDailyProvisioned")
        }
      }

      public var virtualCardsTotalActiveCards: String {
        get {
          return snapshot["virtualCardsTotalActiveCards"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "virtualCardsTotalActiveCards")
        }
      }

      public var virtualCardsTransactedAmountPerDay: String {
        get {
          return snapshot["virtualCardsTransactedAmountPerDay"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "virtualCardsTransactedAmountPerDay")
        }
      }

      public var virtualCardsTransactedVolumePerDay: String {
        get {
          return snapshot["virtualCardsTransactedVolumePerDay"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "virtualCardsTransactedVolumePerDay")
        }
      }

      public var voiceCallingByCountry: String {
        get {
          return snapshot["voiceCallingByCountry"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "voiceCallingByCountry")
        }
      }

      public var voiceCallingDailyActivity: String {
        get {
          return snapshot["voiceCallingDailyActivity"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "voiceCallingDailyActivity")
        }
      }

      public var voiceCallingDuration: String {
        get {
          return snapshot["voiceCallingDuration"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "voiceCallingDuration")
        }
      }

      public var voiceCallingVolume: String {
        get {
          return snapshot["voiceCallingVolume"]! as! String
        }
        set {
          snapshot.updateValue(newValue, forKey: "voiceCallingVolume")
        }
      }
    }
  }
}
