//
//  SessionRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

import Domain
import NetworkService

import Moya

final public class SessionRepository: SessionRepositoryProtocol {
  private var provider: MoyaProvider<SessionAPITarget>

  public init(
      provider: MoyaProvider<SessionAPITarget> = MoyaProvider<SessionAPITarget>.default,
  ) {
      self.provider = provider
  }

  public func checkSession(
    sessionId: String
  ) async throws -> Domain.SessionResult {
    let body = SessionRequestDTO(sessionId: sessionId)
    let response: BaseResponse<SessionResponseDTO> = try await provider.request(.checkSession(body: body))

    guard let data = response.data else {
      throw NetworkError.noData
    }

    return data.toDomain()
  }
}
