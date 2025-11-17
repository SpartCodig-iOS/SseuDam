//
//  GoogleOAuthServicing.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol GoogleOAuthProtocol {
  func signIn() async throws -> GoogleOAuthPayload
}

// MARK: - Dependencies
public struct GoogleOAuthServiceDependency: DependencyKey {
  public static var liveValue: any GoogleOAuthProtocol = MockGoogleOAuthRepository()
  public static var previewValue: any GoogleOAuthProtocol = MockGoogleOAuthRepository()
  public static var testValue: any GoogleOAuthProtocol = MockGoogleOAuthRepository()
}

public extension DependencyValues {
  var googleOAuthService: any GoogleOAuthProtocol {
    get { self[GoogleOAuthServiceDependency.self] }
    set { self[GoogleOAuthServiceDependency.self] = newValue }
  }
}
