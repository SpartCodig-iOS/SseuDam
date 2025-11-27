//
//  LoginUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/20/25.
//

import ComposableArchitecture
import AuthenticationServices

/// Coordinates every dependency needed to perform an OAuth based login.
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
        let repo = MockLoginRepository()
        return LoginUseCase(repository: repo)
    }
}
