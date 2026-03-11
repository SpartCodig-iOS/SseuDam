//
//  AuthSessionManager.swift
//  Data
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation
import Alamofire
import Domain
import LogMacro

final class AuthSessionManager {
  static let shared = AuthSessionManager()

  let authenticator: AccessTokenAuthenticator
  let interceptor: AuthenticationInterceptor<AccessTokenAuthenticator>
  let session: Session

  private var tokenUpdateObservers: [NSObjectProtocol] = []
  private var tokenCheckTimer: Timer?

  private init(
    authenticator: AccessTokenAuthenticator = AccessTokenAuthenticator()
  ) {
    self.authenticator = authenticator

    let initialCredential = AuthSessionManager.loadCredentialFromKeychain()
    interceptor = AuthenticationInterceptor(
      authenticator: authenticator,
      credential: initialCredential
    )
    session = Session(interceptor: interceptor)

    registerTokenObservers()
    startPeriodicTokenCheck()
    registerAppStateObservers()

    // 앱 시작 시 즉시 토큰 상태 체크
    Task {
      await checkTokenOnStartup()
    }
  }

  deinit {
    tokenUpdateObservers.forEach { NotificationCenter.default.removeObserver($0) }
    tokenCheckTimer?.invalidate()
  }

  func updateCredential(with tokens: AuthTokens) {
    guard let refreshToken = tokens.refreshToken else {
      #logError("AuthSessionManager: No refresh token provided, clearing credential")
      interceptor.credential = nil
      return
    }

    let credential = AccessTokenCredential.make(
      accessToken: tokens.accessToken,
      refreshToken: refreshToken
    )

    interceptor.credential = credential
    #logDebug("AuthSessionManager: Credential updated successfully")
  }

  public func clear() {
    interceptor.credential = nil
  }

  func updateCredential(accessToken: String, refreshToken: String) {
    let credential = AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    )

    interceptor.credential = credential
    #logDebug("AuthSessionManager: Credential updated with new tokens")
  }
}

private extension AuthSessionManager {
  func registerTokenObservers() {
    let update = NotificationCenter.default.addObserver(
      forName: .tokensDidUpdate,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.reloadCredentialFromKeychain()
    }

    let clear = NotificationCenter.default.addObserver(
      forName: .tokensDidClear,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      self?.interceptor.credential = nil
    }

    tokenUpdateObservers.append(contentsOf: [update, clear])
  }

  func registerAppStateObservers() {
    // UIKit import 제거로 인해 앱 상태 알림은 주석 처리
    // 주기적인 토큰 체크로 대체함
    #logDebug("AuthSessionManager: App state observers disabled - using periodic checks")
  }

  func reloadCredentialFromKeychain() {
    interceptor.credential = AuthSessionManager.loadCredentialFromKeychain()
  }

  static func loadCredentialFromKeychain() -> AccessTokenCredential? {
    guard
      let accessToken = KeychainManager.live.loadAccessTokenSync(),
      let refreshToken = KeychainManager.live.loadRefreshTokenSync()
    else {
      #logError("AuthSession: Failed to load tokens from keychain")
      return nil
    }

    let credential = AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    )

    #logDebug("AuthSession: Successfully loaded credential from keychain")
    #logDebug("AuthSession: Token expires at: \(credential.expiration)")
    #logDebug("AuthSession: Requires refresh: \(credential.requiresRefresh)")

    return credential
  }

  func startPeriodicTokenCheck() {
    // Check token every 2 minutes for immediate detection of expired tokens
    tokenCheckTimer = Timer.scheduledTimer(withTimeInterval: 2 * 60, repeats: true) { [weak self] _ in
      print("⏰ AuthSessionManager: Periodic token check triggered")
      self?.checkAndRefreshTokenIfNeeded()
    }

    // 즉시 한번 실행
    print("🚀 AuthSessionManager: Initial token check on startup")
    checkAndRefreshTokenIfNeeded()
  }

  private func checkAndRefreshTokenIfNeeded() {
    guard let credential = interceptor.credential else {
      print("AuthSessionManager: No credential available for refresh check")
      return
    }

    let now = Date()
    let timeUntilExpiry = credential.expiration.timeIntervalSince(now)

    print("AuthSessionManager: Token expires in \(timeUntilExpiry/3600) hours")
    print("AuthSessionManager: requiresRefresh = \(credential.requiresRefresh)")

    // If token requires refresh OR already expired, force refresh
    if credential.requiresRefresh || timeUntilExpiry <= 0 {
      print("🔄 AuthSessionManager: FORCING token refresh - expired or expiring soon")

      // 401 에러를 유도하여 Alamofire AuthenticationInterceptor 갱신 트리거
      let url = URL(string: "https://httpbin.org/status/401")!
      var request = URLRequest(url: url)
      request.setValue("Bearer \(credential.accessToken)", forHTTPHeaderField: "Authorization")
      request.timeoutInterval = 10

      session.request(request).response { response in
        print("AuthSessionManager: 401 trigger completed - Status: \(response.response?.statusCode ?? 0)")

        if let error = response.error {
          print("AuthSessionManager: Triggered error: \(error)")
        }
      }
    } else {
      print("AuthSessionManager: Token is still valid, no refresh needed")
    }
  }

  private func checkTokenOnStartup() async {
    #logDebug("AuthSessionManager: Checking token status on startup")

    guard let credential = interceptor.credential else {
      #logDebug("AuthSessionManager: No credential found on startup")
      return
    }

    let now = Date()
    let timeUntilExpiry = credential.expiration.timeIntervalSince(now)

    #logDebug("AuthSessionManager: Current token expires in \(timeUntilExpiry/3600) hours")

    if credential.requiresRefresh {
      #logDebug("AuthSessionManager: Token requires refresh on startup, triggering immediate refresh")

      // 만료된 토큰에 대해 즉시 갱신 시도
      let dummyURL = URL(string: "https://httpbin.org/status/401")!
      var request = URLRequest(url: dummyURL)
      request.setValue("Bearer \(credential.accessToken)", forHTTPHeaderField: "Authorization")

      session.request(request).response { response in
        #logDebug("AuthSessionManager: Startup token refresh attempt completed")
      }
    }
  }
}
