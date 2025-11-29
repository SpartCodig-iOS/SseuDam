//
//  AuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import  ComposableArchitecture

public struct AuthUseCase: AuthUseCaseProtocol {
    private let repository: AuthRepositoryProtocol

    public init(
        repository: AuthRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    public func refresh() async throws -> TokenResult {
        let token = KeychainManager.shared.loadRefreshToken() ?? ""
        let result = try await repository.refresh(token: token)

        KeychainManager.shared.saveTokens(
            accessToken: result.token.accessToken,
            refreshToken: result.token.refreshToken
        )

        return result
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
