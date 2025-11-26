//
//  SignUpRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation
import Domain
import Moya
import NetworkService

final public class SignUpRepository: SignUpRepositoryProtocol {
    private var provider: MoyaProvider<OAuthAPITarget>
    
    public init(
        provider: MoyaProvider<OAuthAPITarget> = MoyaProvider<OAuthAPITarget>.default,
    ) {
        self.provider = provider
    }
    
    public func checkSignUpUser(
        input: OAuthUserInput
    ) async throws -> OAuthCheckUser {
        let body = OAuthLoginUserRequestDTO(accessToken: input.accessToken, loginType: input.socialType.rawValue)
        let response: BaseResponse<OAuthCheckUserResponseDTO> = try await provider.request(.checkSignUpUser(body: body))
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
    
    public func signUpUser(
        input: Domain.OAuthUserInput
    ) async throws -> Domain.AuthEntity {
        let body = OAuthSignUpUserRequestDTO(accessToken: input.accessToken, loginType: input.socialType.rawValue, authorizationCode: input.authorizationCode)
        let response: BaseResponse<OAuthResponseDTO> = try await provider.request(.signUpOAuth(body: body))
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
}
