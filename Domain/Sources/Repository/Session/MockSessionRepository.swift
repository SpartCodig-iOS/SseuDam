//
//  MockSessionRepository.swift
//  Domain
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation
import Dependencies

public struct MockSessionRepository: SessionRepositoryProtocol {
  public struct Configuration {
    public let shouldSucceed: Bool
    public let delay: TimeInterval
    public let session: SessionEntity

    public init(
      shouldSucceed: Bool = true,
      delay: TimeInterval = 0.0,
      session: SessionEntity = SessionEntity(
        provider: .apple,
        sessionId: "mock-session-id",
        status: "active"
      )
    ) {
      self.shouldSucceed = shouldSucceed
      self.delay = delay
      self.session = session
    }
  }

  private let configuration: Configuration

  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
  }

  public func checkLoginSession(sessionId: String) async throws -> SessionEntity {
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    guard configuration.shouldSucceed else {
      throw MockSessionError.sessionInvalid
    }

    let baseSession = configuration.session
    return SessionEntity(
      provider: baseSession.provider,
      sessionId: sessionId.isEmpty ? baseSession.sessionId : sessionId,
      status: baseSession.status
    )
  }
}

// MARK: - Mock Errors

public enum MockSessionError: Error, LocalizedError {
  case sessionInvalid

  public var errorDescription: String? {
    switch self {
    case .sessionInvalid:
      return "Mock session validation failed"
    }
  }
}

// MARK: - Convenience Initializers

public extension MockSessionRepository {
  static var success: MockSessionRepository {
    MockSessionRepository(configuration: Configuration(shouldSucceed: true))
  }

  static var failure: MockSessionRepository {
    MockSessionRepository(configuration: Configuration(shouldSucceed: false))
  }

  static func withSession(_ session: SessionEntity) -> MockSessionRepository {
    MockSessionRepository(configuration: Configuration(session: session))
  }

  static func withDelay(_ delay: TimeInterval) -> MockSessionRepository {
    MockSessionRepository(configuration: Configuration(delay: delay))
  }
}

// MARK: - Dependencies

extension MockSessionRepository: DependencyKey {
  public static var liveValue: any SessionRepositoryProtocol = MockSessionRepository.success
  public static var previewValue: any SessionRepositoryProtocol = MockSessionRepository.success
  public static var testValue: any SessionRepositoryProtocol = MockSessionRepository.success
}

public extension DependencyValues {
  var mockSessionRepository: MockSessionRepository {
    get {
      if let mock = self[MockSessionRepository.self] as? MockSessionRepository {
        return mock
      }
      return MockSessionRepository.success
    }
    set { self[MockSessionRepository.self] = newValue }
  }
}
