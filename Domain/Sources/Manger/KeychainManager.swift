//
//  KeychainManager.swift
//  Domain
//
//  Created by Wonji Suh  on 11/18/25.
//

import Foundation
import Security
import LogMacro

enum KeychainKey: String {
  case accessToken = "access_token"
  case refreshToken = "refresh_token"
}

public struct KeychainManager {
  static let shared = KeychainManager()
  private init() {}

  // MARK: - Public API
  func saveAccessToken(_ token: String) {
    save(token: token, for: .accessToken)
  }

  func saveRefreshToken(_ token: String) {
    save(token: token, for: .refreshToken)
  }

  public func loadAccessToken() -> String? {
    loadToken(for: .accessToken)
  }

  public func loadRefreshToken() -> String? {
    loadToken(for: .refreshToken)
  }

  public func deleteAccessToken() {
    deleteToken(for: .accessToken)
  }

  public func deleteRefreshToken() {
    deleteToken(for: .refreshToken)
  }

  /// 둘 다 한 번에 저장
  func saveTokens(
    accessToken: String?,
    refreshToken: String?
  ) {
    if let accessToken {
      saveAccessToken(accessToken)
    } else {
      deleteAccessToken()
    }

    if let refreshToken {
      saveRefreshToken(refreshToken)
    } else {
      deleteRefreshToken()
    }
  }

  /// 둘 다 한 번에 불러오기
  func loadTokens() -> (accessToken: String?, refreshToken: String?) {
    (loadAccessToken(), loadRefreshToken())
  }

  /// 모두 삭제 (로그아웃 시 등)
  func clearAll() {
    deleteAccessToken()
    deleteRefreshToken()
  }

  // MARK: - Private helpers

  private func save(token: String, for key: KeychainKey) {
    guard let data = token.data(using: .utf8) else {
      Log.info("Keychain: Failed to convert token to data for key \(key.rawValue)")
      return
    }

    // 기존 항목이 있으면 먼저 삭제
    deleteToken(for: key)

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key.rawValue,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]

    let status = SecItemAdd(query as CFDictionary, nil)

    if status != errSecSuccess {
      Log.info("Keychain: Failed to save token for key \(key.rawValue), status: \(status)")
    }
  }

  private func loadToken(for key: KeychainKey) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key.rawValue,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess,
          let data = item as? Data,
          let token = String(data: data, encoding: .utf8)
    else {
      if status != errSecItemNotFound {
        Log.info("Keychain: Failed to load token for key \(key.rawValue), status: \(status)")
      }
      return nil
    }

    return token
  }

  private func deleteToken(for key: KeychainKey) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key.rawValue
    ]

    let status = SecItemDelete(query as CFDictionary)
    if status != errSecSuccess && status != errSecItemNotFound {
      Log.info("Keychain: Failed to delete token for key \(key.rawValue), status: \(status)")
    }
  }
}
