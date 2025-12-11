//
//  AuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public protocol AuthRepositoryProtocol {
  // 세션/토큰
  func refresh(token: String) async throws -> TokenResult
  func logout(sessionId: String) async throws -> LogoutStatus
  func delete() async throws -> AuthDeleteStatus
  func registerDeviceToken(token: String)  async throws -> DeviceToken

  // 인증/가입
  func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser
  func login(input: OAuthUserInput) async throws -> AuthResult
  func signUp(input: OAuthUserInput) async throws -> AuthResult
  func finalizeKakao(ticket: String) async throws -> AuthResult
}
