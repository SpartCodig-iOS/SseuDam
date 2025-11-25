//
//  SessionUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

import ComposableArchitecture

public struct SessionUseCase: SessionUseCaseProtocol {
  private let repository: SessionRepositoryProtocol

  public init(
    repository: SessionRepositoryProtocol
  ) {
    self.repository = repository
  }

  public func checkAuthSession(
    sessionId: String
  ) async throws -> SessionEntity {
    return try await repository.checkLoginSession(sessionId: sessionId)
  }
}


extension SessionUseCase: DependencyKey {
  public static var liveValue: SessionUseCaseProtocol {
  return SessionUseCase(repository: MockSessionRepository())
  }

  public static var previewValue:  SessionUseCaseProtocol { liveValue }

  public static var testValue:  SessionUseCaseProtocol {
    return SessionUseCase(repository: MockSessionRepository())
  }
}

public extension DependencyValues {
  var sessionUseCase: SessionUseCaseProtocol {
    get { self[SessionUseCase.self] }
    set { self[SessionUseCase.self] = newValue }
  }
}
