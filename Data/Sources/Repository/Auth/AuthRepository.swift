//
//  AuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/27/25.
//

import Domain
import Moya
import NetworkService

final public class AuthRepository: AuthRepositoryProtocol {
    private var provider: MoyaProvider<AuthAPITarget>

    public init(
      provider: MoyaProvider<AuthAPITarget> = MoyaProvider<AuthAPITarget>.default
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

}

extension AuthRepository: @unchecked Sendable {}
