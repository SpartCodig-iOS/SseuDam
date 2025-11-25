//
//  SessionUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

public protocol SessionUseCaseProtocol {
  func checkAuthSession(
    sessionId: String
  ) async throws -> SessionEntity
}
