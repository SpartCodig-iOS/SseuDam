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

    public func login(
        input: Domain.OAuthUserInput
    ) async throws -> Domain.AuthResult {
        let body = LoginUserRequestDTO(accessToken: input.accessToken, loginType: input.socialType.rawValue)
        let respons: BaseResponse<AuthResponseDTO> = try await provider.request(.loginOAuth(body: body))
        guard let data = respons.data  else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
}
