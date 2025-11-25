//
//  SessionRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation
import Domain

final public class SessionRepository: SessionRepositoryProtocol {


  private let dataSource: SessionRemoteDataSourceProtocol

  public init(
    dataSource: SessionRemoteDataSourceProtocol
  ) {
    self.dataSource = dataSource
  }

  public func checkLoginSession(
    sessionId: String
  ) async throws -> Domain.SessionEntity {
    let data = try await dataSource.checkLoginSession(body: SessionRequestDTO(sessionId: sessionId))
    return data.toDomain()
  }
}
