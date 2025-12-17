//
//  OAuthFlowCoordinator.swift
//  Domain
//
//  Created by Wonji Suh  on 12/17/25.
//

import Foundation
import ComposableArchitecture
import LogMacro
import AuthenticationServices

public struct OAuthFlowUseCase {
    @Dependency(\.oAuthUseCase) private var oAuthUseCase: any OAuthUseCaseProtocol
    @Dependency(\.signUpUseCase) private var signUpUseCase
    @Dependency(\.authUseCase) private var authUseCase

    public init() {}
}


public extension OAuthFlowUseCase {
    struct FlowPayload {
        public let authData: AuthData
        public let immediateAuthResult: AuthResult?
    }

    // 단일 엔트리 포인트: 소셜 타입에 맞춰 전체 플로우 실행
    func process(
        socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> AuthFlowOutcome {
        Log.info("🔐 Orchestrator start: \(socialType.rawValue)")
        
        let authDataResult = await fetchOAuthPayload(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )
        
        guard case .success(let payload) = authDataResult else {
            if case .failure(let error) = authDataResult {
                return .failure(error)
            }
            return .failure(.unknownError("OAuth 데이터 획득 실패"))
        }
        
        // Kakao는 finalizeKakao까지 수행했으므로 바로 로그인 성공 처리
        if let immediate = payload.immediateAuthResult {
            return .loginSuccess(immediate)
        }
        
        // 가입 여부 확인
        let checkResult = await signUpUseCase.checkUser(payload.authData)
        guard case .success(let checkUser) = checkResult else {
            if case .failure(let error) = checkResult {
                return .failure(error)
            }
            return .failure(.unknownError("가입 여부 확인 실패"))
        }
        
        if checkUser.registered {
            let loginResult = await authUseCase.login(payload.authData)
            switch loginResult {
                case .success(let authResult):
                    return .loginSuccess(authResult)
                case .failure(let error):
                    return .failure(error)
            }
        }
        
        if checkUser.needsTerms {
            return .needsTermsAgreement(payload.authData)
        }
        
        let signUpResult = await signUpUseCase.signUp(payload.authData)
        switch signUpResult {
            case .success(let authResult):
                return .signUpSuccess(authResult)
            case .failure(let error):
                return .failure(error)
        }
    }

    // 개별 단계 노출 (UnifiedOAuthUseCase 등 파사드에서 재사용)
    func fetchOAuthPayload(
        socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> Result<FlowPayload, AuthError> {
        await fetchOAuthData(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )
    }

    func checkUserRegistrationStatus(with authData: AuthData) async -> Result<OAuthCheckUser, AuthError> {
        await signUpUseCase.checkUser(authData)
    }

    func login(with authData: AuthData) async -> Result<AuthResult, AuthError> {
        await authUseCase.login(authData)
    }

    func signUp(with authData: AuthData) async -> Result<AuthResult, AuthError> {
        await signUpUseCase.signUp(authData)
    }
}


private extension OAuthFlowUseCase {
    func fetchOAuthData(
        socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential?,
        nonce: String?
    ) async -> Result<FlowPayload, AuthError> {
        do {
            switch socialType {
                case .apple:
                    guard
                        let credential = appleCredential,
                        let nonce = nonce,
                        !nonce.isEmpty
                    else {
                        return .failure(.invalidCredential("Apple 자격정보가 없습니다"))
                    }
                    
                    let profile = try await oAuthUseCase.signInWithApple(
                        credential: credential,
                        nonce: nonce
                    )
                    
                    return .success(
                        FlowPayload(
                            authData: AuthData(
                                socialType: profile.provider,
                                accessToken: profile.tokens.accessToken,
                                authToken: profile.tokens.authToken,
                                displayName: profile.displayName,
                                authorizationCode: profile.authCode,
                                codeVerifier: nil,
                                redirectUri: nil,
                                refreshToken: profile.tokens.refreshToken,
                                sessionID: profile.tokens.sessionID,
                                userId: profile.id
                            ),
                            immediateAuthResult: nil
                        )
                    )
                    
                case .google:
                    let profile = try await oAuthUseCase.signUp(with: socialType)
                    return .success(
                        FlowPayload(
                            authData: AuthData(
                                socialType: profile.provider,
                                accessToken: profile.tokens.accessToken,
                                authToken: profile.tokens.authToken,
                                displayName: profile.displayName,
                                authorizationCode: profile.authCode,
                                codeVerifier: nil,
                                redirectUri: nil,
                                refreshToken: profile.tokens.refreshToken,
                                sessionID: profile.tokens.sessionID,
                                userId: profile.id
                            ),
                            immediateAuthResult: nil
                        )
                    )
                    
                case .kakao:
                    // Kakao는 ticket -> finalizeKakao를 통해 토큰 확보
                    let profile = try await oAuthUseCase.signUp(with: socialType)
                    guard let ticket = profile.authCode else {
                        return .failure(.invalidCredential("Kakao ticket이 없습니다"))
                    }
                    
                    let finalize = await signUpUseCase.finalizeKakao(ticket: ticket)
                    guard case .success(let finalized) = finalize else {
                        if case .failure(let error) = finalize {
                            return .failure(error)
                        }
                        return .failure(.unknownError("Kakao finalize 실패"))
                    }
                    
                    let accessToken = finalized.token.accessToken
                    return .success(
                        FlowPayload(
                            authData: AuthData(
                                socialType: profile.provider,
                                accessToken: accessToken,
                                authToken: accessToken,
                                displayName: finalized.name,
                                authorizationCode: ticket,
                                codeVerifier: profile.codeVerifier,
                                redirectUri: "https://sseudam.up.railway.app/api/v1/oauth/kakao/callback",
                                refreshToken: finalized.token.refreshToken,
                                sessionID: finalized.token.sessionID,
                                userId: finalized.userId
                            ),
                            immediateAuthResult: finalized
                        )
                    )
                    
                case .none:
                    return .failure(.invalidCredential("잘못된 소셜 타입"))
            }
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }
}


//MARK: - Dependency Registration
extension OAuthFlowUseCase: DependencyKey {
    public static var liveValue: OAuthFlowUseCase = OAuthFlowUseCase()
    public static var previewValue: OAuthFlowUseCase = OAuthFlowUseCase()
    public static var testValue: OAuthFlowUseCase = OAuthFlowUseCase()
}

public extension DependencyValues {
    var oAuthFlowUseCase: OAuthFlowUseCase {
        get { self[OAuthFlowUseCase.self] }
        set { self[OAuthFlowUseCase.self] = newValue }
    }
}
