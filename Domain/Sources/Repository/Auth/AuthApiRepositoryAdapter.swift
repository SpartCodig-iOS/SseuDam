//
//  AuthRepositoryAdapter.swift
//  Domain
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation

/// 기존 Auth/Login/SignUp/Kakao finalize Repo를 하나로 묶는 어댑터
public struct AuthRepositoryAdapter: AuthRepositoryProtocol, @unchecked Sendable {
    private let authRepository: any AuthRepositoryProtocol
    private let loginRepository: any LoginRepositoryProtocol
    private let signUpRepository: any SignUpRepositoryProtocol
    private let kakaoFinalizeRepository: any KakaoFinalizeRepositoryProtocol

    public init(
        authRepository: any AuthRepositoryProtocol,
        loginRepository: any LoginRepositoryProtocol,
        signUpRepository: any SignUpRepositoryProtocol,
        kakaoFinalizeRepository: any KakaoFinalizeRepositoryProtocol
    ) {
        self.authRepository = authRepository
        self.loginRepository = loginRepository
        self.signUpRepository = signUpRepository
        self.kakaoFinalizeRepository = kakaoFinalizeRepository
    }

    public func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser {
        try await signUpRepository.checkSignUp(input: input)
    }

    public func login(input: OAuthUserInput) async throws -> AuthResult {
        try await loginRepository.login(input: input)
    }

    public func signUp(input: OAuthUserInput) async throws -> AuthResult {
        try await signUpRepository.signUp(input: input)
    }

    public func finalizeKakao(ticket: String) async throws -> AuthResult {
        try await kakaoFinalizeRepository.finalize(ticket: ticket)
    }

    public func refresh(token: String) async throws -> TokenResult {
        try await authRepository.refresh(token: token)
    }

    public func logout(sessionId: String) async throws -> LogoutStatus {
        try await authRepository.logout(sessionId: sessionId)
    }

    public func delete() async throws -> AuthDeleteStatus {
        try await authRepository.delete()
    }

    public func registerDeviceToken(token: String) async throws -> DeviceToken {
        try await authRepository.registerDeviceToken(token: token)
    }
}
