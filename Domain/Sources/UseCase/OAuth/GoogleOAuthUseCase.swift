//
//  GoogleOAuthUseCase.swift
//  Domain
//
//  Created by Wonji Suh  on 11/17/25.
//

import Dependencies

public protocol GoogleOAuthUseCaseProtocol {
  func signIn() async throws -> GoogleOAuthPayload
}

public struct GoogleOAuthUseCase: GoogleOAuthUseCaseProtocol {
  private let service: GoogleOAuthServicing

  public init(service: GoogleOAuthServicing) {
    self.service = service
  }

  public func signIn() async throws -> GoogleOAuthPayload {
    try await service.signIn()
  }
}

// MARK: - Dependencies

private enum GoogleOAuthUseCaseDependencyKey: DependencyKey {
  static var liveValue: any GoogleOAuthUseCaseProtocol = UnimplementedGoogleOAuthUseCase()
  static var previewValue: any GoogleOAuthUseCaseProtocol = UnimplementedGoogleOAuthUseCase()
  static var testValue: any GoogleOAuthUseCaseProtocol = UnimplementedGoogleOAuthUseCase()
}

public extension DependencyValues {
  var googleOAuthUseCase: any GoogleOAuthUseCaseProtocol {
    get { self[GoogleOAuthUseCaseDependencyKey.self] }
    set { self[GoogleOAuthUseCaseDependencyKey.self] = newValue }
  }
}

private struct UnimplementedGoogleOAuthUseCase: GoogleOAuthUseCaseProtocol {
  func signIn() async throws -> GoogleOAuthPayload {
    fatalError("GoogleOAuthUseCase dependency has not been provided.")
  }
}

