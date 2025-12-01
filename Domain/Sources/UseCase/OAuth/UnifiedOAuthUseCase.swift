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
    private let oAuthUseCase: any OAuthUseCaseProtocol
    private let signUpRepository: any SignUpRepositoryProtocol
    private let loginRepository: any LoginRepositoryProtocol

    public init(
        oAuthUseCase: any OAuthUseCaseProtocol = OAuthUseCase.liveValue,
        signUpRepository: any SignUpRepositoryProtocol = MockSignUpRepository(),
        loginRepository: any LoginRepositoryProtocol = MockLoginRepository()
    ) {
        self.oAuthUseCase = oAuthUseCase
        self.signUpRepository = signUpRepository
        self.loginRepository = loginRepository
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

    func loginOrSignUp(
        with socialType: SocialType,
        appleCredential: ASAuthorizationAppleIDCredential? = nil,
        nonce: String? = nil
    ) async -> Result<AuthResult, AuthError> {
        Log.info("🔐 Starting unified OAuth flow for: \(socialType.rawValue)")

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
        let authResult = checkUser.registered
            ? await attemptLogin(with: authData)
            : await attemptSignUp(with: authData)

        // 4단계: 성공 시 토큰 저장 (회원가입은 attemptSignUp에서 이미 처리)
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
                    authorizationCode: profile.authCode ?? ""
                )


                return .success(oAuthData)

            case .google:
                let profile = try await oAuthUseCase.signUp(with: socialType)
                let oAuthData = AuthData(
                    socialType: profile.provider,
                    accessToken: profile.tokens.accessToken,
                    authToken: profile.tokens.authToken,
                    displayName: profile.displayName,
                    authorizationCode: profile.authCode ?? ""
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
            let input = OAuthUserInput(
                accessToken: oAuthData.authToken ,
                socialType: oAuthData.socialType,
                authorizationCode: oAuthData.authorizationCode
            )

            var authEntity = try await loginRepository.login(input: input)
            authEntity.token.authToken = oAuthData.authToken
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
            let checkInput = OAuthUserInput(
                accessToken: oAuthData.authToken,
                socialType: oAuthData.socialType,
                authorizationCode: oAuthData.authorizationCode
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
            let checkInput = OAuthUserInput(
                accessToken: oAuthData.authToken,
                socialType: oAuthData.socialType,
                authorizationCode: oAuthData.authorizationCode
            )
            var authEntity = try await signUpRepository.signUp(input: checkInput)
            authEntity.token.authToken = oAuthData.authToken
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
        loginRepository: MockLoginRepository()
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
