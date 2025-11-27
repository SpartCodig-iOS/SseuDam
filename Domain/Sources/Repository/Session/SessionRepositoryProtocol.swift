//
//  SessionRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation
import  Dependencies

public protocol SessionRepositoryProtocol {
  func checkSession(sessionId: String) async throws -> SessionResult
}

public struct SessionRepositoryDependency: DependencyKey {
  public static var liveValue: SessionRepositoryProtocol = MockSessionRepository()
  public static var previewValue: SessionRepositoryProtocol = MockSessionRepository()
  public static var testValue: SessionRepositoryProtocol = MockSessionRepository()
}

public extension DependencyValues {
  var sessionRepository:  SessionRepositoryProtocol {
    get { self[SessionRepositoryDependency.self] }
    set { self[SessionRepositoryDependency.self] = newValue }
  }
}
