//
//  MockVersionRepository.swift
//  Domain
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation
import Dependencies

/// Thread-safe mock implementation for VersionRepositoryProtocol.
public actor MockVersionRepository: VersionRepositoryProtocol {
  public struct Configuration {
    public let shouldSucceed: Bool
    public let delay: TimeInterval
    public let version: Version
    public let error: Error?

    public init(
      shouldSucceed: Bool = true,
      delay: TimeInterval = 0.0,
      version: Version = Version(message: "최신 버전입니다.", shouldUpdate: false, appStoreUrl: "", version: "1.0.0"),
      error: Error? = nil
    ) {
      self.shouldSucceed = shouldSucceed
      self.delay = delay
      self.version = version
      self.error = error
    }
  }

  private let configuration: Configuration

  public init(configuration: Configuration = Configuration()) {
    self.configuration = configuration
  }

  public func getVersion(bundleId: String, version: String) async throws -> Version {
    if configuration.delay > 0 {
      try await Task.sleep(for: .seconds(configuration.delay))
    }

    guard configuration.shouldSucceed else {
      throw configuration.error ?? MockVersionRepositoryError.fetchFailed
    }

    return configuration.version
  }
}

// MARK: - Errors

public enum MockVersionRepositoryError: Error, LocalizedError {
  case fetchFailed

  public var errorDescription: String? {
    switch self {
    case .fetchFailed:
      return "Mock 버전 정보 조회 실패"
    }
  }
}

// MARK: - Convenience factories

public extension MockVersionRepository {
  static var success: MockVersionRepository {
    MockVersionRepository()
  }

  static var needsUpdate: MockVersionRepository {
    MockVersionRepository(
      configuration: Configuration(
        version: Version(
          message: "업데이트가 필요합니다.",
          shouldUpdate: true,
          appStoreUrl: "",
          version: "1.0.0"
        )
      )
    )
  }

  static var failure: MockVersionRepository {
    MockVersionRepository(
      configuration: Configuration(
        shouldSucceed: false,
        error: MockVersionRepositoryError.fetchFailed
      )
    )
  }

  static func withDelay(_ delay: TimeInterval, version: Version? = nil) -> MockVersionRepository {
    MockVersionRepository(
      configuration: Configuration(
        delay: delay,
        version: version ?? Configuration().version
      )
    )
  }
}

// MARK: - Dependencies

extension MockVersionRepository: DependencyKey {
  public static var liveValue: any VersionRepositoryProtocol = MockVersionRepository.success
  public static var previewValue: any VersionRepositoryProtocol = MockVersionRepository.success
  public static var testValue: any VersionRepositoryProtocol = MockVersionRepository.success
}

public extension DependencyValues {
  var mockVersionRepository: MockVersionRepository {
    get {
      if let mock = self[MockVersionRepository.self] as? MockVersionRepository {
        return mock
      }
      return MockVersionRepository.success
    }
    set { self[MockVersionRepository.self] = newValue }
  }
}
