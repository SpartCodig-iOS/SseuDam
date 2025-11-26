//
//  AppleOAuthProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol AppleOAuthRepositoryProtocol {
  func signIn() async throws -> AppleOAuthPayload
}

// MARK: - Dependencies
public struct AppleOAuthServiceDependency: DependencyKey {
  public static var liveValue:  AppleOAuthRepositoryProtocol = MockAppleOAuthRepository()
  public static var previewValue:  AppleOAuthRepositoryProtocol = MockAppleOAuthRepository()
  public static var testValue:  AppleOAuthRepositoryProtocol = MockAppleOAuthRepository()
}

public extension DependencyValues {
  var appleOAuthService:  AppleOAuthRepositoryProtocol {
    get { self[AppleOAuthServiceDependency.self] }
    set { self[AppleOAuthServiceDependency.self] = newValue }
  }
}
