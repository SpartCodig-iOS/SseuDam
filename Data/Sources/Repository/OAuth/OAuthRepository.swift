//
//  OAuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Domain
import Supabase
import LogMacro

public class OAuthRepository: OAuthRepositoryProtocol {
  private let client = SupabaseManager.shared.client
  public init() {}

  public func signIn(
    provider: SocialType,
    idToken: String,
    nonce: String?,
    displayName: String?
  ) async throws -> Supabase.Session {
    let credentials = OpenIDConnectCredentials(
      provider: provider == .apple ? .apple : .google,
      idToken: idToken,
      nonce: nonce
    )

    let session = try await client.auth.signInWithIdToken(credentials: credentials)
    Log.info("\(provider.rawValue) signInWithIdToken completed. \(session.accessToken)")

    try await updateDisplayNameIfNeeded(displayName)
    return session
  }

  public func updateUserDisplayName(_ name: String) async throws {
    try await client.auth.update(
      user: UserAttributes(data: ["display_name": .string(name)])
    )
  }

  // MARK: - Private

  private func updateDisplayNameIfNeeded(_ displayName: String?) async throws {
    guard let displayName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines),
          !displayName.isEmpty
    else { return }

    try await updateUserDisplayName(displayName)
    Log.info("Updated Supabase display_name to \(displayName)")
  }
}
