//
//  SignUpUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 12/17/25.
//

import Foundation
import Dependencies
import LogMacro

/// 회원가입/로그인/체크/카카오 finalize 등 인증 비즈니스 로직 전담
public struct SignUpUseCase: SignUpUseCaseProtocol {
    @Dependency(\.authRepository) private var authRepository: AuthRepositoryProtocol
    @Dependency(\.tokenStorageUseCase) private var tokenStorageUseCase: TokenStorageUseCase

    public init() {}
}

public extension SignUpUseCase {
    func checkUser(_ authData: AuthData) async -> Result<OAuthCheckUser, AuthError> {
        do {
            let input = makeOAuthInput(from: authData)
            let result = try await authRepository.checkUser(input: input)
            return .success(result)
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }

    func signUp(_ authData: AuthData) async -> Result<AuthResult, AuthError> {
        do {
            let input = makeOAuthInput(from: authData)
            var authResult = try await authRepository.signUp(input: input)
            authResult.token.authToken = authData.authToken
            await tokenStorageUseCase.save(auth: authResult)
            return .success(authResult)
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }

    func finalizeKakao(ticket: String) async -> Result<AuthResult, AuthError> {
        do {
            let authResult = try await authRepository.finalizeKakao(ticket: ticket)
            await tokenStorageUseCase.save(auth: authResult)
            return .success(authResult)
        } catch {
            let authError = error as? AuthError ?? .unknownError(error.localizedDescription)
            return .failure(authError)
        }
    }
}

// MARK: - Helpers
private extension SignUpUseCase {
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

// MARK: - Dependency Registration
extension SignUpUseCase: DependencyKey {
    public static var liveValue: SignUpUseCase = SignUpUseCase()
    public static var previewValue: SignUpUseCase = SignUpUseCase()
    public static var testValue: SignUpUseCase = SignUpUseCase()
}

public extension DependencyValues {
    var signUpUseCase: SignUpUseCase {
        get { self[SignUpUseCase.self] }
        set { self[SignUpUseCase.self] = newValue }
    }
}
