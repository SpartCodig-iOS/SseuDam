//
//  AuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

//
//  AuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import  ComposableArchitecture

public struct AuthUseCase: AuthUseCaseProtocol {
  @Shared(.appStorage("sessionId")) var sessionId: String? = ""
  
    private let repository: AuthRepositoryProtocol
    public init(
        repository: AuthRepositoryProtocol
    ) {
        self.repository = repository
    }

  public func logout() async throws -> LogoutStatus {
    let sessionId = self.sessionId ?? ""
    return try await repository.logout(sessionId: sessionId)
  }
}


extension AuthUseCase: DependencyKey {
    public static var liveValue: AuthUseCaseProtocol {
        return AuthUseCase(repository: MockAuthRepository())
    }

    public static var previewValue: any AuthUseCaseProtocol { liveValue }

    public static let testValue: AuthUseCaseProtocol = AuthUseCase(
        repository: MockAuthRepository()
    )
}


public extension DependencyValues {
    var authUseCase : AuthUseCaseProtocol {
        get { self[AuthUseCase.self] }
        set { self[AuthUseCase.self] = newValue }
    }
}
