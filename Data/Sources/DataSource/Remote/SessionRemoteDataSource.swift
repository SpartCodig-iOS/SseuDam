//
//  SessionRemoteDataSource.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import  Moya
import NetworkService

public protocol SessionRemoteDataSourceProtocol {
  func checkLoginSession(
    body: SessionRequestDTO
  ) async throws -> SessionResponseDTO
}


public final class SessionRemoteDataSource: SessionRemoteDataSourceProtocol {
  private var provider = MoyaProvider<SessionService>.default

  public init(
      provider: MoyaProvider<SessionService> = MoyaProvider<SessionService>.default
  ) {
      self.provider = provider
  }


  public func checkLoginSession(
    body: SessionRequestDTO
  ) async throws -> SessionResponseDTO {
    let response: BaseResponse<SessionResponseDTO> = try await provider.request(.checkSession(body: body))
    
    guard let data = response.data else {
        throw NetworkError.noData
    }

    return data
  }

}
