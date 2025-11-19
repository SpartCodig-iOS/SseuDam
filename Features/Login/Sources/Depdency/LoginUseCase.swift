//
//  LoginUseCase.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/18/25.
//

import Domain
import ComposableArchitecture

/// Coordinates every dependency needed to perform an OAuth based login.
public struct LoginUseCase {
  public let oAuth: OAuthUseCase

  public init(oAuth: OAuthUseCase) {
    self.oAuth = oAuth
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
