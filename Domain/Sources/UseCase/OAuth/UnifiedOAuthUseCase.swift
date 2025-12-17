//
//  UnifiedOAuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh on 11/26/25.
//

import Foundation
import Dependencies
import AuthenticationServices

/// 통합 OAuth UseCase - 로그인/회원가입 플로우를 하나로 통합 (AuthFacade 역할)
public struct UnifiedOAuthUseCase {
    @Dependency(\.oAuthFlowUseCase) private var oAuthFlow: OAuthFlowUseCase
    
    public init() {}
}

// MARK: - Public Interface

public extension UnifiedOAuthUseCase {
    
    /// OAuth Provider에서 토큰 획득 (Google/Apple SDK 호출)
    func socialLogin(
        with socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> Result<AuthData, AuthError> {
        let payload = await oAuthFlow.fetchOAuthPayload(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )
        return payload.map(\.authData)
    }
    
    /// 회원가입 상태 확인
    func checkSignUpUser(
        with oAuthData: AuthData
    ) async -> Result<OAuthCheckUser, AuthError> {
        await oAuthFlow.checkUserRegistrationStatus(with: oAuthData)
    }
    
    /// 로그인 처리
    func loginUser(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        await oAuthFlow.login(with: oAuthData)
    }
    
    /// 회원가입 처리
    func signUpUser(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        await oAuthFlow.signUp(with: oAuthData)
    }
    
    /// 약관 동의 후 회원가입 처리
    func signUpWithTermsAgreement(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        await oAuthFlow.signUp(with: oAuthData)
    }
    
    /// OAuth 플로우 처리 (AuthFlowOutcome 반환)
    func processOAuthFlow(
        with socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> AuthFlowOutcome {
        return await oAuthFlow.process(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )
    }
    
    func loginOrSignUp(
        with socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> Result<AuthResult, AuthError> {
        let outcome = await oAuthFlow.process(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )

        switch outcome {
        case .loginSuccess(let auth):
            return .success(auth)
        case .signUpSuccess(let auth):
            return .success(auth)
        case .needsTermsAgreement:
            return .failure(.needsTermsAgreement("약관 동의가 필요합니다"))
        case .failure(let error):
            return .failure(error)
        }
    }
}

// MARK: - Dependencies Registration

extension UnifiedOAuthUseCase: DependencyKey {
    public static let liveValue = UnifiedOAuthUseCase()
    public static let testValue = UnifiedOAuthUseCase()
}

extension DependencyValues {
    public var unifiedOAuthUseCase: UnifiedOAuthUseCase {
        get { self[UnifiedOAuthUseCase.self] }
        set { self[UnifiedOAuthUseCase.self] = newValue }
    }
}
