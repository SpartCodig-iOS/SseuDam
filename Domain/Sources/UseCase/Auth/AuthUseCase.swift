//
//  AuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import ComposableArchitecture

/// Placeholder for logout / withdrawal use cases. Refresh is handled in the network layer.
public struct AuthUseCase: AuthUseCaseProtocol {
  private let repository: AuthRepositoryProtocol

  public init(repository: AuthRepositoryProtocol) {
    self.repository = repository
  }
}

extension AuthUseCase: DependencyKey {
  public static var liveValue: AuthUseCaseProtocol {
    AuthUseCase(repository: MockAuthRepository())
  }

  public static var previewValue: any AuthUseCaseProtocol { liveValue }

  public static let testValue: AuthUseCaseProtocol = AuthUseCase(
    repository: MockAuthRepository()
  )
}

public extension DependencyValues {
  var authUseCase: AuthUseCaseProtocol {
    get { self[AuthUseCase.self] }
    set { self[AuthUseCase.self] = newValue }
  }
}
