//
//  OAuthRepositoryProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Supabase
import ComposableArchitecture
import NetworkService

public protocol OAuthRepositoryProtocol {
  func signIn(
    provider: SocialType,
    idToken: String,
    nonce: String?,
    displayName: String?
  ) async throws -> Supabase.Session
  func updateUserDisplayName(_ name: String) async throws
  func checkSignUpUser(input: OAuthCheckUserInput) async throws -> OAuthCheckUser
}

// MARK: - Dependencies


public struct OAuthRepositoryDependency: DependencyKey {
  public static var liveValue: OAuthRepositoryProtocol = MockOAuthRepository()
  public static var previewValue: OAuthRepositoryProtocol = MockOAuthRepository()
  public static var testValue: OAuthRepositoryProtocol = MockOAuthRepository()
}

public extension DependencyValues {
  var oAuthRepository:  OAuthRepositoryProtocol {
    get { self[OAuthRepositoryDependency.self] }
    set { self[OAuthRepositoryDependency.self] = newValue }
  }
}
