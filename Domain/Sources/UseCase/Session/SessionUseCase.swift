//
//  SessionUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation
import Dependencies

public struct SessionUseCase: SessionUseCaseProtocol {
    @Dependency(\.sessionRepository) private var repository: SessionRepositoryProtocol
    
    public init() {}
    
    public func checkSession(
        sessionId: String
    ) async throws -> SessionStatus {
        return try await repository.checkSession(sessionId: sessionId)
    }
}

extension SessionUseCase: DependencyKey {
    public static let liveValue: SessionUseCaseProtocol = SessionUseCase()
    public static let previewValue:  SessionUseCaseProtocol = SessionUseCase()
    public static let testValue:  SessionUseCaseProtocol = SessionUseCase()
}

public extension DependencyValues {
    var sessionUseCase: SessionUseCaseProtocol {
        get { self[SessionUseCase.self] }
        set { self[SessionUseCase.self] = newValue }
    }
}
