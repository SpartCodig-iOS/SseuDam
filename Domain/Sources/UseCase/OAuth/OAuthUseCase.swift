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

  public init(
    repository: OAuthRepositoryProtocol,
    googleRepository: GoogleOAuthRepositoryProtocol,
    appleRepository: AppleOAuthRepositoryProtocol,
  ) {
    self.repository = repository
    self.googleRepository = googleRepository
    self.appleRepository = appleRepository
  }

  public func signInWithApple(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserEntity {
    guard let identityTokenData = credential.identityToken,
          let identityToken = String(data: identityTokenData, encoding: .utf8),
          let authCode = String(data: credential.authorizationCode ?? Data(), encoding: .utf8)
    else {
      throw AuthError.missingIDToken
    }

    let displayName = formatDisplayName(credential.fullName)
    Log.info("Apple sign-in credential received for \(displayName ?? "unknown user")")

    let session = try await repository.signIn(
      provider: .apple,
      idToken: identityToken,
      nonce: nonce,
      displayName: displayName
    )
    Log.info("Supabase sign-in with Apple succeeded")

    let user = session.user
    return user.toDomain(session: session, authCode: authCode)
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

  public func signUp(with provider: SocialType) async throws -> UserEntity {
    let payload = try await fetchPayload(for: provider)
    Log.info("\(provider.rawValue) sign-in succeeded for \(payload.displayName ?? "unknown user")")

    let session = try await repository.signIn(
      provider: payload.provider,
      idToken: payload.idToken,
      nonce: payload.nonce,
      displayName: payload.displayName
    )
    Log.info("Supabase sign-in with \(provider.rawValue) succeeded")

    let user = session.user
    return user.toDomain(session: session, authCode: payload.authorizationCode)
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
      case .none:
        throw AuthError.configurationMissing
    }
  }

  public func loginUser(
    accessToken: String,
    socialType: SocialType
  ) async throws -> AuthEntity {
    return try await repository.loginUser(input: OAuthUserInput(accessToken: accessToken, socialType: socialType))
  }
}

// MARK: - Dependencies
extension OAuthUseCase: DependencyKey {
  public static var liveValue:  OAuthUseCaseProtocol = MockOAuthUseCase()
  public static var previewValue:  OAuthUseCaseProtocol = MockOAuthUseCase()
  public static var testValue:  OAuthUseCaseProtocol = MockOAuthUseCase()
}

public extension DependencyValues {
  var oAuthUseCase:  OAuthUseCaseProtocol {
    get { self[OAuthUseCase.self] }
    set { self[OAuthUseCase.self] = newValue }
  }
}
