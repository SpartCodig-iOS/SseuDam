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
    public let session: SessionStatus

    public init(
      shouldSucceed: Bool = true,
      delay: TimeInterval = 0.0,
      session: SessionStatus = SessionStatus(
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

  public func checkSession(sessionId: String) async throws -> SessionStatus {
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    guard configuration.shouldSucceed else {
      throw MockSessionError.sessionInvalid
    }

    let baseSession = configuration.session
    return SessionStatus(
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

  static func withSession(_ session: SessionStatus) -> MockSessionRepository {
    MockSessionRepository(configuration: Configuration(session: session))
  }

  static func withDelay(_ delay: TimeInterval) -> MockSessionRepository {
    MockSessionRepository(configuration: Configuration(delay: delay))
  }
}
