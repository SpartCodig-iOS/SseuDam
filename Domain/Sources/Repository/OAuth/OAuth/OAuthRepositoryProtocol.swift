//
//  OAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Supabase
import ComposableArchitecture

public protocol OAuthRepositoryProtocol {
  func signIn(
    provider: SocialType,
    idToken: String,
    nonce: String?,
    displayName: String?
  ) async throws -> Supabase.Session
  func updateUserDisplayName(_ name: String) async throws
}

