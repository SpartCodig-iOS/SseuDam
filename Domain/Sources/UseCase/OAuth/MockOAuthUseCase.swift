//
//  MockOAuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/18/25.
//

import Foundation
import Dependencies
import LogMacro
import AuthenticationServices

public struct MockOAuthUseCase: OAuthUseCaseProtocol {
  public func signInWithApple(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserEntity {
    // Mock implementation for testing/preview
    return UserEntity(
      id: "mock-apple-user-id",
      email: "apple.user@example.com",
      displayName: "Mock Apple User",
      provider: .apple,
      tokens: .init(
        authToken: "mock-superbase-token",
        accessToken: "mock-access-token",
        refreshToken: "mock-refresh-token",
        sessionID: "mock-sessionID"
      ),
      authCode: "mock-auth-code"
    )
  }

  public func signUp(with provider: SocialType) async throws -> UserEntity {
    switch provider {
      case .apple:
        return makeUser(provider: .apple)
      case .google:
        return makeUser(provider: .google)
      case .none:
        throw AuthError.configurationMissing
    }
  }

  private func makeUser(provider: SocialType) -> UserEntity {
    return UserEntity(
      id: "mock-\(provider.rawValue)-user-id",
      email: "\(provider.rawValue).user@example.com",
      displayName: "Mock \(provider.rawValue.capitalized) User",
      provider: provider,
      tokens: .init(
        authToken: "mock-\(provider.rawValue)-superbase-token",
        accessToken: "mock-\(provider.rawValue)-access-token",
        refreshToken: "mock-\(provider.rawValue)-refresh-token",
        sessionID: "mock-\(provider.rawValue)-session-token",
      ),
      authCode: "mock-\(provider.rawValue)-auth-code"
    )
  }

  public func checkUserSignUp(
    accessToken: String,
    socialType: SocialType
  ) async throws -> OAuthCheckUser {
    return OAuthCheckUser(registered: true)
  }

  public func loginUser(accessToken: String, socialType: SocialType) async throws -> AuthEntity {
    let mockData = AuthEntity(
      name: "testter",
      provider: .apple,
      token: .init(authToken: "", accessToken: "", refreshToken: "", sessionID: "")
    )
    return mockData
  }
}
