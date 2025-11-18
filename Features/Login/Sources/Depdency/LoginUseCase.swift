//
//  LoginUseCase.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/18/25.
//

import Domain
import Data
import ComposableArchitecture

public struct LoginUseCase {
  let oauth: OAuthUseCase
  public init(
    oauth: OAuthUseCase,
  ) {
    self.oauth = oauth
  }
}

extension LoginUseCase: DependencyKey {
  static public var liveValue: LoginUseCase = {
    let oauth =  OAuthUseCase(
      repository: OAuthRepository(),
      googleRepository: GoogleOAuthRepository(),
      appleRepository: AppleOAuthRepository()
    )
    return LoginUseCase(oauth: oauth)
  }()

  static public var previewValue: LoginUseCase { liveValue }

  static public var testValue: LoginUseCase =   {
    let oauth = OAuthUseCase(
      repository: MockOAuthRepository(),
      googleRepository: MockGoogleOAuthRepository(),
      appleRepository: MockAppleOAuthRepository()
    )
    return LoginUseCase(oauth: oauth)
  }()
}

public extension DependencyValues {
  var loginUseCase: LoginUseCase {
    get { self[LoginUseCase.self] }
    set { self[LoginUseCase.self] = newValue }
  }
}
