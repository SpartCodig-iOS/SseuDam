//
//  AuthSessionManager.swift
//  Data
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation
import Alamofire
import Domain

final class AuthSessionManager {
  static let shared = AuthSessionManager()

  let authenticator: AccessTokenAuthenticator
  let interceptor: AuthenticationInterceptor<AccessTokenAuthenticator>
  let session: Session

  private var tokenUpdateObservers: [NSObjectProtocol] = []

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
  }

  deinit {
    tokenUpdateObservers.forEach { NotificationCenter.default.removeObserver($0) }
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

  func reloadCredentialFromKeychain() {
    interceptor.credential = AuthSessionManager.loadCredentialFromKeychain()
  }

  static func loadCredentialFromKeychain() -> AccessTokenCredential? {
    guard
      let accessToken = KeychainManager.live.loadAccessToken(),
      let refreshToken = KeychainManager.live.loadRefreshToken()
    else {
      return nil
    }

    return AccessTokenCredential.make(
      accessToken: accessToken,
      refreshToken: refreshToken
    )
  }
}
