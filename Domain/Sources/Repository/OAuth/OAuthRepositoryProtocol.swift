//
//  OAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Supabase

public protocol OAuthRepositoryProtocol {
  func signInWithApple(idToken: String, nonce: String, displayName: String?) async throws -> Supabase.Session
  func signInWithGoogle(idToken: String, displayName: String?) async throws -> Supabase.Session
  func updateUserDisplayName(_ name: String) async throws
}
