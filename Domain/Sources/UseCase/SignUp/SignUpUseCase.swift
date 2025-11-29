//
//  SignUpUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import ComposableArchitecture

public struct SignUpUseCase: SignUpUseCaseProtocol {
    private let repository: SignUpRepositoryProtocol
    
    public init(
        repository: SignUpRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    
    public func checkUserSignUp(
        accessToken: String,
        socialType: SocialType
    ) async throws -> OAuthCheckUser {
      return try await repository.checkSignUp(
        input: OAuthUserInput(
          accessToken: accessToken,
          socialType: socialType,
          authorizationCode: ""
        )
      )
    }


  public func signUp(
    accessToken: String,
    socialType: SocialType,
    authCode: String
  ) async throws -> AuthResult {
    return try await repository.signUp(
      input: OAuthUserInput(
        accessToken: accessToken,
        socialType: socialType,
        authorizationCode: authCode
      )
    )
  }
}


// MARK: - Dependencies
extension SignUpUseCase: DependencyKey {
    public static var liveValue:  SignUpUseCaseProtocol =  {
        return SignUpUseCase(repository: MockSignUpRepository())
    } ()
    public static var previewValue:  SignUpUseCaseProtocol = liveValue
    public static var testValue:  SignUpUseCaseProtocol = SignUpUseCase(repository: MockSignUpRepository())
}

public extension DependencyValues {
    var signUpUseCase:  SignUpUseCaseProtocol {
        get { self[SignUpUseCase.self] }
        set { self[SignUpUseCase.self] = newValue }
    }
}
