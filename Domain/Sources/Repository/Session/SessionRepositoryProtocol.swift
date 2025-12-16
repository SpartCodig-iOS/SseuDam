//
//  SessionRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation
import Dependencies

public protocol SessionRepositoryProtocol {
    /// Validate a stored session id and return its status from backend.
    func checkSession(sessionId: String) async throws -> SessionStatus
}

// MARK: - Dependencies
public struct SessionRepositoryDependencyKey: DependencyKey {
    public static var liveValue: SessionRepositoryProtocol {
        fatalError("SessionRepositoryDependency liveValue not implemented")
    }
    public static let previewValue: SessionRepositoryProtocol = MockSessionRepository()
    public static let testValue: SessionRepositoryProtocol = MockSessionRepository()
}

public extension DependencyValues {
    var sessionRepository:  SessionRepositoryProtocol {
        get { self[SessionRepositoryDependencyKey.self] }
        set { self[SessionRepositoryDependencyKey.self] = newValue }
    }
}
