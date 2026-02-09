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
    @Dependency(\.authRepository) private var authRepository: AuthRepositoryProtocol
    @Dependency(\.tokenStorageUseCase) private var tokenStorageUseCase: TokenStorageUseCase
    @Dependency(\.keychainManager) private var keychainManager

    
    public init() {}
    
    // MARK: - 로그인
    public func login(_ authData: AuthData) async -> Result<AuthResult, AuthError> {
        do {
            let input = makeOAuthInput(from: authData)
            var authResult = try await authRepository.login(input: input)
            authResult.token.authToken = authData.authToken
            await tokenStorageUseCase.save(auth: authResult)
            return .success(authResult)
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }
    
    // MARK: - 로그아웃
    public func logout() async throws -> LogoutStatus {
        let sessionId = self.sessionId ?? ""
        return try await repository.logout(sessionId: sessionId)
    }
    
    public func deleteUser() async throws -> AuthDeleteStatus {
        let result = try await repository.delete()
        keychainManager.clearAll()
        return result
    }
}

private extension AuthUseCase {
    func makeOAuthInput(from authData: AuthData) -> OAuthUserInput {
        OAuthUserInput(
            accessToken: authData.authToken,
            socialType: authData.socialType,
            authorizationCode: authData.authorizationCode,
            codeVerifier: authData.codeVerifier,
            redirectUri: authData.redirectUri
        )
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
