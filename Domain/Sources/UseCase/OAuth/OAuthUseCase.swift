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
  private let repository: OAuthRepositoryProtocol
  private let googleService: GoogleOAuthServicing
  private let appleService: AppleOAuthServicing

  public init(
    repository: OAuthRepositoryProtocol,
    googleService: GoogleOAuthServicing,
    appleService: AppleOAuthServicing,
  ) {
    self.repository = repository
    self.googleService = googleService
    self.appleService = appleService
  }

  public func signInWithAppleOnce(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserEntity {
    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8),
          let authCode = String(data: credential.authorizationCode ?? Data(), encoding: .utf8)
    else {
      throw AppleSignInError.missingIDToken
    }

    let displayName = formatDisplayName(credential.fullName)
    Log.info("Apple sign-in credential received for \(displayName ?? "unknown user")")

    let session = try await repository.signInWithApple(
      idToken: identityToken,
      nonce: nonce,
      displayName: displayName
    )
    Log.info("Supabase sign-in with Apple succeeded")

    let user = session.user
    return user.toDomain(session: session, authCode: authCode)
  }


  public func signUpWithAppleSuperBase() async throws -> UserEntity {
    let payload = try await appleService.signIn()
    Log.info("Apple sign-in succeeded for \(payload.displayName ?? "unknown user")")

    let session = try await repository.signInWithApple(
      idToken: payload.idToken,
      nonce: payload.nonce,
      displayName: payload.displayName
    )
    Log.info("Supabase sign-in with Apple succeeded")

    let user = session.user
    return user.toDomain(session: session, authCode: payload.authorizationCode ?? "")
  }

  public func signUpWithGoogleSuperBase() async throws -> UserEntity {
    let payload = try await googleService.signIn()
    Log.info("Google sign-in succeeded for \(payload.displayName ?? "unknown user")")

    let session = try await repository.signInWithGoogle(
      idToken: payload.idToken,
      displayName: payload.displayName
    )
    Log.info("Supabase sign-in with Google succeeded", "\(payload.authorizationCode ?? "")")

    let user = session.user
    return user.toDomain(session: session, authCode: payload.authorizationCode ?? "")
  }

  // MARK: - Helper Methods
  private func formatDisplayName(_ components: PersonNameComponents?) -> String? {
    guard let components else { return nil }
    let formatter = PersonNameComponentsFormatter()
    let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
  }
}

// MARK: - Dependencies

private struct MockOAuthUseCase: OAuthUseCaseProtocol {
  func signInWithAppleOnce(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserEntity {
    // Mock implementation for testing/preview
    return UserEntity(
      id: "mock-apple-user-id",
      email: "apple.user@example.com",
      displayName: "Mock Apple User",
      provider: .apple,
      authCode: "",
    )
  }

  func signUpWithAppleSuperBase() async throws -> UserEntity {
    // Mock implementation for testing/preview
    return UserEntity(
      id: "mock-apple-user-id",
      email: "apple.user@example.com",
      displayName: "Mock Apple User",
      provider: .apple,
      authCode: "",

    )
  }

  func signUpWithGoogleSuperBase() async throws -> UserEntity {
    // Mock implementation for testing/preview
    return UserEntity(
      id: "mock-google-user-id",
      email: "google.user@example.com",
      displayName: "Mock Google User",
      provider: .google,
      authCode: "",
    )
  }
}

extension OAuthUseCase: DependencyKey {
  public static var liveValue: any OAuthUseCaseProtocol = MockOAuthUseCase()
  public static var previewValue: any OAuthUseCaseProtocol = MockOAuthUseCase()
  public static var testValue: any OAuthUseCaseProtocol = MockOAuthUseCase()
}

public extension DependencyValues {
  var oAuthUseCase: any OAuthUseCaseProtocol {
    get { self[OAuthUseCase.self] }
    set { self[OAuthUseCase.self] = newValue }
  }
}
