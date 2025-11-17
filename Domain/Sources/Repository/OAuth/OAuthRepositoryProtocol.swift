//
//  OAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Supabase
import Dependencies

public protocol OAuthRepositoryProtocol {
  func signInWithApple(idToken: String, nonce: String, displayName: String?) async throws -> Supabase.Session
  func signInWithGoogle(idToken: String, displayName: String?) async throws -> Supabase.Session
  func updateUserDisplayName(_ name: String) async throws
}

// MARK: - Dependencies

private struct MockOAuthRepository: OAuthRepositoryProtocol {
  func signInWithApple(idToken: String, nonce: String, displayName: String?) async throws -> Supabase.Session {
    // Mock implementation - create a fake session
    let mockUser = Supabase.User(
      id: UUID(),
      appMetadata: [:],
      userMetadata: [:],
      aud: "apple.user@example.com",
      confirmationSentAt: nil,
      recoverySentAt: nil,
      emailChangeSentAt: nil,
      newEmail: nil,
      invitedAt: nil,
      actionLink: nil,
      email: "apple.user@example.com",
      phone: nil,
      createdAt: Date(),
      confirmedAt: Date(),
      emailConfirmedAt: Date(),
      phoneConfirmedAt: nil,
      lastSignInAt: Date(),
      role: "authenticated",
      updatedAt: Date(),
      identities: [],
      isAnonymous: false,
      factors: nil
    )

    return Supabase.Session(
      accessToken: "mock-access-token",
      tokenType: "bearer",
      expiresIn: 3600,
      expiresAt: Date().addingTimeInterval(3600).timeIntervalSince1970,
      refreshToken: "mock-refresh-token",
      user: mockUser
    )
  }

  func signInWithGoogle(idToken: String, displayName: String?) async throws -> Supabase.Session {
    // Mock implementation - create a fake session
    let mockUser = Supabase.User(
      id: UUID(),
      appMetadata: [:],
      userMetadata: [:],
      aud: "google.user@example.com",
      confirmationSentAt: nil,
      recoverySentAt: nil,
      emailChangeSentAt: nil,
      newEmail: nil,
      invitedAt: nil,
      actionLink: nil,
      email: "google.user@example.com",
      phone: nil,
      createdAt: Date(),
      confirmedAt: Date(),
      emailConfirmedAt: Date(),
      phoneConfirmedAt: nil,
      lastSignInAt: Date(),
      role: "authenticated",
      updatedAt: Date(),
      identities: [],
      isAnonymous: false,
      factors: nil
    )

    return Supabase.Session(
      accessToken: "mock-access-token",
      tokenType: "bearer",
      expiresIn: 3600,
      expiresAt: Date().addingTimeInterval(3600).timeIntervalSince1970,
      refreshToken: "mock-refresh-token",
      user: mockUser
    )
  }

  func updateUserDisplayName(_ name: String) async throws {
    // Mock implementation - do nothing
  }
}

public struct OAuthRepositoryDependency: DependencyKey {
  public static var liveValue: any OAuthRepositoryProtocol = MockOAuthRepository()
  public static var previewValue: any OAuthRepositoryProtocol = MockOAuthRepository()
  public static var testValue: any OAuthRepositoryProtocol = MockOAuthRepository()
}

public extension DependencyValues {
  var oAuthRepository: any OAuthRepositoryProtocol {
    get { self[OAuthRepositoryDependency.self] }
    set { self[OAuthRepositoryDependency.self] = newValue }
  }
}
