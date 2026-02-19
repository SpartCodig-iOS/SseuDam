//
//  AuthSessionManager.swift
//  Data
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation
import UIKit
import Alamofire
import Domain

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
  }

  deinit {
    tokenUpdateObservers.forEach { NotificationCenter.default.removeObserver($0) }
    tokenCheckTimer?.invalidate()
  }

  func updateCredential(with tokens: AuthTokens) {
    guard
      let refreshToken = tokens.refreshToken,
      let credential = AccessTokenCredential.make(
        accessToken: tokens.accessToken,
        refreshToken: refreshToken
      )
    else {
      interceptor.credential = nil
      return
    }

    interceptor.credential = credential
  }

  public func clear() {
    interceptor.credential = nil
  }

  func updateCredential(accessToken: String, refreshToken: String) {
    guard let credential = AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    ) else {
      interceptor.credential = nil
      return
    }

    interceptor.credential = credential
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
    let foreground = NotificationCenter.default.addObserver(
      forName: UIApplication.willEnterForegroundNotification,
      object: nil,
      queue: nil
    ) { [weak self] _ in
      print("AuthSessionManager: App entering foreground, checking token")
      self?.checkAndRefreshTokenIfNeeded()
    }

    tokenUpdateObservers.append(foreground)
  }

  func reloadCredentialFromKeychain() {
    interceptor.credential = AuthSessionManager.loadCredentialFromKeychain()
  }

  static func loadCredentialFromKeychain() -> AccessTokenCredential? {
    guard
      let accessToken = KeychainManager.live.loadAccessTokenSync(),
      let refreshToken = KeychainManager.live.loadRefreshTokenSync()
    else {
      return nil
    }

    return AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    )
  }

  func startPeriodicTokenCheck() {
    // Check token every 10 minutes in foreground
    tokenCheckTimer = Timer.scheduledTimer(withTimeInterval: 10 * 60, repeats: true) { [weak self] _ in
      self?.checkAndRefreshTokenIfNeeded()
    }
  }

  private func checkAndRefreshTokenIfNeeded() {
    guard let credential = interceptor.credential else { return }

    // If token requires refresh, trigger a dummy request to force refresh
    if credential.requiresRefresh {
      print("AuthSessionManager: Token requires refresh, triggering proactive refresh")

      // Create a simple request to trigger the authenticator
      let url = URL(string: "https://httpbin.org/status/401")!
      var request = URLRequest(url: url)
      request.setValue("Bearer \(credential.accessToken)", forHTTPHeaderField: "Authorization")

      session.request(request).response { _ in
        print("AuthSessionManager: Proactive refresh attempt completed")
      }
    }
  }
}
