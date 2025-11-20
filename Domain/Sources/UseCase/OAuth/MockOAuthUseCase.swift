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
  public func signInWithAppleOnce(
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
        refreshToken: "mock-refresh-token"
      ),
      authCode: "mock-auth-code"
    )
  }

  public func signUpWithAppleSuperBase() async throws -> UserEntity {
    // Mock implementation for testing/preview
    return UserEntity(
      id: "mock-apple-user-id",
      email: "apple.user@example.com",
      displayName: "Mock Apple User",
      provider: .apple,
      tokens: .init(
        authToken: "mock-superbase-token",
        accessToken: "mock-access-token",
        refreshToken: "mock-refresh-token"
      ),
      authCode: "mock-auth-code"
    )
  }

  public func signUpWithGoogleSuperBase() async throws -> UserEntity {
    // Mock implementation for testing/preview
    return UserEntity(
      id: "mock-google-user-id",
      email: "google.user@example.com",
      displayName: "Mock Google User",
      provider: .google,
      tokens: .init(
        authToken: "mock-superbase-token",
        accessToken: "mock-access-token",
        refreshToken: "mock-refresh-token"
      ),
      authCode: "mock-google-auth-code"
    )
  }
}
