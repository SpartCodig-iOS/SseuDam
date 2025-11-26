//
//  MockSignUpRepository.swift
//  Domain
//
//  Created by Wonji Suh  on 11/26/25.
//

import Foundation
import Dependencies

/// Thread-safe Actor-based Mock implementation of SignUpRepositoryProtocol for testing and preview purposes
public actor MockSignUpRepository: SignUpRepositoryProtocol {
    
    /// Configuration for mock behavior
    public struct Configuration {
        public let shouldSucceed: Bool
        public let delay: TimeInterval
        public let mockCheckResult: MockCheckResult
        public let shouldFailForSpecificProvider: SocialType?
        
        public init(
            shouldSucceed: Bool = true,
            delay: TimeInterval = 0.5,
            mockCheckResult: MockCheckResult = .userRegistered,
            shouldFailForSpecificProvider: SocialType? = nil
        ) {
            self.shouldSucceed = shouldSucceed
            self.delay = delay
            self.mockCheckResult = mockCheckResult
            self.shouldFailForSpecificProvider = shouldFailForSpecificProvider
        }
    }
    
    /// Mock check result scenarios
    public enum MockCheckResult {
        case userRegistered
        case userNotRegistered
        case customResult(Bool)
        
        var isRegistered: Bool {
            switch self {
                case .userRegistered:
                    return true
                case .userNotRegistered:
                    return false
                case .customResult(let registered):
                    return registered
            }
        }
    }
    
    private let configuration: Configuration
    
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - SignUpRepositoryProtocol Implementation
    
    public func checkSignUpUser(input: OAuthCheckUserInput) async throws -> OAuthCheckUser {
        // Simulate network delay
        if configuration.delay > 0 {
            try await Task.sleep(for: .seconds(configuration.delay))
        }
        
        // Simulate failure if configured
        if !configuration.shouldSucceed {
            throw MockSignUpRepositoryError.checkSignUpFailed(input.socialType)
        }
        
        // Simulate provider-specific failure
        if let failProvider = configuration.shouldFailForSpecificProvider,
           failProvider == input.socialType {
            throw MockSignUpRepositoryError.providerSpecificError(input.socialType)
        }
        
        // Return mock result based on configuration
        return OAuthCheckUser(registered: configuration.mockCheckResult.isRegistered)
    }
}

// MARK: - Mock Errors

public enum MockSignUpRepositoryError: Error, LocalizedError {
    case checkSignUpFailed(SocialType)
    case providerSpecificError(SocialType)
    case invalidAccessToken
    case networkError
    
    public var errorDescription: String? {
        switch self {
            case .checkSignUpFailed(let provider):
                return "Mock Check SignUp Failed for \(provider.description)"
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

public extension MockSignUpRepository {
    /// Creates a mock that always succeeds with registered user
    static var registeredUser: MockSignUpRepository {
        MockSignUpRepository(
            configuration: Configuration(
                shouldSucceed: true,
                mockCheckResult: .userRegistered
            )
        )
    }
    
    /// Creates a mock that always succeeds with unregistered user
    static var newUser: MockSignUpRepository {
        MockSignUpRepository(
            configuration: Configuration(
                shouldSucceed: true,
                mockCheckResult: .userNotRegistered
            )
        )
    }
    
    /// Creates a mock that always fails
    static var failure: MockSignUpRepository {
        MockSignUpRepository(
            configuration: Configuration(shouldSucceed: false)
        )
    }
    
    /// Creates a mock with custom delay
    static func withDelay(_ delay: TimeInterval) -> MockSignUpRepository {
        MockSignUpRepository(
            configuration: Configuration(delay: delay)
        )
    }
    
    /// Creates a mock that fails for specific provider
    static func failsForProvider(_ provider: SocialType) -> MockSignUpRepository {
        MockSignUpRepository(
            configuration: Configuration(shouldFailForSpecificProvider: provider)
        )
    }
    
    /// Creates a mock with custom registration result
    static func withRegistrationResult(_ isRegistered: Bool) -> MockSignUpRepository {
        MockSignUpRepository(
            configuration: Configuration(
                mockCheckResult: .customResult(isRegistered)
            )
        )
    }
}
