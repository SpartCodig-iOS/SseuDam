//
//  ProfileRepository.swift
//  Data
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation
import Moya
import Domain
import NetworkService

final public class ProfileRepository: ProfileRepositoryProtocol {
  private let provider: MoyaProvider<ProfileTarget>

  public init(provider: MoyaProvider<ProfileTarget> = MoyaProvider<ProfileTarget>.withSession(AuthInterceptor.shared)) {
    self.provider = provider
  }

    public func getProfile() async throws -> Domain.Profile {
        let response: BaseResponse<ProfileResponseDTO> = try await provider.request(.getProfile)
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }

}
