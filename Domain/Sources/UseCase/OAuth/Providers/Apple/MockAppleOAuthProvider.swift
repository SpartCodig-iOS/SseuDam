//
//  MockAppleOAuthProvider.swift
//  Domain
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation
import AuthenticationServices

/// Mock implementation for Apple OAuth Provider for testing and previews
public class MockAppleOAuthProvider: AppleOAuthProviderProtocol, @unchecked Sendable {
  public let socialType: SocialType = .apple

  // MARK: - Configuration

  /// Scenarios for testing
  public enum Configuration {
    case success
    case failure(String)
    case invalidCredentials
    case networkError
    case customUser(String)
    case missingIDToken
    case userCancelled
  }

  private var configuration: Configuration = .success
  private(set) var signInWithCredentialCallCount = 0
  private(set) var signUpCallCount = 0
  private var lastCredential: ASAuthorizationAppleIDCredential?
  private var lastNonce: String?

  // MARK: - Initialization

  public init(configuration: Configuration = .success) {
    self.configuration = configuration
  }

  /// Default mock provider
  public static func `default`() -> MockAppleOAuthProvider {
    MockAppleOAuthProvider(configuration: .success)
  }

  /// Convenience constructors
  public static func success() -> MockAppleOAuthProvider {
    MockAppleOAuthProvider(configuration: .success)
  }

  public static func failure(_ message: String = "Mock failure") -> MockAppleOAuthProvider {
    MockAppleOAuthProvider(configuration: .failure(message))
  }

  public static func customUser(_ name: String) -> MockAppleOAuthProvider {
    MockAppleOAuthProvider(configuration: .customUser(name))
  }

  public static func invalidCredentials() -> MockAppleOAuthProvider {
    MockAppleOAuthProvider(configuration: .invalidCredentials)
  }

  public static func networkError() -> MockAppleOAuthProvider {
    MockAppleOAuthProvider(configuration: .networkError)
  }

  // MARK: - Configuration Management

  /// Change configuration dynamically
  public func setConfiguration(_ configuration: Configuration) {
    self.configuration = configuration
    resetCounts()
  }

  /// Reset call counts for testing
  public func resetCounts() {
    signInWithCredentialCallCount = 0
    signUpCallCount = 0
    lastCredential = nil
    lastNonce = nil
  }

  // MARK: - Test Helpers

  /// Get call count for verification
  public func getSignInWithCredentialCallCount() -> Int { signInWithCredentialCallCount }
  public func getSignUpCallCount() -> Int { signUpCallCount }
  public func getLastNonce() -> String? { lastNonce }

  // MARK: - AppleOAuthProviderProtocol Implementation

  public func signInWithCredential(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws -> UserProfile {
    signInWithCredentialCallCount += 1
    lastCredential = credential
    lastNonce = nonce

    // Simulate delay for realistic testing
    try await Task.sleep(for: .milliseconds(100))

    switch configuration {
    case .success:
      return createMockUserProfile(name: "Mock User")

    case .customUser(let name):
      return createMockUserProfile(name: name)

    case .failure(let message):
      throw AuthError.invalidCredential(message)

    case .invalidCredentials:
      throw AuthError.missingIDToken

    case .networkError:
      throw AuthError.networkError("Mock network error")

    case .missingIDToken:
      throw AuthError.missingIDToken

    case .userCancelled:
      throw AuthError.userCancelled
    }
  }

  public func signUp() async throws -> UserProfile {
    signUpCallCount += 1

    // Simulate delay for realistic testing
    try await Task.sleep(for: .milliseconds(100))

    switch configuration {
    case .success:
      return createMockUserProfile(name: "Mock User")

    case .customUser(let name):
      return createMockUserProfile(name: name)

    case .failure(let message):
      throw AuthError.invalidCredential(message)

    case .invalidCredentials:
      throw AuthError.missingIDToken

    case .networkError:
      throw AuthError.networkError("Mock network error")

    case .missingIDToken:
      throw AuthError.missingIDToken

    case .userCancelled:
      throw AuthError.userCancelled
    }
  }

  // MARK: - Private Helpers

  private func createMockUserProfile(name: String) -> UserProfile {
    UserProfile(
      id: UUID().uuidString,
      email: "mock@apple.com",
      displayName: name,
      provider: .apple,
      tokens: AuthTokens(
        authToken: "mock_auth_token",
        accessToken: "mock_access_token",
        refreshToken: "mock_refresh_token",
        sessionID: "mock_session_id"
      )
    )
  }

  /// Create mock credential data for advanced testing scenarios
  public func createMockCredential() -> MockCredential {
    MockCredential()
  }

  // Helper for creating mock ASAuthorizationAppleIDCredential data
  public struct MockCredential {
    public let identityToken = "mock.identity.token".data(using: .utf8)
    public let authorizationCode = "mock.authorization.code".data(using: .utf8)
    public let fullName: PersonNameComponents = {
      var components = PersonNameComponents()
      components.givenName = "Mock"
      components.familyName = "User"
      return components
    }()
  }
}