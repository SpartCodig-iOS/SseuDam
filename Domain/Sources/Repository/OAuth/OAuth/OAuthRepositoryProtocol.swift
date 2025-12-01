//
//  OAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import ComposableArchitecture

public protocol OAuthRepositoryProtocol {
  func signIn(
    provider: SocialType,
    idToken: String,
    nonce: String?,
    displayName: String?,
    authorizationCode: String?
  ) async throws -> UserProfile
  func updateUserDisplayName(_ name: String) async throws
}
