//
//  KeychainManagerProtocol.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation

/// Protocol for keychain operations
/// Provides secure storage for authentication tokens
public protocol KeychainManaging: Sendable {
  /// Save access token to keychain
  func saveAccessToken(_ token: String)

  /// Save refresh token to keychain
  func saveRefreshToken(_ token: String)

  /// Save both tokens atomically
  func saveTokens(accessToken: String?, refreshToken: String?)

  /// Load access token from keychain
  func loadAccessToken() -> String?

  /// Load refresh token from keychain
  func loadRefreshToken() -> String?

  /// Load both tokens
  func loadTokens() -> (accessToken: String?, refreshToken: String?)

  /// Clear all stored tokens
  func clearAll()
}