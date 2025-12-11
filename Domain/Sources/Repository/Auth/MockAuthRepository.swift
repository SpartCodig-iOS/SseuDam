//
//  MockAuthRepository.swift
//  Domain
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public actor MockAuthRepository: AuthRepositoryProtocol {
  // 테스트 시나리오를 위한 설정
  public var shouldThrowError: Bool = false
  public var errorToThrow: Error?
  public var mockTokenResult: TokenResult?
  public var mockCheckUser: OAuthCheckUser = OAuthCheckUser(registered: true, needsTerms: false)
  public var mockLoginResult: AuthResult = AuthResult(
    userId: "mock-user",
    name: "Mock User",
    provider: .google,
    token: AuthTokens(
      authToken: "mock_auth",
      accessToken: "mock_access",
      refreshToken: "mock_refresh",
      sessionID: "mock_session"
    )
  )
  public var mockSignUpResult: AuthResult = AuthResult(
    userId: "mock-user-signup",
    name: "Mock User Signup",
    provider: .google,
    token: AuthTokens(
      authToken: "mock_auth_signup",
      accessToken: "mock_access_signup",
      refreshToken: "mock_refresh_signup",
      sessionID: "mock_session_signup"
    )
  )
  public var mockFinalizeResult: AuthResult = AuthResult(
    userId: "mock-kakao-user",
    name: "Mock Kakao",
    provider: .kakao,
    token: AuthTokens(
      authToken: "mock_kakao_auth",
      accessToken: "mock_kakao_access",
      refreshToken: "mock_kakao_refresh",
      sessionID: "mock_kakao_session"
    )
  )
  public var mockDeviceToken: DeviceToken?
  public var delay: TimeInterval = 0
  private let persistentPendingKey: String = UUID().uuidString

  public init() {}

  public func refresh(token: String) async throws -> TokenResult {
    // 지연 시뮬레이션
    if delay > 0 {
      try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }

    // 에러 시나리오
    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.refreshFailed
    }

    // 커스텀 결과가 있으면 반환
    if let customResult = mockTokenResult {
      return customResult
    }

    // 기본 mock 데이터 반환
    let mockAuthTokens = AuthTokens(
      authToken: "mock_auth_token_\(UUID().uuidString.prefix(8))",
      accessToken: "mock_access_token_\(UUID().uuidString.prefix(8))",
      refreshToken: "mock_refresh_token_\(UUID().uuidString.prefix(8))",
      sessionID: "mock_session_\(UUID().uuidString.prefix(8))"
    )

    return TokenResult(token: mockAuthTokens)
  }

  // MARK: - 테스트 헬퍼 메소드들

  /// 성공 시나리오로 설정
  public func setupSuccess(with customResult: TokenResult? = nil) {
    shouldThrowError = false
    errorToThrow = nil
    mockTokenResult = customResult
  }

  /// 실패 시나리오로 설정
  public func setupFailure(with error: Error = MockAuthError.refreshFailed) {
    shouldThrowError = true
    errorToThrow = error
    mockTokenResult = nil
  }

  /// 지연 시나리오로 설정
  public func setupDelay(_ delay: TimeInterval) {
    self.delay = delay
  }

  /// 모든 설정 초기화
  public func reset() {
    shouldThrowError = false
    errorToThrow = nil
    mockTokenResult = nil
    delay = 0
  }

  /// 특정 토큰 데이터로 설정
  public func setupCustomTokens(
    authToken: String = "custom_auth_token",
    accessToken: String = "custom_access_token",
    refreshToken: String? = "custom_refresh_token",
    sessionID: String = "custom_session_id"
  ) {
    let tokens = AuthTokens(
      authToken: authToken,
      accessToken: accessToken,
      refreshToken: refreshToken,
      sessionID: sessionID
    )
    mockTokenResult = TokenResult(token: tokens)
  }

  public func logout(
    sessionId: String
  ) async throws -> LogoutStatus {
    if delay > 0 {
      try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }

    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.networkError
    }

    return LogoutStatus(revoked: true)
  }

  public func delete() async throws -> AuthDeleteStatus {
    if delay > 0 {
      try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }

    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.networkError
    }

    return AuthDeleteStatus(isDeleted: true)
  }

  public func registerDeviceToken(token: String) async throws -> DeviceToken {
    if delay > 0 {
      try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }

    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.networkError
    }

    if let custom = mockDeviceToken {
      return custom
    }

    return DeviceToken(
      deviceToken: token,
      pendingKey: persistentPendingKey
    )
  }

  public func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser {
    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.networkError
    }
    return mockCheckUser
  }

  public func login(input: OAuthUserInput) async throws -> AuthResult {
    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.networkError
    }
    return mockLoginResult
  }

  public func signUp(input: OAuthUserInput) async throws -> AuthResult {
    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.networkError
    }
    return mockSignUpResult
  }

  public func finalizeKakao(ticket: String) async throws -> AuthResult {
    if shouldThrowError {
      throw errorToThrow ?? MockAuthError.networkError
    }
    return mockFinalizeResult
  }

}

// Mock 전용 에러 타입
public enum MockAuthError: Error, Equatable {
  case refreshFailed
  case invalidToken
  case networkError
}
