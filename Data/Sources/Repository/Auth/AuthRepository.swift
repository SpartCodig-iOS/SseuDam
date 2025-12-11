//
//  AuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/27/25.
//

import Domain
import Moya
import NetworkService
import Foundation

final public class AuthRepository: AuthRepositoryProtocol {
    private let remote: any AuthRemoteDataSourceProtocol
    
    public init(
        remote: any AuthRemoteDataSourceProtocol = AuthRemoteDataSource(
            authProvider: MoyaProvider<AuthAPITarget>.authorized,
            oauthProvider: MoyaProvider<OAuthAPITarget>.default
        )
    ) {
        self.remote = remote
    }
    
    public func refresh(token: String) async throws -> Domain.TokenResult {
        try await remote.refresh(token: token)
    }
    
    public func logout(
        sessionId: String
    ) async throws -> Domain.LogoutStatus {
        try await remote.logout(sessionId: sessionId)
    }
    
    public func delete() async throws -> Domain.AuthDeleteStatus {
        try await remote.delete()
    }

    public func registerDeviceToken(
        token: String
    ) async throws -> Domain.DeviceToken {
        try await remote.registerDeviceToken(token: token)
    }

    // MARK: - Auth / SignUp / Kakao finalize
    public func checkUser(input: Domain.OAuthUserInput) async throws -> Domain.OAuthCheckUser {
        try await remote.checkUser(input: input)
    }

    public func login(input: Domain.OAuthUserInput) async throws -> Domain.AuthResult {
        try await remote.login(input: input)
    }

    public func signUp(input: Domain.OAuthUserInput) async throws -> Domain.AuthResult {
        try await remote.signUp(input: input)
    }

    public func finalizeKakao(ticket: String) async throws -> Domain.AuthResult {
        try await remote.finalizeKakao(ticket: ticket)
    }
}

extension AuthRepository: @unchecked Sendable {}
