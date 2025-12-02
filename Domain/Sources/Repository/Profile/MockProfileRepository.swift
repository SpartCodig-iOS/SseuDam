//
//  MockProfileRepository.swift
//  Domain
//
//  Created by Wonji Suh  on 12/1/25.
//

import Combine
import Foundation

public actor MockProfileRepository: ProfileRepositoryProtocol {
  public var shouldThrowError = false
  public var errorToThrow: Error = ProfileError.unknown("mock failure")
  public var delay: TimeInterval = 0
  public var mockProfile: Profile?

  public init() {}

  public func getProfile() async throws -> Profile {
    if delay > 0 {
      try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }

    if shouldThrowError {
      throw errorToThrow
    }

    if let profile = mockProfile {
      return profile
    }

    return Profile(
      userId: "mock_user_\(UUID().uuidString.prefix(6))",
      email: "mock@example.com",
      name: "Mock User",
      profileImage: "",
      provider: .google
    )
  }

  // MARK: - Helpers
  public func setupSuccess(profile: Profile? = nil) {
    shouldThrowError = false
    errorToThrow = ProfileError.unknown("mock failure")
    mockProfile = profile
  }

  public func setupFailure(error: Error = ProfileError.unknown("fetch failed")) {
    shouldThrowError = true
    errorToThrow = error
  }

  public func setupDelay(_ delay: TimeInterval) {
    self.delay = delay
  }

  public func editProfile(name: String?, avatarData: Data?, fileName: String?) async throws -> Profile {
    return try await getProfile()
  }
}
