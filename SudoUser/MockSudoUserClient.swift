//
// Copyright © 2020 Anonyome Labs, Inc. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import SudoKeyManager

// Mock implementation of `SudoUserClient` protocol used for unit testing.
open class MockSudoUserClient: SudoUserClient {

    public var version: String = "1.0"

    public init() {}

    public var isRegisteredCalled: Bool = false
    public var isRegisteredReturn: Bool = true

    open func isRegistered() -> Bool {
        self.isRegisteredCalled = true
        return self.isRegisteredReturn
    }

    public var getSymmetricKeyIdCalled: Bool = false
    public var getSymmetricKeyIdReturn: String = ""
    public var getSymmetricKeyIdError: Error?

    open func getSymmetricKeyId() throws -> String {
        self.getSymmetricKeyIdCalled = true

        if let error = self.getSymmetricKeyIdError {
            throw error
        }

        return self.getSymmetricKeyIdReturn
    }

    public var resetCalled: Bool = false
    public var resetError: Error?

    open func reset() throws {
        self.resetCalled = true

        if let error = self.resetError {
            throw error
        }
    }

    public var getDeviceCheckChallengeCalled: Bool = false
    public var getDeviceCheckChallengeResult: GetRegistrationChallengesResult = .success(challenges: [])
    public var getDeviceCheckChallengeError: Error?
    public var getDeviceCheckChallengeParamDeviceToken: Data?
    public var getDeviceCheckChallengeParamBuildType: String?

    open func getDeviceCheckChallenge(deviceToken: Data, buildType: String, completion: @escaping (GetRegistrationChallengesResult) -> Void) throws {
        self.getDeviceCheckChallengeCalled = true
        self.getDeviceCheckChallengeParamDeviceToken = deviceToken
        self.getDeviceCheckChallengeParamBuildType = buildType

        if let error = self.getDeviceCheckChallengeError {
            throw error
        }

        completion(self.getDeviceCheckChallengeResult)
    }

    public var registerCalled: Bool = false
    public var registerResult: RegisterResult = .success(uid: "")
    public var registerError: Error?
    public var registerParamChallenge: RegistrationChallenge?
    public var registerParamVendorId: UUID?
    public var registerParamRegistrationId: String?

    open func register(challenge: RegistrationChallenge, vendorId: UUID?, registrationId: String?, completion: @escaping (RegisterResult) -> Void) throws {
        self.registerCalled = true
        self.registerParamChallenge = challenge
        self.registerParamVendorId = vendorId
        self.registerParamRegistrationId = registrationId

        if let error = self.registerError {
            throw error
        }

        completion(self.registerResult)
    }

    public var registerWithDeviceCheckCalled: Bool = false
    public var registerWithDeviceCheckResult: RegisterResult = .success(uid: "")
    public var registerWithDeviceCheckError: Error?
    public var registerWithDeviceCheckParamToken: Data?
    public var registerWithDeviceCheckParamBuildType: String?
    public var registerWithDeviceCheckParamVendorId: UUID?
    public var registerWithDeviceCheckParamRegistrationId: String?

    open func registerWithDeviceCheck(token: Data, buildType: String, vendorId: UUID?, registrationId: String?, completion: @escaping (RegisterResult) -> Void) throws {
        self.registerWithDeviceCheckCalled = true
        self.registerWithDeviceCheckParamBuildType = buildType
        self.registerWithDeviceCheckParamToken = token
        self.registerWithDeviceCheckParamVendorId = vendorId
        self.registerWithDeviceCheckParamRegistrationId = registrationId

        if let error = self.registerWithDeviceCheckError {
            throw error
        }

        completion(self.registerWithDeviceCheckResult)
    }

    public var registerWithAuthenticationProviderCalled: Bool = false
    public var registerWithAuthenticationProviderResult: RegisterResult = .success(uid: "")
    public var registerWithAuthenticationProviderError: Error?
    public var registerWithAuthenticationProviderParamAuthenticationProvider: AuthenticationProvider?
    public var registerWithAuthenticationProviderParamRegistrationId: String?

    open func registerWithAuthenticationProvider(authenticationProvider: AuthenticationProvider, registrationId: String?, completion: @escaping (RegisterResult) -> Void) throws {
        self.registerWithAuthenticationProviderCalled = true
        self.registerWithAuthenticationProviderParamAuthenticationProvider = authenticationProvider
        self.registerWithAuthenticationProviderParamRegistrationId = registrationId

        if let error = self.registerWithAuthenticationProviderError {
            throw error
        }

        completion(self.registerWithAuthenticationProviderResult)
    }

    public var deregisterCalled: Bool = false
    public var deregisterResult: DeregisterResult = .success(uid: "")

    open func deregister(completion: @escaping (DeregisterResult) -> Void) {
        self.deregisterCalled = true
        completion(self.deregisterResult)
    }

    public var signInWithKeyCalled: Bool = false
    public var signInWithKeyResult: SignInResult = .success(tokens: AuthenticationTokens(idToken: "", accessToken: "", refreshToken: "", lifetime: 0))
    public var signInWithKeyError: Error?

    open func signInWithKey(completion: @escaping (SignInResult) -> Void) throws {
        self.signInWithKeyCalled = true

        if let error = self.signInWithKeyError {
            throw error
        }

        completion(self.signInWithKeyResult)
    }

    public var refreshTokensCalled: Bool = false
    public var refreshTokensResult: SignInResult = .success(tokens: AuthenticationTokens(idToken: "", accessToken: "", refreshToken: "", lifetime: 0))
    public var refreshTokensError: Error?
    public var refreshTokensParamRefreshToken: String?

    open func refreshTokens(refreshToken: String, completion: @escaping (SignInResult) -> Void) throws {
        self.refreshTokensCalled = true
        self.refreshTokensParamRefreshToken = refreshToken

        if let error = self.refreshTokensError {
            throw error
        }

        completion(self.refreshTokensResult)
    }

    public var getUserNameCalled: Bool = false
    public var getUserNameReturn: String?
    public var getUserNameError: Error?

    open func getUserName() throws -> String? {
        self.getUserNameCalled = true

        if let error = self.getUserNameError {
            throw error
        }

        return self.getUserNameReturn
    }

    public var getIdTokenCalled: Bool = false
    public var getIdTokenReturn: String?
    public var getIdTokenError: Error?

    open func getIdToken() throws -> String? {
        self.getIdTokenCalled = true

        if let error = self.getIdTokenError {
            throw error
        }

        return self.getIdTokenReturn
    }

    public var getAccessTokenCalled: Bool = false
    public var getAccessTokenReturn: String?
    public var getAccessTokenError: Error?

    open func getAccessToken() throws -> String? {
        self.getAccessTokenCalled = true

        if let error = self.getAccessTokenError {
            throw error
        }

        return self.getAccessTokenReturn
    }

    public var getRefreshTokenCalled: Bool = false
    public var getRefreshTokenReturn: String?
    public var getRefreshTokenError: Error?

    open func getRefreshToken() throws -> String? {
        self.getRefreshTokenCalled = true

        if let error = self.getRefreshTokenError {
            throw error
        }

        return self.getRefreshTokenReturn
    }

    public var getTokenExpiryCalled: Bool = false
    public var getTokenExpiryReturn: Date?
    public var getTokenExpiryError: Error?

    open func getTokenExpiry() throws -> Date? {
        self.getTokenExpiryCalled = true

        if let error = self.getTokenExpiryError {
            throw error
        }

        return self.getTokenExpiryReturn
    }

    public var getRefreshTokenExpiryCalled: Bool = false
    public var getRefreshTokenExpiryReturn: Date?
    public var getRefreshTokenExpiryError: Error?

    open func getRefreshTokenExpiry() throws -> Date? {
        self.getRefreshTokenExpiryCalled = true

        if let error = self.getRefreshTokenExpiryError {
            throw error
        }

        return self.getRefreshTokenExpiryReturn
    }

    public var encryptCalled: Bool = false
    public var encryptReturn = Data()
    public var encryptError: Error?
    public var encryptParamKeyId: String?
    public var encryptParamAlgorithm: SymmetricKeyEncryptionAlgorithm?
    public var encryptParamData: Data?

    open func encrypt(keyId: String, algorithm: SymmetricKeyEncryptionAlgorithm, data: Data) throws -> Data {
        self.encryptCalled = true
        self.encryptParamKeyId = keyId
        self.encryptParamAlgorithm = algorithm
        self.encryptParamData = data

        if let error = self.encryptError {
            throw error
        }

        return self.encryptReturn
    }

    public var decryptCalled: Bool = false
    public var decryptReturn = Data()
    public var decryptError: Error?
    public var decryptParamKeyId: String?
    public var decryptParamAlgorithm: SymmetricKeyEncryptionAlgorithm?
    public var decryptParamData: Data?

    open func decrypt(keyId: String, algorithm: SymmetricKeyEncryptionAlgorithm, data: Data) throws -> Data {
        self.decryptCalled = true
        self.decryptParamKeyId = keyId
        self.decryptParamAlgorithm = algorithm
        self.decryptParamData = data

        if let error = self.decryptError {
            throw error
        }

        return self.decryptReturn
    }

    public var presentFederatedSignInUICalled: Bool = false
    public var presentFederatedSignInUIError: Error?
    public var presentFederatedSignInUIResult: SignInResult = .success(tokens: AuthenticationTokens(idToken: "", accessToken: "", refreshToken: "", lifetime: 0))

    open func presentFederatedSignInUI(navigationController: UINavigationController, completion: @escaping (SignInResult) -> Void) throws {
        self.presentFederatedSignInUICalled = true

        if let error = self.presentFederatedSignInUIError {
            throw error
        }

        completion(self.presentFederatedSignInUIResult)
    }

    public var presentFederatedSignOutUICalled: Bool = false
    public var presentFederatedSignOutUIError: Error?
    public var presentFederatedSignOutUIResult: ApiResult = .success

    open func presentFederatedSignOutUI(navigationController: UINavigationController, completion: @escaping (ApiResult) -> Void) throws {
        self.presentFederatedSignOutUICalled = true

        if let error = self.presentFederatedSignOutUIError {
            throw error
        }

        completion(self.presentFederatedSignOutUIResult)
    }

    public var processFederatedSignInTokensCalled: Bool = false
    public var processFederatedSignInTokensError: Error?
    public var processFederatedSignInTokenstParamUrl: URL?

    public func processFederatedSignInTokens(url: URL) throws {
        self.processFederatedSignInTokensCalled = true
        self.processFederatedSignInTokenstParamUrl = url

        if let error = self.processFederatedSignInTokensError {
            throw error
        }
    }

    public var clearAuthTokensCalled: Bool = false
    public var clearAuthTokensError: Error?

    open func clearAuthTokens() throws {
        self.clearAuthTokensCalled = true

        if let error = self.clearAuthTokensError {
            throw error
        }
    }

    public var globalSignOutCalled: Bool = false
    public var globalSignOutError: Error?
    public var globalSignOutResult: ApiResult = .success

    open func globalSignOut(completion: @escaping (ApiResult) -> Void) throws {
        self.globalSignOutCalled = true

        if let error = self.globalSignOutError {
            throw error
        }

        completion(self.globalSignOutResult)
    }

    public var getIdentityIdCalled: Bool = false
    public var getIdentityIdReturn = "dummy_id"

    open func getIdentityId() -> String? {
        self.getIdentityIdCalled = true

        return getIdentityIdReturn
    }

    public var getSubjectCalled: Bool = false
    public var getSubjectReturn: String?
    public var getSubjectError: Error?

    open func getSubject() throws -> String? {
        self.getSubjectCalled = true

        if let error = self.getSubjectError {
            throw error
        }

        return self.getSubjectReturn
    }

    public var getUserClaimReturn: Any?

    open func getUserClaim(name: String) throws -> Any? {
        return self.getUserClaimReturn
    }

    public var storeTokensCalled: Bool = false
    public var storeTokensError: Error?
    public var storeTokensParamTokens: AuthenticationTokens?

    open func storeTokens(tokens: AuthenticationTokens) throws {
        self.storeTokensCalled = true
        self.storeTokensParamTokens = tokens

        if let error = self.storeTokensError {
            throw error
        }
    }

    public var isSignedInCalled: Bool = false
    public var isSignedInReturn: Bool = false
    public var isSignedInError: Error?

    open func isSignedIn() throws -> Bool {
        self.isSignedInCalled = true

        if let error = self.isSignedInError {
            throw error
        }

        return isSignedInReturn
    }

    public var isGetSupportedRegistrationChallengeTypeCalled: Bool = false
    public var isGetSupportedRegistrationChallengeTypeReturn: [ChallengeType]  = []

    public func getSupportedRegistrationChallengeType() -> [ChallengeType] {
        self.isGetSupportedRegistrationChallengeTypeCalled = true
        return isGetSupportedRegistrationChallengeTypeReturn
    }

    public var registerSignInObserverCalled: Bool = false
    public var registerSignInObserverParamId: String = ""
    public var registerSignInObserverParamObserver: SignInStatusObserver?

    open func registerSignInStatusObserver(id: String, observer: SignInStatusObserver) {
        self.registerSignInObserverCalled = true
        self.registerSignInObserverParamId = id
        self.registerSignInObserverParamObserver = observer
    }

    public var deregisterSignInObserverCalled: Bool = false
    public var deregisterSignInObserverParamId: String = ""

    open func deregisterSignInStatusObserver(id: String) {
        self.deregisterSignInObserverCalled = true
        self.deregisterSignInObserverParamId = id
    }

    public var signInWithAuthenticationProviderCalled: Bool = false
    public var signInWithAuthenticationProviderResult: SignInResult = .success(tokens: AuthenticationTokens(idToken: "", accessToken: "", refreshToken: "", lifetime: 0))
    public var signInWithAuthenticationProviderError: Error?
    public var signInWithAuthenticationProviderParamAuthenticationProvider: AuthenticationProvider?

    open func signInWithAuthenticationProvider(authenticationProvider: AuthenticationProvider, completion: @escaping (SignInResult) -> Void) throws {
        self.signInWithAuthenticationProviderCalled = true
        self.signInWithAuthenticationProviderParamAuthenticationProvider = authenticationProvider

        if let error = self.signInWithAuthenticationProviderError {
            throw error
        }

        completion(self.signInWithAuthenticationProviderResult)
    }

}
