//
//  OAuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import ComposableArchitecture
import LogMacro
import AuthenticationServices

public struct OAuthUseCase: OAuthUseCaseProtocol {
  private let repository: OAuthRepositoryProtocol
  private let googleRepository: GoogleOAuthRepositoryProtocol
  private let appleRepository: AppleOAuthRepositoryProtocol
  private let kakaoRepository: KakaoOAuthRepositoryProtocol

  public init(
    repository: OAuthRepositoryProtocol,
    googleRepository: GoogleOAuthRepositoryProtocol,
    appleRepository: AppleOAuthRepositoryProtocol,
    kakaoRepository: KakaoOAuthRepositoryProtocol
  ) {
    self.repository = repository
    self.googleRepository = googleRepository
    self.appleRepository = appleRepository
    self.kakaoRepository = kakaoRepository
  }

  public func signInWithApple(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserProfile {
    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8),
          let authCode = String(data: credential.authorizationCode ?? Data(), encoding: .utf8)
    else {
      throw AuthError.missingIDToken
    }

    let displayName = formatDisplayName(credential.fullName)
    Log.info("Apple sign-in credential received for \(displayName ?? "unknown user")")

    let profile = try await repository.signIn(
      provider: .apple,
      idToken: identityToken,
      nonce: nonce,
      displayName: displayName,
      authorizationCode: authCode
    )
    Log.info("Supabase sign-in with Apple succeeded")
    return profile
  }

  // MARK: - Helper Methods
  private func formatDisplayName(
    _ components: PersonNameComponents?
  ) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }

    public func signUp(
      with provider: SocialType
    ) async throws -> UserProfile {
        // Kakao는 Supabase OAuth를 거치지 않고 Kakao SDK 토큰을 그대로 사용
        if provider == .kakao {
            let kakaoPayload = try await kakaoRepository.signIn()
            let tokens = AuthTokens(
              authToken: kakaoPayload.authorizationCode ?? "",
              accessToken: kakaoPayload.accessToken,
              refreshToken: kakaoPayload.refreshToken ?? "",
              sessionID: ""
            )
            return UserProfile(
              id: kakaoPayload.authorizationCode ?? UUID().uuidString,
              email: nil,
              displayName: kakaoPayload.displayName,
              provider: .kakao,
              tokens: tokens,
              authCode: kakaoPayload.authorizationCode,
              codeVerifier: kakaoPayload.codeVerifier
            )
        }

    let payload = try await fetchPayload(for: provider)
    Log.info("\(provider.rawValue) sign-in succeeded for \(payload.displayName ?? "unknown user")")

    let profile = try await repository.signIn(
      provider: payload.provider,
      idToken: payload.idToken,
      nonce: payload.nonce,
      displayName: payload.displayName,
      authorizationCode: payload.authorizationCode
    )
    Log.info("Supabase sign-in with \(provider.rawValue) succeeded")

    return profile
  }

  private func fetchPayload(
    for provider: SocialType
  ) async throws -> OAuthSignInPayload {
    switch provider {
      case .apple:
        let payload = try await appleRepository.signIn()
        return OAuthSignInPayload(
          provider: .apple,
          idToken: payload.idToken,
          nonce: payload.nonce,
          displayName: payload.displayName,
          authorizationCode: payload.authorizationCode
        )
      case .google:
        let payload = try await googleRepository.signIn()
        return OAuthSignInPayload(
          provider: .google,
          idToken: payload.idToken,
          nonce: nil,
          displayName: payload.displayName,
          authorizationCode: payload.authorizationCode
        )
      case .kakao:
        // Kakao는 SDK 토큰을 바로 사용하므로 여기서는 빈 페이로드 반환
        return OAuthSignInPayload(
          provider: .kakao,
          idToken: "",
          nonce: nil,
          displayName: nil,
          authorizationCode: nil
        )
      case .none:
        throw AuthError.configurationMissing
    }
  }
}

// MARK: - Dependencies
extension OAuthUseCase: DependencyKey {
  public static var liveValue:  OAuthUseCaseProtocol = {
    return OAuthUseCase(
      repository: MockOAuthRepository(),
      googleRepository: MockGoogleOAuthRepository(),
      appleRepository: MockAppleOAuthRepository(),
      kakaoRepository: MockKakaoOAuthRepository()
    )
  }()
  public static var previewValue:  OAuthUseCaseProtocol = liveValue
  public static var testValue:  OAuthUseCaseProtocol = {
    return OAuthUseCase(
      repository: MockOAuthRepository(),
      googleRepository: MockGoogleOAuthRepository(),
      appleRepository: MockAppleOAuthRepository(),
      kakaoRepository: MockKakaoOAuthRepository()
    )
  }()
}

public extension DependencyValues {
  var oAuthUseCase:  OAuthUseCaseProtocol {
    get { self[OAuthUseCase.self] }
    set { self[OAuthUseCase.self] = newValue }
  }
}
