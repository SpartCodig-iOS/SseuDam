//
//  MockAppleOAuthRepository.swift
//  Domain
//
//  Created by Wonji Suh on 11/18/25.
//

import Foundation
import Dependencies

/// Mock implementation of AppleOAuthProtocol for testing and preview purposes
public struct MockAppleOAuthRepository: AppleOAuthRepositoryProtocol {

  /// Configuration for mock behavior
  public struct Configuration {
    public let shouldSucceed: Bool
    public let delay: TimeInterval
    public let mockUser: MockUser

    public init(
      shouldSucceed: Bool = true,
      delay: TimeInterval = 1.0,
      mockUser: MockUser = .default
    ) {
      self.shouldSucceed = shouldSucceed
      self.delay = delay
      self.mockUser = mockUser
    }
  }

  /// Mock user data
  public struct MockUser {
    public let displayName: String
    public let idToken: String
    public let authorizationCode: String?
    public let nonce: String

    public init(
      displayName: String,
      idToken: String,
      authorizationCode: String?,
      nonce: String
    ) {
      self.displayName = displayName
      self.idToken = idToken
      self.authorizationCode = authorizationCode
      self.nonce = nonce
    }

    public static let `default` = MockUser(
      displayName: "Mock Apple User",
      idToken: "mock-apple-id-token-12345",
      authorizationCode: "mock-apple-auth-code-67890",
      nonce: "mock-apple-nonce-abcdef"
    )

    public static let johnDoe = MockUser(
      displayName: "John Doe",
      idToken: "mock-apple-id-token-john-doe",
      authorizationCode: "mock-apple-auth-code-john",
      nonce: "mock-apple-nonce-john"
    )

    public static let anonymous = MockUser(
      displayName: "",
      idToken: "mock-apple-id-token-anonymous",
      authorizationCode: nil,
      nonce: "mock-apple-nonce-anonymous"
    )
  }

  private let configuration: Configuration

  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
  }

  @MainActor
  public func signIn() async throws -> AppleOAuthPayload {
    // Simulate network delay
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    // Simulate failure if configured
    if !configuration.shouldSucceed {
      throw AuthError.invalidCredential("Mock Apple Sign In failed")
    }

    // Return mock payload
    return AppleOAuthPayload(
      idToken: configuration.mockUser.idToken,
      authorizationCode: configuration.mockUser.authorizationCode,
      displayName: configuration.mockUser.displayName.isEmpty ? nil : configuration.mockUser.displayName,
      nonce: configuration.mockUser.nonce
    )
  }
}

// MARK: - Convenience Initializers

public extension MockAppleOAuthRepository {
  /// Creates a mock that always succeeds with default user
  static var success: MockAppleOAuthRepository {
    MockAppleOAuthRepository(
      configuration: Configuration(shouldSucceed: true)
    )
  }

  /// Creates a mock that always fails
  static var failure: MockAppleOAuthRepository {
    MockAppleOAuthRepository(
      configuration: Configuration(shouldSucceed: false)
    )
  }

  /// Creates a mock with specific user
  static func withUser(_ user: MockUser) -> MockAppleOAuthRepository {
    MockAppleOAuthRepository(
      configuration: Configuration(mockUser: user)
    )
  }

  /// Creates a mock with custom delay
  static func withDelay(_ delay: TimeInterval) -> MockAppleOAuthRepository {
    MockAppleOAuthRepository(
      configuration: Configuration(delay: delay)
    )
  }
}

// MARK: - Dependencies

extension MockAppleOAuthRepository: DependencyKey {
  public static var liveValue: any AppleOAuthRepositoryProtocol = MockAppleOAuthRepository.success
  public static var previewValue: any AppleOAuthRepositoryProtocol = MockAppleOAuthRepository.success
  public static var testValue: any AppleOAuthRepositoryProtocol = MockAppleOAuthRepository.success
}

public extension DependencyValues {
  var mockAppleOAuthRepository: MockAppleOAuthRepository {
    get {
      if let mock = self[MockAppleOAuthRepository.self] as? MockAppleOAuthRepository {
        return mock
      }
      return MockAppleOAuthRepository.success
    }
    set { self[MockAppleOAuthRepository.self] = newValue }
  }
}
