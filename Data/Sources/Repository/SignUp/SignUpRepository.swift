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
    
    public func checkSignUp(
        input: OAuthUserInput
    ) async throws -> OAuthCheckUser {
        // 카카오는 authorizationCode/codeVerifier 전달, 그 외는 accessToken만
        let body = LoginUserRequestDTO(
            accessToken: input.accessToken,
            loginType: input.socialType.rawValue,
            authorizationCode: input.socialType == .kakao ? input.authorizationCode : nil,
            codeVerifier: input.socialType == .kakao ? input.codeVerifier : nil,
            redirectUri: input.socialType == .kakao ? input.redirectUri : nil,
            deviceToken: nil
        )
        let response: BaseResponse<ChecSignUpResponseDTO> = try await provider.request(.checkSignUpUser(body: body))
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
    
    public func signUp(
        input: Domain.OAuthUserInput
    ) async throws -> Domain.AuthResult {
      let token = UserDefaults.standard.string(forKey: "Token") ?? ""
      let body = SignUpUserRequestDTO(
            accessToken: input.accessToken,
            loginType: input.socialType.rawValue,
            authorizationCode: input.socialType == .kakao ? input.authorizationCode : input.authorizationCode,
            codeVerifier: input.socialType == .kakao ? input.codeVerifier : input.codeVerifier,
            redirectUri: input.socialType == .kakao ? input.redirectUri : nil,
            deviceToken: token
        )
        let response: BaseResponse<AuthResponseDTO> = try await provider.request(.signUpOAuth(body: body))
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }
}
