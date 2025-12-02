//
//  MockLoginRepository.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation
import Dependencies

/// Thread-safe Actor-based Mock implementation of LoginRepositoryProtocol for testing and preview purposes
public actor MockLoginRepository: LoginRepositoryProtocol {
    /// Configuration for mock behavior
    public struct Configuration {
        public let shouldSucceed: Bool
        public let delay: TimeInterval
        public let mockResult: MockLoginResult
        public let shouldFailForSpecificProvider: SocialType?

        public init(
            shouldSucceed: Bool = true,
            delay: TimeInterval = 0.5,
            mockResult: MockLoginResult = .success,
            shouldFailForSpecificProvider: SocialType? = nil
        ) {
            self.shouldSucceed = shouldSucceed
            self.delay = delay
            self.mockResult = mockResult
            self.shouldFailForSpecificProvider = shouldFailForSpecificProvider
        }
    }

    /// Mock login result scenarios
    public enum MockLoginResult {
        case success
        case appleUser
        case googleUser
        case customUser(name: String, provider: SocialType)

        func createAuthEntity() -> AuthResult {
            switch self {
            case .success:
                return AuthResult(
                  userId: UUID().uuidString,
                  name: "MockUser",
                    provider: .apple,
                    token: AuthTokens(
                        authToken: "mock_auth_token_\(UUID().uuidString.prefix(8))",
                        accessToken: "mock_access_token_\(UUID().uuidString.prefix(8))",
                        refreshToken: "mock_refresh_token_\(UUID().uuidString.prefix(8))",
                        sessionID: "mock_session_\(UUID().uuidString.prefix(8))"
                    )
                )
            case .appleUser:
                return AuthResult(
                  userId: UUID().uuidString,
                  name: "Apple User",
                    provider: .apple,
                    token: AuthTokens(
                        authToken: "mock_apple_auth_token",
                        accessToken: "mock_apple_access_token",
                        refreshToken: "mock_apple_refresh_token",
                        sessionID: "mock_apple_session"
                    )
                )
            case .googleUser:
                return AuthResult(
                  userId: UUID().uuidString,
                  name: "Google User",
                    provider: .google,
                    token: AuthTokens(
                        authToken: "mock_google_auth_token",
                        accessToken: "mock_google_access_token",
                        refreshToken: "mock_google_refresh_token",
                        sessionID: "mock_google_session"
                    )
                )
            case .customUser(let name, let provider):
                return AuthResult(
                  userId: UUID().uuidString,
                  name: name,
                    provider: provider,
                    token: AuthTokens(
                        authToken: "mock_custom_auth_token",
                        accessToken: "mock_custom_access_token",
                        refreshToken: "mock_custom_refresh_token",
                        sessionID: "mock_custom_session"
                    )
                )
            }
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    // MARK: - LoginRepositoryProtocol Implementation

    public func login(input: OAuthUserInput) async throws -> AuthResult {
        // Simulate network delay
        if configuration.delay > 0 {
            try await Task.sleep(for: .seconds(configuration.delay))
        }

        // Simulate failure if configured
        if !configuration.shouldSucceed {
            throw MockLoginRepositoryError.loginFailed(input.socialType)
        }

        // Simulate provider-specific failure
        if let failProvider = configuration.shouldFailForSpecificProvider,
           failProvider == input.socialType {
            throw MockLoginRepositoryError.providerSpecificError(input.socialType)
        }

        // Generate mock result based on provider or configuration
        let authEntity = configuration.mockResult.createAuthEntity()

        // Override provider if input specifies different one
        return AuthResult(
          userId: authEntity.userId,
          name: authEntity.name,
            provider: input.socialType,
            token: AuthTokens(
                authToken: authEntity.token.authToken,
                accessToken: input.accessToken, // Use input access token
                refreshToken: authEntity.token.refreshToken,
                sessionID: authEntity.token.sessionID
            )
        )
    }
}

// MARK: - Mock Errors

public enum MockLoginRepositoryError: Error, LocalizedError {
    case loginFailed(SocialType)
    case providerSpecificError(SocialType)
    case invalidAccessToken
    case networkError

    public var errorDescription: String? {
        switch self {
        case .loginFailed(let provider):
            return "Mock Login Failed for \(provider.description)"
        case .providerSpecificError(let provider):
            return "Mock Provider Specific Error for \(provider.description)"
        case .invalidAccessToken:
            return "Mock Invalid Access Token"
        case .networkError:
            return "Mock Network Error"
        }
    }
}

// MARK: - Convenience Initializers

public extension MockLoginRepository {
    /// Creates a mock that always succeeds with default user
    static var success: MockLoginRepository {
        MockLoginRepository(
            configuration: Configuration(
                shouldSucceed: true,
                mockResult: .success
            )
        )
    }

    /// Creates a mock that always fails
    static var failure: MockLoginRepository {
        MockLoginRepository(
            configuration: Configuration(shouldSucceed: false)
        )
    }

    /// Creates a mock for Apple user scenario
    static var appleUser: MockLoginRepository {
        MockLoginRepository(
            configuration: Configuration(mockResult: .appleUser)
        )
    }

    /// Creates a mock for Google user scenario
    static var googleUser: MockLoginRepository {
        MockLoginRepository(
            configuration: Configuration(mockResult: .googleUser)
        )
    }

    /// Creates a mock with custom delay
    static func withDelay(_ delay: TimeInterval) -> MockLoginRepository {
        MockLoginRepository(
            configuration: Configuration(delay: delay)
        )
    }

    /// Creates a mock that fails for specific provider
    static func failsForProvider(_ provider: SocialType) -> MockLoginRepository {
        MockLoginRepository(
            configuration: Configuration(shouldFailForSpecificProvider: provider)
        )
    }

    /// Creates a mock with custom user
    static func withCustomUser(name: String, provider: SocialType) -> MockLoginRepository {
        MockLoginRepository(
            configuration: Configuration(
                mockResult: .customUser(name: name, provider: provider)
            )
        )
    }
}

// MARK: - Dependencies

extension MockLoginRepository: DependencyKey {
    public static var liveValue: any LoginRepositoryProtocol = MockLoginRepository.success
    public static var previewValue: any LoginRepositoryProtocol = MockLoginRepository.success
    public static var testValue: any LoginRepositoryProtocol = MockLoginRepository.success
}

public extension DependencyValues {
    var mockLoginRepository: MockLoginRepository {
        get {
            if let mock = self[MockLoginRepository.self] as? MockLoginRepository {
                return mock
            }
            return MockLoginRepository.success
        }
        set { self[MockLoginRepository.self] = newValue }
    }
}
