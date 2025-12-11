//
//  AuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public protocol AuthRepositoryProtocol {
  func refresh(token: String) async throws -> TokenResult
  func logout(sessionId: String) async throws -> LogoutStatus
  func delete() async throws -> AuthDeleteStatus
  func registerDeviceToken(token: String)  async throws -> DeviceToken
}
