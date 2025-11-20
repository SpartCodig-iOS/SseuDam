//
//  LoginUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/20/25.
//

import Domain
import ComposableArchitecture
import AuthenticationServices

/// Coordinates every dependency needed to perform an OAuth based login.
public struct LoginUseCase {
  private let oAuth: OAuthUseCase

  public init(oAuth: OAuthUseCase) {
    self.oAuth = oAuth
  }

  public func signInWithApple(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserEntity {
    try await oAuth.signInWithAppleOnce(credential: credential, nonce: nonce)
  }

  public func signUp(with provider: SocialType) async throws -> UserEntity {
    try await oAuth.signUp(with: provider)
  }
}

extension LoginUseCase: DependencyKey {
  public static var liveValue: LoginUseCase = .mockedDependency()
  public static var previewValue: LoginUseCase { .mockedDependency() }
  public static var testValue: LoginUseCase = .mockedDependency()
}

public extension DependencyValues {
  var loginUseCase: LoginUseCase {
    get { self[LoginUseCase.self] }
    set { self[LoginUseCase.self] = newValue }
  }
}

private extension LoginUseCase {
  static func mockedDependency() -> LoginUseCase {
    let oauth = OAuthUseCase(
      repository: MockOAuthRepository(),
      googleRepository: MockGoogleOAuthRepository(),
      appleRepository: MockAppleOAuthRepository()
    )
    return LoginUseCase(oAuth: oauth)
  }
}

