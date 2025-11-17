//
//  AppleOAuthProtocol.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Dependencies

public protocol AppleOAuthProtocol {
  func signIn() async throws -> AppleOAuthPayload
}

// MARK: - Dependencies
public struct AppleOAuthServiceDependency: DependencyKey {
  public static var liveValue:  AppleOAuthProtocol = MockAppleOAuthRepository()
  public static var previewValue:  AppleOAuthProtocol = MockAppleOAuthRepository()
  public static var testValue:  AppleOAuthProtocol = MockAppleOAuthRepository()
}

public extension DependencyValues {
  var appleOAuthService:  AppleOAuthProtocol {
    get { self[AppleOAuthServiceDependency.self] }
    set { self[AppleOAuthServiceDependency.self] = newValue }
  }
}
