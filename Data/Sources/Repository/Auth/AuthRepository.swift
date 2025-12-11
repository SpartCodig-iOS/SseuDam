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
    private var provider: MoyaProvider<AuthAPITarget>
    
    public init(
        provider: MoyaProvider<AuthAPITarget> = MoyaProvider<AuthAPITarget>.authorized
    ) {
        self.provider = provider
    }
    
    
    public func refresh(token: String) async throws -> Domain.TokenResult {
        let body = RefreshRequestDTO(refreshToken: token)
        let response: BaseResponse<RefreshResponseDTO> = try await provider.request(.refreshToken(body: body))
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
    
    public func logout(
        sessionId: String
    ) async throws -> Domain.LogoutStatus {
        let body = SessionRequestDTO(sessionId: sessionId)
        let response: BaseResponse<LogoutResponseDTO> = try await provider.request(.logout(body: body))
        guard let data = response.data  else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
    
    public func delete() async throws -> Domain.AuthDeleteStatus {
        let response: BaseResponse<AuthDeleteResponseDTO> = try await provider.request(.deleteAccount)
        guard let data = response.data else {
            throw  NetworkError.noData
        }
        return data.toDomain()
    }

    public func registerDeviceToken(
        token: String
    ) async throws -> Domain.DeviceToken {
        let pendingKey = getOrCreatePendingKey()
        let body = DeviceTokenRequestDTO(deviceToken: token, pendingKey: pendingKey)
        let response: BaseResponse<DeviceTokenResponseDTO> = try await provider.request(.registerDeviceToken(body: body))
        guard let data = response.data else {
            throw NetworkError.noData
        }

        if let returnedKey = data.pendingKey {
            persistPendingKey(returnedKey)
        }

        return data.toDomain()
    }

    private func getOrCreatePendingKey() -> String {
        let key = "auth.pendingKey"
        if let saved = UserDefaults.standard.string(forKey: key) {
            return saved
        }
        let newKey = UUID().uuidString
        UserDefaults.standard.set(newKey, forKey: key)
        return newKey
    }

    private func persistPendingKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "auth.pendingKey")
    }
}

extension AuthRepository: @unchecked Sendable {}
