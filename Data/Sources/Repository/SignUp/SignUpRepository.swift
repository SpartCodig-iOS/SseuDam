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
    input: Domain.OAuthCheckUserInput
  ) async throws -> Domain.OAuthCheckUser {
    let body = OAuthCheckUserRequestDTO(accessToken: input.accessToken, loginType: input.socialType.rawValue)
    let response: BaseResponse<OAuthCheckUserResponseDTO> = try await provider.request(.checkSignUpUser(body: body))
    guard let data = response.data else {
      throw NetworkError.noData
    }
    return data.toDomain()
  }
}
