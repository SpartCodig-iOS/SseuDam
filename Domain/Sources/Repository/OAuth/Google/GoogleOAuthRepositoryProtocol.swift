//
//  GoogleOAuthServicing.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol GoogleOAuthRepositoryProtocol {
  func signIn() async throws -> GoogleOAuthPayload
}

// MARK: - Dependencies
public struct GoogleOAuthServiceDependency: DependencyKey {
  public static var liveValue: any GoogleOAuthRepositoryProtocol = MockGoogleOAuthRepository()
  public static var previewValue: any GoogleOAuthRepositoryProtocol = MockGoogleOAuthRepository()
  public static var testValue: any GoogleOAuthRepositoryProtocol = MockGoogleOAuthRepository()
}

public extension DependencyValues {
  var googleOAuthService: any GoogleOAuthRepositoryProtocol {
    get { self[GoogleOAuthServiceDependency.self] }
    set { self[GoogleOAuthServiceDependency.self] = newValue }
  }
}
