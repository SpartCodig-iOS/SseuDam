//
//  LoginUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/20/25.
//

import ComposableArchitecture
import AuthenticationServices

public struct LoginUseCase: LoginUseCaseProtocol {

    private let repository: LoginRepositoryProtocol

    public init(
        repository: LoginRepositoryProtocol
    ) {
        self.repository = repository
    }

    public func login(
      accessToken: String,
      socialType: SocialType
    ) async throws -> AuthResult {
      return try await repository.login(input: OAuthUserInput(accessToken: accessToken, socialType: socialType, authorizationCode: ""))
    }
}

extension LoginUseCase: DependencyKey {
    public static var liveValue: LoginUseCaseProtocol = mockedDependency()
    public static var previewValue: LoginUseCaseProtocol { mockedDependency() }
    public static var testValue: LoginUseCaseProtocol = mockedDependency()
}

public extension DependencyValues {
    var loginUseCase: LoginUseCaseProtocol {
        get { self[LoginUseCase.self] }
        set { self[LoginUseCase.self] = newValue }
    }
}

private extension LoginUseCase {
    static func mockedDependency() -> LoginUseCaseProtocol {
        let repo = MockLoginRepository()
        return LoginUseCase(repository: repo)
    }
}
