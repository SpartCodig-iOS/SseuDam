//
//  OAuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Domain
import Supabase
import LogMacro
import Dependencies


public class OAuthRepository: OAuthRepositoryProtocol {
  private let client = SuperBaseManger.shared.client
  public init() {}

  public func signInWithApple(
    idToken: String,
    nonce: String,
    displayName: String?
  ) async throws -> Supabase.Session {
    let credentials = OpenIDConnectCredentials(
      provider: .apple,
      idToken: idToken,
      nonce: nonce
    )
    let session = try await client.auth.signInWithIdToken(credentials: credentials)
    Log.info("Apple signInWithIdToken completed., \(session.accessToken)")

    if let displayName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines), !displayName.isEmpty {
      try await updateUserDisplayName(displayName)
      Log.info("Updated Supabase display_name to \(displayName)")
    }

    return session
  }

  public func signInWithGoogle(
    idToken: String,
    displayName: String?
  ) async throws -> Auth.Session {
    let credentials = OpenIDConnectCredentials(
      provider: .google,
      idToken: idToken
    )
     let session = try await client.auth.signInWithIdToken(credentials: credentials) 
    Log.debug("Google signInWithIdToken completed. , \(session.accessToken)")

    if let displayName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines), !displayName.isEmpty {
      try await updateUserDisplayName(displayName)
      Log.info("Updated Supabase display_name to \(displayName)")
    }
    return session
  }
  
  public func updateUserDisplayName(_ name: String) async throws {
    try await client.auth.update(
      user: UserAttributes(data: ["display_name": .string(name)])
    )
  }
}

