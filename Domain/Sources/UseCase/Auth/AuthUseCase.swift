//
//  AuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//


import  ComposableArchitecture
import Dependencies

public struct AuthUseCase: AuthUseCaseProtocol {
    @Shared(.appStorage("sessionId")) var sessionId: String? = ""
    
    @Dependency(\.authRepository) private var repository: AuthRepositoryProtocol
    public init() {}
    
    // MARK: - 로그아웃
    public func logout() async throws -> LogoutStatus {
        let sessionId = self.sessionId ?? ""
        return try await repository.logout(sessionId: sessionId)
    }
    
    public func deleteUser() async throws -> AuthDeleteStatus {
        let result = try await repository.delete()
        KeychainManager.shared.clearAll()
        return result
    }
}


extension AuthUseCase: DependencyKey {
    public static let liveValue: AuthUseCaseProtocol = AuthUseCase()
    public static let previewValue: any AuthUseCaseProtocol = AuthUseCase()
    public static let testValue: AuthUseCaseProtocol = AuthUseCase()
}


public extension DependencyValues {
    var authUseCase : AuthUseCaseProtocol {
        get { self[AuthUseCase.self] }
        set { self[AuthUseCase.self] = newValue }
    }
}
