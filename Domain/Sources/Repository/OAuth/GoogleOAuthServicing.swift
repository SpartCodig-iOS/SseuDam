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

private struct UnimplementedGoogleOAuthService: GoogleOAuthServicing {
  @MainActor
  func signIn() async throws -> GoogleOAuthPayload {
    fatalError("GoogleOAuthService dependency has not been provided.")
  }
}

public struct GoogleOAuthServiceDependency: DependencyKey {
  public static var liveValue: any GoogleOAuthServicing = UnimplementedGoogleOAuthService()
  public static var previewValue: any GoogleOAuthServicing = UnimplementedGoogleOAuthService()
  public static var testValue: any GoogleOAuthServicing = UnimplementedGoogleOAuthService()
}

public extension DependencyValues {
  var googleOAuthService: any GoogleOAuthServicing {
    get { self[GoogleOAuthServiceDependency.self] }
    set { self[GoogleOAuthServiceDependency.self] = newValue }
  }
}