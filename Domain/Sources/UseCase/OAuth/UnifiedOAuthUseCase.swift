//
//  UnifiedOAuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh on 11/26/25.
//

import Foundation
import Dependencies
import LogMacro
import AuthenticationServices
import ComposableArchitecture

/// 통합 OAuth UseCase - 로그인/회원가입 플로우를 하나로 통합
public struct UnifiedOAuthUseCase {
    @Shared(.appStorage("socialType"))  var socialType: SocialType? = nil
    @Shared(.appStorage("userId")) var userId: String? = ""
  
    private let oAuthUseCase: any OAuthUseCaseProtocol
    private let signUpRepository: any SignUpRepositoryProtocol
    private let loginRepository: any LoginRepositoryProtocol
    private let kakaoFinalizeRepository: any KakaoFinalizeRepositoryProtocol

    public init(
        oAuthUseCase: any OAuthUseCaseProtocol = OAuthUseCase.liveValue,
        signUpRepository: any SignUpRepositoryProtocol = MockSignUpRepository(),
        loginRepository: any LoginRepositoryProtocol = MockLoginRepository(),
        kakaoFinalizeRepository: any KakaoFinalizeRepositoryProtocol = MockKakaoFinalizeRepository()
    ) {
        self.oAuthUseCase = oAuthUseCase
        self.signUpRepository = signUpRepository
        self.loginRepository = loginRepository
        self.kakaoFinalizeRepository = kakaoFinalizeRepository
    }
}

// MARK: - Public Interface

public extension UnifiedOAuthUseCase {

    /// OAuth Provider에서 토큰 획득 (Google/Apple SDK 호출)
    func socialLogin(
        with socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> Result<AuthData, AuthError> {
        return await getOAuthCredentials(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )
    }

    /// 회원가입 상태 확인
    func checkSignUpUser(
        with oAuthData: AuthData
    ) async -> Result<OAuthCheckUser, AuthError> {
        return await checkUserRegistrationStatus(with: oAuthData)
    }

    /// 로그인 처리
    func loginUser(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        let loginResult = await attemptLogin(with: oAuthData)

        if case .success(let authEntity) = loginResult {
            saveTokensAndComplete(authEntity: authEntity)
        }

        return loginResult
    }

    /// 회원가입 처리
    func signUpUser(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        return await attemptSignUp(with: oAuthData)
    }

    /// 약관 동의 후 회원가입 처리
    func signUpWithTermsAgreement(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        Log.info("✅ Terms agreement completed, proceeding with signup")
        return await attemptSignUp(with: oAuthData)
    }

    /// OAuth 플로우 처리 (AuthFlowOutcome 반환)
    func processOAuthFlow(
        with socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> AuthFlowOutcome {
        Log.info("🔐 Starting OAuth flow for: \(socialType.rawValue)")

        // 1단계: OAuth Provider 인증
        let oAuthData = await getOAuthCredentials(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )
        guard case .success(let authData) = oAuthData else {
            if case .failure(let error) = oAuthData {
                return .failure(error)
            } else {
                return .failure(.unknownError("OAuth 인증 실패"))
            }
        }

        // 2단계: 사용자 등록 상태 확인
        let registrationStatus = await checkUserRegistrationStatus(with: authData)
        guard case .success(let checkUser) = registrationStatus else {
            if case .failure(let error) = registrationStatus {
                return .failure(error)
            } else {
                return .failure(.unknownError("등록 상태 확인 실패"))
            }
        }

        // 3단계: 등록 여부에 따른 분기 처리
        if checkUser.registered {
            // 이미 등록된 사용자 -> 로그인 진행
            let loginResult = await attemptLogin(with: authData)
            switch loginResult {
            case .success(let authResult):
                saveTokensAndComplete(authEntity: authResult)
                return .loginSuccess(authResult)
            case .failure(let error):
                return .failure(error)
            }
        } else if checkUser.needsTerms {
            // 약관 동의 필요
            return .needsTermsAgreement(authData)
        } else {
            // 약관 동의 완료 -> 회원가입 진행
            let signUpResult = await attemptSignUp(with: authData)
            switch signUpResult {
            case .success(let authResult):
                return .signUpSuccess(authResult)
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func loginOrSignUp(
        with socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> Result<AuthResult, AuthError> {
        Log.info("🔐 Starting unified OAuth flow for: \(socialType.rawValue)")

        let oAuthData = await getOAuthCredentials(
            socialType: socialType,
            appleCredential: appleCredential,
            nonce: nonce
        )
        guard case .success(let authData) = oAuthData else {
            if case .failure(let error) = oAuthData {
                return .failure(error)
            } else {
                return .failure(.unknownError("OAuth 인증 실패"))
            }
        }

        let registrationStatus = await checkUserRegistrationStatus(with: authData)
        guard case .success(let checkUser) = registrationStatus else {
            if case .failure(let error) = registrationStatus {
                return .failure(error)
            } else {
                return .failure(.unknownError("등록 상태 확인 실패"))
            }
        }

        let authResult: Result<AuthResult, AuthError>

        if checkUser.registered {
            authResult = await attemptLogin(with: authData)
        } else {
            if checkUser.needsTerms {
                Log.info("📋 Terms agreement required for new user")
                return .failure(.needsTermsAgreement("약관 동의가 필요합니다"))
            } else {
                authResult = await attemptSignUp(with: authData)
            }
        }

        if case .success(let authEntity) = authResult, checkUser.registered {
            saveTokensAndComplete(authEntity: authEntity)
        }

        return authResult
    }
}

// MARK: - Private Methods

private extension UnifiedOAuthUseCase {

    /// OAuth Provider에서 인증 정보 획득
    func getOAuthCredentials(
        socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> Result<AuthData, AuthError> {
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

                let oAuthData = AuthData(
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
                )


                return .success(oAuthData)

            case .google:
                let profile = try await oAuthUseCase.signUp(with: socialType)
                let oAuthData = AuthData(
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
                )
                return .success(oAuthData)
            case .kakao:
                let profile = try await oAuthUseCase.signUp(with: socialType)
                guard let ticket = profile.authCode else {
                    return .failure(.invalidCredential("Kakao ticket이 없습니다"))
                }
                // 바로 finalize 호출하여 세션/토큰 확보
                let finalized = try await kakaoFinalizeRepository.finalize(ticket: ticket)
                let accessToken = finalized.token.authCodeTokenFallback
                let oAuthData = AuthData(
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
                )
                return .success(oAuthData)

            case .none:
                return .failure(.invalidCredential("잘못된 소셜 타입"))
            }
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }

    /// 로그인 시도
    func attemptLogin(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        do {
            if oAuthData.socialType == .kakao {
                let tokens = AuthTokens(
                    authToken: oAuthData.authToken,
                    accessToken: oAuthData.authToken,
                    refreshToken: oAuthData.refreshToken,
                    sessionID: oAuthData.sessionID ?? ""
                )
                let authEntity = AuthResult(
                    userId: oAuthData.userId ?? "kakao-user",
                    name: oAuthData.displayName ?? "",
                    provider: .kakao,
                    token: tokens
                )
                Log.info("✅ Kakao finalize-only login completed")
                return .success(authEntity)
            }

            let input = OAuthUserInput(
                accessToken: oAuthData.authToken ,
                socialType: oAuthData.socialType,
                authorizationCode: oAuthData.authorizationCode,
                codeVerifier: oAuthData.codeVerifier,
                redirectUri: oAuthData.redirectUri
            )

            var authEntity = try await loginRepository.login(input: input)
            authEntity.token.authToken = oAuthData.authToken
            persistSocialType(oAuthData.socialType)
            Log.info("✅ Login successful for \(oAuthData.socialType.rawValue)")
            return .success(authEntity)

        } catch {
            Log.info("⚠️ Login failed: \(error.localizedDescription)")
            return .failure(.networkError(error.localizedDescription))
        }
    }

    /// 회원가입 상태 확인
    func checkUserRegistrationStatus(
        with oAuthData: AuthData
    ) async -> Result<OAuthCheckUser, AuthError> {
        do {
            if oAuthData.socialType == .kakao {
                return .success(OAuthCheckUser(registered: true, needsTerms: false))
            }

            let checkInput = OAuthUserInput(
                accessToken: oAuthData.authToken,
                socialType: oAuthData.socialType,
                authorizationCode: oAuthData.authorizationCode,
                codeVerifier: oAuthData.codeVerifier,
                redirectUri: oAuthData.redirectUri
            )
            let result = try await signUpRepository.checkSignUp(input: checkInput)
            return .success(result)
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }

    /// 회원가입 시도
    func attemptSignUp(
        with oAuthData: AuthData
    ) async -> Result<AuthResult, AuthError> {
        do {
            if oAuthData.socialType == .kakao {
                let tokens = AuthTokens(
                    authToken: oAuthData.authToken,
                    accessToken: oAuthData.authToken,
                    refreshToken: oAuthData.refreshToken,
                    sessionID: oAuthData.sessionID ?? ""
                )
                let authEntity = AuthResult(
                  userId: oAuthData.userId ?? "kakao-user",
                    name: oAuthData.displayName ?? "",
                    provider: .kakao,
                    token: tokens
                )
                saveTokensAndComplete(authEntity: authEntity)
                return .success(authEntity)
            }

            let checkInput = OAuthUserInput(
                accessToken: oAuthData.authToken,
                socialType: oAuthData.socialType,
                authorizationCode: oAuthData.authorizationCode,
                codeVerifier: oAuthData.codeVerifier,
                redirectUri: oAuthData.redirectUri
            )
            var authEntity = try await signUpRepository.signUp(input: checkInput)
            authEntity.token.authToken = oAuthData.authToken
            persistSocialType(oAuthData.socialType)
            saveTokensAndComplete(authEntity: authEntity)
            return .success(authEntity)
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }

    /// 토큰 저장 및 로깅
    func saveTokensAndComplete(
        authEntity: AuthResult
    ) {
        // Keychain에 토큰 저장
        KeychainManager.shared.saveTokens(
            accessToken: authEntity.token.accessToken,
            refreshToken: authEntity.token.refreshToken
        )

        persistSocialType(authEntity.provider)

        self.$userId.withLock { $0 = authEntity.userId }
        // 완료 로깅 (저장 확인을 위한 불필요한 재로드 제거)
        Log.info("💾 Tokens saved to Keychain successfully")
        Log.info("🎉 OAuth flow completed for \(authEntity.provider.rawValue)")
    }
}



// MARK: - Dependencies Registration

extension UnifiedOAuthUseCase: DependencyKey {
    public static let liveValue = UnifiedOAuthUseCase()

    public static let testValue = UnifiedOAuthUseCase(
        oAuthUseCase: OAuthUseCase.testValue,
        signUpRepository: MockSignUpRepository(),
        loginRepository: MockLoginRepository(),
        kakaoFinalizeRepository: MockKakaoFinalizeRepository()
    )
}

private extension UnifiedOAuthUseCase {
    func persistSocialType(_ socialType: SocialType) {
      $socialType.withLock { $0 = socialType }
    }
}

extension DependencyValues {
    public var unifiedOAuthUseCase: UnifiedOAuthUseCase {
        get { self[UnifiedOAuthUseCase.self] }
        set { self[UnifiedOAuthUseCase.self] = newValue }
    }
}
