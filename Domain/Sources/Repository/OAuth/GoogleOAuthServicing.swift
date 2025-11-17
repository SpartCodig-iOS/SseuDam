//
//  GoogleOAuthServicing.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol GoogleOAuthServicing {
  @MainActor
  func signIn() async throws -> GoogleOAuthPayload
}

// MARK: - Dependencies

private struct MockGoogleOAuthService: GoogleOAuthServicing {
  @MainActor
  func signIn() async throws -> GoogleOAuthPayload {
    // Mock implementation for testing/preview
    return GoogleOAuthPayload(
      idToken: "mock-google-id-token",
      accessToken: "mock-google-access-token",
      authorizationCode: "mock-google-auth-code",
      displayName: "Mock Google User"
    )
  }
}

public struct GoogleOAuthServiceDependency: DependencyKey {
  public static var liveValue: any GoogleOAuthServicing = MockGoogleOAuthService()
  public static var previewValue: any GoogleOAuthServicing = MockGoogleOAuthService()
  public static var testValue: any GoogleOAuthServicing = MockGoogleOAuthService()
}

public extension DependencyValues {
  var googleOAuthService: any GoogleOAuthServicing {
    get { self[GoogleOAuthServiceDependency.self] }
    set { self[GoogleOAuthServiceDependency.self] = newValue }
  }
}