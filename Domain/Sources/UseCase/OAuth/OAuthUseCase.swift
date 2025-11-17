//
//  OAuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies
import LogMacro

public struct OAuthUseCase: OAuthUseCaseProtocol {
  private let repository: OAuthRepositoryProtocol
  private let googleService: GoogleOAuthServicing

  public init(
    repository: OAuthRepositoryProtocol,
    googleService: GoogleOAuthServicing
  ) {
    self.repository = repository
    self.googleService = googleService
  }

  @MainActor
  public func signUpWithGoogleSuperBase() async throws -> UserEntity {
    let payload = try await googleService.signIn()
    Log.info("Google sign-in succeeded for \(payload.displayName ?? "unknown user")")

    let session = try await repository.signInWithGoogle(
      idToken: payload.idToken,
      displayName: payload.displayName
    )
    Log.info("Supabase sign-in with Google succeeded")

    let user = session.user
    return user.toDomain(session: session)
  }
}

// MARK: - Dependencies

private struct UnimplementedOAuthUseCase: OAuthUseCaseProtocol {
  @MainActor
  func signUpWithGoogleSuperBase() async throws -> UserEntity {
    fatalError("OAuthUseCase dependency has not been provided.")
  }
}

extension OAuthUseCase: DependencyKey {
  public static var liveValue: any OAuthUseCaseProtocol = UnimplementedOAuthUseCase()
  public static var previewValue: any OAuthUseCaseProtocol = UnimplementedOAuthUseCase()
  public static var testValue: any OAuthUseCaseProtocol = UnimplementedOAuthUseCase()
}

public extension DependencyValues {
  var oAuthUseCase: any OAuthUseCaseProtocol {
    get { self[OAuthUseCase.self] }
    set { self[OAuthUseCase.self] = newValue }
  }
}
