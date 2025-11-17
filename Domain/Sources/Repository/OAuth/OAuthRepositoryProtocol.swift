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

private struct UnimplementedOAuthRepository: OAuthRepositoryProtocol {
  func signInWithApple(idToken: String, nonce: String, displayName: String?) async throws -> Supabase.Session {
    fatalError("OAuthRepository dependency has not been provided.")
  }

  func signInWithGoogle(idToken: String, displayName: String?) async throws -> Supabase.Session {
    fatalError("OAuthRepository dependency has not been provided.")
  }

  func updateUserDisplayName(_ name: String) async throws {
    fatalError("OAuthRepository dependency has not been provided.")
  }
}

public struct OAuthRepositoryDependency: DependencyKey {
  public static var liveValue: any OAuthRepositoryProtocol = UnimplementedOAuthRepository()
  public static var previewValue: any OAuthRepositoryProtocol = UnimplementedOAuthRepository()
  public static var testValue: any OAuthRepositoryProtocol = UnimplementedOAuthRepository()
}

public extension DependencyValues {
  var oAuthRepository: any OAuthRepositoryProtocol {
    get { self[OAuthRepositoryDependency.self] }
    set { self[OAuthRepositoryDependency.self] = newValue }
  }
}
