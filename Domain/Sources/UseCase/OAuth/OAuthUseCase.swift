//
//  OAuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies
import LogMacro
import AuthenticationServices

public struct OAuthUseCase: OAuthUseCaseProtocol {

    @Dependency(\.oAuthRepository) private var repository: OAuthRepositoryProtocol
    @Dependency(\.googleOAuthRepository) private var googleRepository: GoogleOAuthRepositoryProtocol
    @Dependency(\.appleOAuthRepository) private var appleRepository: AppleOAuthRepositoryProtocol
    @Dependency(\.kakaoOAuthRepository) private var kakaoRepository: KakaoOAuthRepositoryProtocol

    // ✅ Provider들도 DI로 주입받음
    @Dependency(\.appleOAuthProvider) private var appleProvider: AppleOAuthProviderProtocol
    @Dependency(\.googleOAuthProvider) private var googleProvider: GoogleOAuthProviderProtocol

    public init() {}


    public func signInWithApple(
        credential: ASAuthorizationAppleIDCredential,
        nonce: String
    ) async throws -> UserProfile {
        return try await appleProvider.signInWithCredential(
            credential: credential,
            nonce: nonce
        )
    }


    public func signUp(
        with provider: SocialType
    ) async throws -> UserProfile {
        Log.info("🔥 OAuthUseCase.signUp called with provider: \(provider.rawValue)")

        do {
            switch provider {
            case .apple:
                let result = try await appleProvider.signUp()
                Log.info("✅ Apple signUp completed successfully")
                return result
            case .google:
                let result = try await googleProvider.signUp()
                Log.info("✅ Google signUp completed successfully")
                return result
            case .kakao:
                let kakaoProvider = KakaoOAuthProvider()
                let result = try await kakaoProvider.signUp(kakaoRepository: kakaoRepository)
                Log.info("✅ Kakao signUp completed successfully")
                return result
            case .none:
                Log.error("❌ Invalid provider: none")
                throw AuthError.configurationMissing
            }
        } catch {
            Log.error("💥 OAuthUseCase.signUp failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Dependencies
extension OAuthUseCase: DependencyKey {
    public static var liveValue:  OAuthUseCaseProtocol = OAuthUseCase()
    public static var previewValue:  OAuthUseCaseProtocol = OAuthUseCase()
    public static var testValue:  OAuthUseCaseProtocol = OAuthUseCase()
}

public extension DependencyValues {
    var oAuthUseCase:  OAuthUseCaseProtocol {
        get { self[OAuthUseCase.self] }
        set { self[OAuthUseCase.self] = newValue }
    }
}
