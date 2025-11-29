//
//  MockOAuthRepository.swift
//  Domain
//
//  Created by Wonji Suh on 11/18/25.
//

import Foundation
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
    public let provider: SocialType

    public init(
      id: UUID = UUID(),
      email: String,
      displayName: String?,
      provider: SocialType
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

  private let configuration: Configuration

  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
  }

  public func signIn(
    provider: SocialType,
    idToken: String,
    nonce: String?,
    displayName: String?,
    authorizationCode: String?
  ) async throws -> UserProfile {
    _ = idToken
    _ = nonce
    return try await performMockSignIn(
      provider: provider,
      displayName: displayName,
      authorizationCode: authorizationCode
    )
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

  }

  public func loginUser(input: OAuthUserInput) async throws -> AuthResult {
    let mockData = AuthResult(
      name: "testter",
      provider: .apple,
      token: .init(authToken: "", accessToken: "", refreshToken: "", sessionID: "")
    )
    return mockData
  }

  public func signUpUser(input: OAuthUserInput) async throws -> AuthResult {
    let mockData = AuthResult(
      name: "testter",
      provider: .apple,
      token: .init(authToken: "", accessToken: "", refreshToken: "", sessionID: "")
    )
    return mockData
  }


  // MARK: - Private Methods
  private func performMockSignIn(
    provider: SocialType,
    displayName: String?,
    authorizationCode: String?
  ) async throws -> UserProfile {
    // Simulate network delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    // Simulate failure if configured
    if !configuration.shouldSucceed {
      throw MockOAuthError.signInFailed(provider)
    }

    let mockUser = createMockUser(provider: provider, displayName: displayName)
    let tokens = AuthTokens(
      authToken: configuration.mockSession.accessToken,
      accessToken: configuration.mockSession.accessToken,
      refreshToken: configuration.mockSession.refreshToken,
      sessionID: configuration.mockSession.user.id.uuidString
    )

    return UserProfile(
      id: mockUser.id.uuidString,
      email: mockUser.email,
      displayName: mockUser.displayName,
      provider: mockUser.provider,
      tokens: tokens,
      authCode: authorizationCode
    )
  }

  private func createMockUser(
    provider: SocialType,
    displayName: String?
  ) -> MockUser {
    let baseUser = configuration.mockSession.user
    let email: String
    let resolvedDisplayName: String?

    switch provider {
    case .apple:
      email = "apple.user@icloud.com"
      resolvedDisplayName = displayName ?? baseUser.displayName ?? "Mock Apple User"
    case .google:
      email = "google.user@gmail.com"
      resolvedDisplayName = displayName ?? baseUser.displayName ?? "Mock Google User"
    case .none:
      email = "anonymous@example.com"
      resolvedDisplayName = displayName ?? baseUser.displayName ?? "Anonymous User"
    }

    return MockUser(
      id: baseUser.id,
      email: email,
      displayName: resolvedDisplayName,
      provider: provider
    )
  }
}

// MARK: - Mock Errors

public enum MockOAuthError: Error, LocalizedError {
  case signInFailed(SocialType)
  case updateDisplayNameFailed(String)

  public var errorDescription: String? {
    switch self {
    case .signInFailed(let provider):
      return "Mock \(provider.rawValue.capitalized) Sign In Error"
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
