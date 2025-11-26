//
//  LoginRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation
import Domain
import Moya
import NetworkService

public final class LoginRepository: LoginRepositoryProtocol {

    private var provider: MoyaProvider<OAuthAPITarget>

    public init(
        provider: MoyaProvider<OAuthAPITarget> = MoyaProvider<OAuthAPITarget>.default,
    ) {
        self.provider = provider
    }

    public func loginUser(
        input: Domain.OAuthUserInput
    ) async throws -> Domain.AuthEntity {
        let body = OAuthLoginUserRequestDTO(accessToken: input.accessToken, loginType: input.socialType.rawValue)
        let respons: BaseResponse<OAuthResponseDTO> = try await provider.request(.loginOAuth(body: body))
        guard let data = respons.data  else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
}
