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
      let token = UserDefaults.standard.string(forKey: "Token") ?? ""
      let body =  LoginUserRequestDTO(
            accessToken: input.accessToken,
            loginType: input.socialType.rawValue,
            authorizationCode: input.socialType == .kakao ? input.authorizationCode : input.authorizationCode,
            codeVerifier: input.socialType == .kakao ? input.codeVerifier : input.codeVerifier,
            redirectUri: input.socialType == .kakao ? input.redirectUri : nil,
            deviceToken: token
        )
        let respons: BaseResponse<AuthResponseDTO> = try await provider.request(.loginOAuth(body: body))
        guard let data = respons.data  else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
}
