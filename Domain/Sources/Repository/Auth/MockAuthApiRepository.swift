//
//  MockAuthCompositeRepository.swift
//  Domain
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation

public struct MockAuthCompositeRepository: AuthRepositoryProtocol, @unchecked Sendable {
    public var checkUserResult: OAuthCheckUser = .init(registered: true, needsTerms: false)
    public var loginResult: AuthResult = AuthResult.mock
    public var signUpResult: AuthResult = AuthResult.mock
    public var kakaoFinalizeResult: AuthResult = AuthResult.mock
    public var tokenResult: TokenResult = TokenResult(token: AuthTokens.mock)
    public var logoutStatus: LogoutStatus = LogoutStatus(revoked: true)
    public var deleteStatus: AuthDeleteStatus = AuthDeleteStatus(isDeleted: true)
    public var deviceToken: DeviceToken = DeviceToken(deviceToken: "mock_device_token", pendingKey: "mock_pending")

    public init() {}

    public func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser { checkUserResult }
    public func login(input: OAuthUserInput) async throws -> AuthResult { loginResult }
    public func signUp(input: OAuthUserInput) async throws -> AuthResult { signUpResult }
    public func finalizeKakao(ticket: String) async throws -> AuthResult { kakaoFinalizeResult }
    public func refresh(token: String) async throws -> TokenResult { tokenResult }
    public func logout(sessionId: String) async throws -> LogoutStatus { logoutStatus }
    public func delete() async throws -> AuthDeleteStatus { deleteStatus }
    public func registerDeviceToken(token: String) async throws -> DeviceToken { deviceToken }
}

private extension AuthTokens {
    static var mock: AuthTokens {
        AuthTokens(
            authToken: "mock_auth",
            accessToken: "mock_access",
            refreshToken: "mock_refresh",
            sessionID: "mock_session"
        )
    }
}

private extension AuthResult {
    static var mock: AuthResult {
        AuthResult(
            userId: "mock_user",
            name: "Mock User",
            provider: .google,
            token: .mock
        )
    }
}

// Kakao finalize는 AuthResult를 그대로 사용
