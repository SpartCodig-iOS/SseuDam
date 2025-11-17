//
//  MockOAuthRepository.swift
//  Domain
//
//  Created by Wonji Suh on 11/18/25.
//

import Foundation
import Supabase
import Dependencies

/// Mock implementation of OAuthRepositoryProtocol for testing and preview purposes
public struct MockOAuthRepository: OAuthRepositoryProtocol {

  /// Configuration for mock behavior
  public struct Configuration {
    public let shouldSucceed: Bool
    public let delay: TimeInterval
    public let mockSession: MockSession
    public let shouldFailOnUpdate: Bool

    public init(
      shouldSucceed: Bool = true,
      delay: TimeInterval = 1.0,
      mockSession: MockSession = .default,
      shouldFailOnUpdate: Bool = false
    ) {
      self.shouldSucceed = shouldSucceed
      self.delay = delay
      self.mockSession = mockSession
      self.shouldFailOnUpdate = shouldFailOnUpdate
    }
  }

  /// Mock session data
  public struct MockSession {
    public let user: MockUser
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: Int

    public init(
      user: MockUser,
      accessToken: String = "mock-access-token",
      refreshToken: String = "mock-refresh-token",
      tokenType: String = "bearer",
      expiresIn: Int = 3600
    ) {
      self.user = user
      self.accessToken = accessToken
      self.refreshToken = refreshToken
      self.tokenType = tokenType
      self.expiresIn = expiresIn
    }

    public static let `default` = MockSession(
      user: .default
    )

    public static let appleUser = MockSession(
      user: .appleUser,
      accessToken: "mock-apple-access-token"
    )

    public static let googleUser = MockSession(
      user: .googleUser,
      accessToken: "mock-google-access-token"
    )
  }

  /// Mock user data
  public struct MockUser {
    public let id: UUID
    public let email: String
    public let displayName: String?
    public let provider: AuthProvider

    public init(
      id: UUID = UUID(),
      email: String,
      displayName: String?,
      provider: AuthProvider
    ) {
      self.id = id
      self.email = email
      self.displayName = displayName
      self.provider = provider
    }

    public static let `default` = MockUser(
      email: "mock@example.com",
      displayName: "Mock User",
      provider: .apple
    )

    public static let appleUser = MockUser(
      email: "apple.user@icloud.com",
      displayName: "Apple User",
      provider: .apple
    )

    public static let googleUser = MockUser(
      email: "google.user@gmail.com",
      displayName: "Google User",
      provider: .google
    )

    public static let anonymousUser = MockUser(
      email: "anonymous@example.com",
      displayName: nil,
      provider: .apple
    )
  }

  public enum AuthProvider {
    case apple
    case google
  }

  private let configuration: Configuration

  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
  }

  public func signInWithApple(
    idToken: String,
    nonce: String,
    displayName: String?
  ) async throws -> Supabase.Session {
    return try await performMockSignIn(provider: .apple, displayName: displayName)
  }

  public func signInWithGoogle(
    idToken: String,
    displayName: String?
  ) async throws -> Supabase.Session {
    return try await performMockSignIn(provider: .google, displayName: displayName)
  }

  public func updateUserDisplayName(_ name: String) async throws {
    // Simulate network delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay * 0.5)) // Shorter delay for update
    }

    // Simulate failure if configured
    if configuration.shouldFailOnUpdate {
      throw MockOAuthError.updateDisplayNameFailed("Mock update display name failed")
    }

    // Success case - do nothing (mock implementation)
  }

  // MARK: - Private Methods

  private func performMockSignIn(
    provider: AuthProvider,
    displayName: String?
  ) async throws -> Supabase.Session {
    // Simulate network delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    // Simulate failure if configured
    if !configuration.shouldSucceed {
      switch provider {
      case .apple:
        throw MockOAuthError.appleSignInFailed("Mock Apple Sign In failed")
      case .google:
        throw MockOAuthError.googleSignInFailed("Mock Google Sign In failed")
      }
    }

    // Create mock Supabase.User
    let mockUser = createMockSupabaseUser(
      provider: provider,
      displayName: displayName
    )

    // Create mock Supabase.Session
    return Supabase.Session(
      accessToken: configuration.mockSession.accessToken,
      tokenType: configuration.mockSession.tokenType,
      expiresIn: TimeInterval(configuration.mockSession.expiresIn),
      expiresAt: Date().addingTimeInterval(TimeInterval(configuration.mockSession.expiresIn)).timeIntervalSince1970,
      refreshToken: configuration.mockSession.refreshToken,
      user: mockUser
    )
  }

  private func createMockSupabaseUser(
    provider: AuthProvider,
    displayName: String?
  ) -> Supabase.User {
    let email = provider == .apple ? "apple.user@icloud.com" : "google.user@gmail.com"
    let finalDisplayName = displayName ?? (provider == .apple ? "Apple User" : "Google User")

    return Supabase.User(
      id: configuration.mockSession.user.id,
      appMetadata: ["provider": AnyJSON.string(provider == .apple ? "apple" : "google")],
      userMetadata: ["display_name": AnyJSON.string(finalDisplayName)],
      aud: email,
      confirmationSentAt: nil,
      recoverySentAt: nil,
      emailChangeSentAt: nil,
      newEmail: nil,
      invitedAt: nil,
      actionLink: nil,
      email: email,
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
  }
}

// MARK: - Mock Errors

public enum MockOAuthError: Error, LocalizedError {
  case appleSignInFailed(String)
  case googleSignInFailed(String)
  case updateDisplayNameFailed(String)

  public var errorDescription: String? {
    switch self {
    case .appleSignInFailed(let message):
      return "Mock Apple Sign In Error: \(message)"
    case .googleSignInFailed(let message):
      return "Mock Google Sign In Error: \(message)"
    case .updateDisplayNameFailed(let message):
      return "Mock Update Display Name Error: \(message)"
    }
  }
}

// MARK: - Convenience Initializers

public extension MockOAuthRepository {
  /// Creates a mock that always succeeds
  static var success: MockOAuthRepository {
    MockOAuthRepository(
      configuration: Configuration(shouldSucceed: true)
    )
  }

  /// Creates a mock that always fails
  static var failure: MockOAuthRepository {
    MockOAuthRepository(
      configuration: Configuration(shouldSucceed: false)
    )
  }

  /// Creates a mock with specific session data
  static func withSession(_ session: MockSession) -> MockOAuthRepository {
    MockOAuthRepository(
      configuration: Configuration(mockSession: session)
    )
  }

  /// Creates a mock with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockOAuthRepository {
    MockOAuthRepository(
      configuration: Configuration(delay: delay)
    )
  }

  /// Creates a mock that succeeds for sign-in but fails for updates
  static var failsOnUpdate: MockOAuthRepository {
    MockOAuthRepository(
      configuration: Configuration(shouldFailOnUpdate: true)
    )
  }

  /// Creates a mock for Apple user scenario
  static var appleUserScenario: MockOAuthRepository {
    MockOAuthRepository(
      configuration: Configuration(mockSession: .appleUser)
    )
  }

  /// Creates a mock for Google user scenario
  static var googleUserScenario: MockOAuthRepository {
    MockOAuthRepository(
      configuration: Configuration(mockSession: .googleUser)
    )
  }
}

// MARK: - Dependencies

extension MockOAuthRepository: DependencyKey {
  public static var liveValue: any OAuthRepositoryProtocol = MockOAuthRepository.success
  public static var previewValue: any OAuthRepositoryProtocol = MockOAuthRepository.success
  public static var testValue: any OAuthRepositoryProtocol = MockOAuthRepository.success
}

public extension DependencyValues {
  var mockOAuthRepository: MockOAuthRepository {
    get {
      if let mock = self[MockOAuthRepository.self] as? MockOAuthRepository {
        return mock
      }
      return MockOAuthRepository.success
    }
    set { self[MockOAuthRepository.self] = newValue }
  }
}
