//
//  AppleOAuthServicing.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol AppleOAuthServicing {
  @MainActor
  func signIn() async throws -> AppleOAuthPayload
}

// MARK: - Dependencies
private struct MockAppleOAuthService: AppleOAuthServicing {
  @MainActor
  func signIn() async throws -> AppleOAuthPayload {
    // Mock implementation for testing/preview
    return AppleOAuthPayload(
      idToken: "mock-apple-id-token",
      authorizationCode: "mock-apple-auth-code",
      displayName: "Mock Apple User",
      nonce: "mock-apple-nonce"
    )
  }
}

public struct AppleOAuthServiceDependency: DependencyKey {
  public static var liveValue: any AppleOAuthServicing = MockAppleOAuthService()
  public static var previewValue: any AppleOAuthServicing = MockAppleOAuthService()
  public static var testValue: any AppleOAuthServicing = MockAppleOAuthService()
}

public extension DependencyValues {
  var appleOAuthService: any AppleOAuthServicing {
    get { self[AppleOAuthServiceDependency.self] }
    set { self[AppleOAuthServiceDependency.self] = newValue }
  }
}
