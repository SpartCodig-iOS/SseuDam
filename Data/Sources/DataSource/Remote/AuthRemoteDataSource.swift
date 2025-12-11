//
//  AuthRemoteDataSource.swift
//  Data
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation
@preconcurrency import Moya
import Domain
import NetworkService

public protocol AuthRemoteDataSourceProtocol: Sendable {
    func refresh(token: String) async throws -> TokenResult
    func logout(sessionId: String) async throws -> LogoutStatus
    func delete() async throws -> AuthDeleteStatus
    func registerDeviceToken(token: String) async throws -> DeviceToken
    func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser
    func login(input: OAuthUserInput) async throws -> AuthResult
    func signUp(input: OAuthUserInput) async throws -> AuthResult
    func finalizeKakao(ticket: String) async throws -> AuthResult
}

public struct AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    private let authProvider: MoyaProvider<AuthAPITarget>
    private let oauthProvider: MoyaProvider<OAuthAPITarget>

    public init(
        authProvider: MoyaProvider<AuthAPITarget> = .authorized,
        oauthProvider: MoyaProvider<OAuthAPITarget> = .default
    ) {
        self.authProvider = authProvider
        self.oauthProvider = oauthProvider
    }

    public func refresh(token: String) async throws -> TokenResult {
        let body = RefreshRequestDTO(refreshToken: token)
        let response: BaseResponse<RefreshResponseDTO> = try await authProvider.request(.refreshToken(body: body))
        guard let data = response.data else { throw NetworkError.noData }
        return data.toDomain()
    }

    public func logout(sessionId: String) async throws -> LogoutStatus {
        let body = SessionRequestDTO(sessionId: sessionId)
        let response: BaseResponse<LogoutResponseDTO> = try await authProvider.request(.logout(body: body))
        guard let data = response.data else { throw NetworkError.noData }
        return data.toDomain()
    }

    public func delete() async throws -> AuthDeleteStatus {
        let response: BaseResponse<AuthDeleteResponseDTO> = try await authProvider.request(.deleteAccount)
        guard let data = response.data else { throw NetworkError.noData }
        return data.toDomain()
    }

    public func registerDeviceToken(token: String) async throws -> DeviceToken {
        let pendingKey = getOrCreatePendingKey()
        let body = DeviceTokenRequestDTO(deviceToken: token, pendingKey: pendingKey)
        let response: BaseResponse<DeviceTokenResponseDTO> = try await authProvider.request(.registerDeviceToken(body: body))
        guard let data = response.data else { throw NetworkError.noData }
        if let returnedKey = data.pendingKey { persistPendingKey(returnedKey) }
        return data.toDomain()
    }

    public func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser {
        let body = LoginUserRequestDTO(
            accessToken: input.accessToken,
            loginType: input.socialType.rawValue,
            authorizationCode: input.authorizationCode,
            codeVerifier: input.codeVerifier,
            redirectUri: input.redirectUri,
            deviceToken: loadDeviceToken()
        )
        let response: BaseResponse<ChecSignUpResponseDTO> = try await oauthProvider.request(.checkSignUpUser(body: body))
        guard let data = response.data else { throw NetworkError.noData }
        return data.toDomain()
    }

    public func login(input: OAuthUserInput) async throws -> AuthResult {
        let body = LoginUserRequestDTO(
            accessToken: input.accessToken,
            loginType: input.socialType.rawValue,
            authorizationCode: input.authorizationCode,
            codeVerifier: input.codeVerifier,
            redirectUri: input.redirectUri,
            deviceToken: loadDeviceToken()
        )
        let response: BaseResponse<AuthResponseDTO> = try await oauthProvider.request(.loginOAuth(body: body))
        guard let data = response.data else { throw NetworkError.noData }
        return data.toDomain()
    }

    public func signUp(input: OAuthUserInput) async throws -> AuthResult {
        let body = SignUpUserRequestDTO(
            accessToken: input.accessToken,
            loginType: input.socialType.rawValue,
            authorizationCode: input.authorizationCode,
            codeVerifier: input.codeVerifier,
            redirectUri: input.redirectUri,
            deviceToken: loadDeviceToken()
        )
        let response: BaseResponse<AuthResponseDTO> = try await oauthProvider.request(.signUpOAuth(body: body))
        guard let data = response.data else { throw NetworkError.noData }
        return data.toDomain()
    }

    public func finalizeKakao(ticket: String) async throws -> AuthResult {
        let body = KakaoFinalizeRequestDTO(ticket: ticket)
        let response: BaseResponse<AuthResponseDTO> = try await oauthProvider.request(.kakaoFinalize(body: body))
        guard let data = response.data else { throw NetworkError.noData }
        return data.toDomain()
    }
}

// MARK: - Helpers
private extension AuthRemoteDataSource {
    func loadDeviceToken() -> String? {
        UserDefaults.standard.string(forKey: "Token")
    }

    func getOrCreatePendingKey() -> String {
        let key = "auth.pendingKey"
        if let saved = UserDefaults.standard.string(forKey: key) {
            return saved
        }
        let newKey = UUID().uuidString
        UserDefaults.standard.set(newKey, forKey: key)
        return newKey
    }

    func persistPendingKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "auth.pendingKey")
    }
}
