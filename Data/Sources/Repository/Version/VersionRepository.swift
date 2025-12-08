//
//  VersionRepository.swift
//  Data
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation
import NetworkService
import Domain

import Moya

final public class VersionRepository: VersionRepositoryProtocol {
  private var provider: MoyaProvider<VersionAPITarget>

  public init(
      provider: MoyaProvider<VersionAPITarget> = MoyaProvider<VersionAPITarget>.default
  ) {
      self.provider = provider
  }

  public func getVersion(bundleId: String, version: String) async throws -> Domain.Version {
    let body = VersionRequestDTO(bundleId: bundleId, currentVersion: version)
    let response: BaseResponse<VersionResponseDTO> = try await provider.request(.getVersion(body: body))

    guard let data = response.data else {
      throw NetworkError.noData
    }
    return data.toDomain()
  }

}
