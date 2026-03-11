//
//  InMemoryKeychainManager.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation

// Import the protocol from the same module
// In a real project structure, this would be handled by module imports

/// In-Memory implementation for KeychainManaging protocol
/// Used for testing and SwiftUI previews
public actor InMemoryKeychainManager: KeychainManaging {
  private var accessTokenStorage: String?
  private var refreshTokenStorage: String?

  // MARK: - Test helpers
  private(set) var saveAccessTokenCallCount = 0
  private(set) var saveRefreshTokenCallCount = 0
  private(set) var saveTokensCallCount = 0
  private(set) var clearAllCallCount = 0

  public init() {}

  // MARK: - KeychainManaging Implementation

  public func saveAccessToken(_ token: String) async {
    accessTokenStorage = token
    saveAccessTokenCallCount += 1
  }

  public func saveRefreshToken(_ token: String) async {
    refreshTokenStorage = token
    saveRefreshTokenCallCount += 1
  }

  public func saveTokens(accessToken: String?, refreshToken: String?) async {
    if let accessToken {
      accessTokenStorage = accessToken
    }
    if let refreshToken {
      refreshTokenStorage = refreshToken
    }
    saveTokensCallCount += 1
  }

  public func loadAccessToken() async -> String? {
    return accessTokenStorage
  }

  public func loadRefreshToken() async -> String? {
    return refreshTokenStorage
  }

  public func loadTokens() async -> (accessToken: String?, refreshToken: String?) {
    return (accessTokenStorage, refreshTokenStorage)
  }

  public func clearAll() async {
    accessTokenStorage = nil
    refreshTokenStorage = nil
    clearAllCallCount += 1
  }

  // MARK: - Test Helpers

  /// Reset all call counts for testing
  public func resetCounts() async {
    saveAccessTokenCallCount = 0
    saveRefreshTokenCallCount = 0
    saveTokensCallCount = 0
    clearAllCallCount = 0
  }

  /// Check if tokens are stored
  public var hasStoredTokens: Bool {
    return accessTokenStorage != nil && refreshTokenStorage != nil
  }

  /// Preload tokens for testing
  public func preloadTokens(accessToken: String, refreshToken: String) async {
    accessTokenStorage = accessToken
    refreshTokenStorage = refreshToken
  }

  /// Verify specific tokens are saved
  public func verifyTokensSaved(accessToken: String, refreshToken: String) async -> Bool {
    return accessTokenStorage == accessToken && refreshTokenStorage == refreshToken
  }

  /// Get all call counts for verification
  public func getAllCallCounts() async -> (saveAccessToken: Int, saveRefreshToken: Int, saveTokens: Int, clearAll: Int) {
    return (saveAccessTokenCallCount, saveRefreshTokenCallCount, saveTokensCallCount, clearAllCallCount)
  }
}