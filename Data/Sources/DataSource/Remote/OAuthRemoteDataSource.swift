//
//  OAuthRemoteDataSource.swift
//  Data
//
//  Created by Wonji Suh  on 11/21/25.
//

import Foundation
import NetworkService
import Moya

public protocol OAuthRemoteDataSourceProtocol {
    func checkSingUpUser(
        body: OAuthCheckUserRequestDTO
    )  async throws ->  OAuthCheckUserResponseDTO
}

public final class OAuthRemoteDataSource: OAuthRemoteDataSourceProtocol {

    private var provider = MoyaProvider<OAuthService>.default
    
    public init(
        provider: MoyaProvider<OAuthService> = MoyaProvider<OAuthService>.default
    ) {
        self.provider = provider
    }
    
    public func checkSingUpUser(
        body: OAuthCheckUserRequestDTO
    ) async throws -> OAuthCheckUserResponseDTO {
        let response: BaseResponse<OAuthCheckUserResponseDTO> = try await provider.request(.checkSignUpUser(body: body))

    guard let data = response.data else {
        throw NetworkError.noData
    }

    return data
  }
}
