//
//  MockGoogleOAuthProvider.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation

/// Mock implementation for Google OAuth Provider for testing and previews
public class MockGoogleOAuthProvider: GoogleOAuthProviderProtocol, @unchecked Sendable {
  public let socialType: SocialType = .google

  // MARK: - Configuration

  /// Scenarios for testing
  public enum Configuration {
    case success
    case failure(String)
    case invalidCredentials
    case networkError
    case customUser(String)
    case userCancelled
    case configurationMissing
  }

  private var configuration: Configuration = .success
  private(set) var signUpCallCount = 0
  private var lastRepository: String? // For testing repository injection

  // MARK: - Initialization

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

  /// Default mock provider
  public static func `default`() -> MockGoogleOAuthProvider {
    MockGoogleOAuthProvider(configuration: .success)
  }

  /// Convenience constructors
  public static func success() -> MockGoogleOAuthProvider {
    MockGoogleOAuthProvider(configuration: .success)
  }

  public static func failure(_ message: String = "Mock failure") -> MockGoogleOAuthProvider {
    MockGoogleOAuthProvider(configuration: .failure(message))
  }

  public static func customUser(_ name: String) -> MockGoogleOAuthProvider {
    MockGoogleOAuthProvider(configuration: .customUser(name))
  }

  public static func invalidCredentials() -> MockGoogleOAuthProvider {
    MockGoogleOAuthProvider(configuration: .invalidCredentials)
  }

  public static func networkError() -> MockGoogleOAuthProvider {
    MockGoogleOAuthProvider(configuration: .networkError)
  }

  // MARK: - Configuration Management

  /// Change configuration dynamically
  public func setConfiguration(_ configuration: Configuration) {
    self.configuration = configuration
    resetCounts()
  }

  /// Reset call counts for testing
  public func resetCounts() {
    signUpCallCount = 0
    lastRepository = nil
  }

  // MARK: - Test Helpers

  /// Get call count for verification
  public func getSignUpCallCount() -> Int { signUpCallCount }
  public func getLastRepository() -> String? { lastRepository }

  // MARK: - GoogleOAuthProviderProtocol Implementation

  public func signUp() async throws -> UserProfile {
    signUpCallCount += 1
    lastRepository = "GoogleOAuthRepository"

    // Simulate delay for realistic testing
    try await Task.sleep(for: .milliseconds(100))

    switch configuration {
    case .success:
      return createMockUserProfile(name: "Mock Google User")

    case .customUser(let name):
      return createMockUserProfile(name: name)

    case .failure(let message):
      throw AuthError.invalidCredential(message)

    case .invalidCredentials:
      throw AuthError.invalidCredential("Google credentials invalid")

    case .networkError:
      throw AuthError.networkError("Google network error")

    case .userCancelled:
      throw AuthError.userCancelled

    case .configurationMissing:
      throw AuthError.configurationMissing
    }
  }

  // MARK: - Private Helpers

  private func createMockUserProfile(name: String) -> UserProfile {
    UserProfile(
      id: UUID().uuidString,
      email: "\(name.lowercased())@gmail.com",
      displayName: name,
      provider: .google,
      tokens: AuthTokens(
        authToken: "mock_auth_token",
        accessToken: "mock_access_token",
        refreshToken: "mock_refresh_token",
        sessionID: "mock_session_id"
      )
    )
  }

  /// Create mock Google payload data for testing
  public func createMockGooglePayload() -> MockGooglePayload {
    MockGooglePayload()
  }

  // Helper for creating mock Google OAuth data
  public struct MockGooglePayload {
    public let idToken = "mock.google.id.token"
    public let authorizationCode = "mock.google.auth.code"
    public let displayName = "Mock Google User"
    public let email = "mockuser@gmail.com"
    public let profileImageURL = "https://lh3.googleusercontent.com/a/mock-profile-image"
  }
}