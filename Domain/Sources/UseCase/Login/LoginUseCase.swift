//
//  LoginUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/20/25.
//

import ComposableArchitecture
import AuthenticationServices

/// Coordinates every dependency needed to perform an OAuth based login.
public struct LoginUseCase {
  public func loginUser(
    accessToken: String,
    socialType: SocialType
  ) async throws -> AuthEntity {
    return try await oAuth.loginUser(accessToken: accessToken, socialType: socialType)
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

