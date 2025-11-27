//
//  SessionUseCaseProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

public protocol SessionUseCaseProtocol {
  func checkSession(
    sessionId: String
  ) async throws -> SessionResult
}
