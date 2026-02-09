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

public final class KeychainManager: KeychainManaging, @unchecked Sendable {
  /// DI를 위한 라이브 인스턴스 제공
  public static let live = KeychainManager()

  private let service: String

  /// Keychain 서비스 이름으로 앱의 Bundle ID 사용
  private init(service: String = "io.sseudam.co") {
    self.service = service
  }

  // MARK: - 공개 API

  /// 액세스 토큰을 키체인에 저장
  public func saveAccessToken(_ token: String) {
    save(token: token, for: .accessToken)
  }

  /// 리프레시 토큰을 키체인에 저장
  public func saveRefreshToken(_ token: String) {
    save(token: token, for: .refreshToken)
  }

  /// 키체인에서 액세스 토큰 로드
  public func loadAccessToken() -> String? {
    loadToken(for: .accessToken)
  }

  /// 키체인에서 리프레시 토큰 로드
  public func loadRefreshToken() -> String? {
    loadToken(for: .refreshToken)
  }

  /// 액세스 토큰 삭제
  public func deleteAccessToken() {
    deleteToken(for: .accessToken)
  }

  /// 리프레시 토큰 삭제
  public func deleteRefreshToken() {
    deleteToken(for: .refreshToken)
  }

  /// 두 토큰을 원자적으로 저장
  public func saveTokens(
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

    NotificationCenter.default.post(name: .tokensDidUpdate, object: nil)
  }

  /// 두 토큰을 모두 로드
  public func loadTokens() -> (accessToken: String?, refreshToken: String?) {
    (loadAccessToken(), loadRefreshToken())
  }

  /// 모든 토큰 삭제 (로그아웃 시 사용)
  public func clearAll() {
    deleteAccessToken()
    deleteRefreshToken()
    NotificationCenter.default.post(name: .tokensDidClear, object: nil)
  }

  // MARK: - 내부 헬퍼 메서드

  /// 토큰을 키체인에 저장 (Update-Add 패턴 사용)
  private func save(token: String, for key: KeychainKey) {
    guard let data = token.data(using: .utf8) else {
      Log.info("Keychain: 토큰을 데이터로 변환 실패, key: \(key.rawValue)")
      return
    }

    // Update-Add 패턴: 먼저 업데이트 시도, 없으면 새로 추가
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key.rawValue,
      kSecAttrService as String: service
    ]

    let attributes: [String: Any] = [
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]

    // Try to update existing item first
    let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

    if updateStatus == errSecItemNotFound {
      // Item doesn't exist, add it
      var addQuery = query
      addQuery[kSecValueData as String] = data
      addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

      let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
      if addStatus != errSecSuccess {
        Log.info("Keychain: Failed to add token for key \(key.rawValue), status: \(addStatus)")
      }
    } else if updateStatus != errSecSuccess {
      Log.info("Keychain: Failed to update token for key \(key.rawValue), status: \(updateStatus)")
    }
  }

  private func loadToken(for key: KeychainKey) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: key.rawValue,
      kSecAttrService as String: service,
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
      kSecAttrAccount as String: key.rawValue,
      kSecAttrService as String: service
    ]

    let status = SecItemDelete(query as CFDictionary)
    if status != errSecSuccess && status != errSecItemNotFound {
      Log.info("Keychain: Failed to delete token for key \(key.rawValue), status: \(status)")
    }
  }
}

public extension Notification.Name {
  static let tokensDidUpdate = Notification.Name("tokensDidUpdate")
  static let tokensDidClear = Notification.Name("tokensDidClear")
  static let refreshTokenExpired = Notification.Name("RefreshTokenExpired")
}
