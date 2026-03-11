//
//  AccessTokenCredential.swift
//  Data
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation
import Alamofire
import LogMacro

struct AccessTokenCredential: AuthenticationCredential, Sendable {
  let accessToken: String
  let refreshToken: String
  let expiration: Date

  private let refreshLeadTime: TimeInterval = 30 * 60 // refresh 30 minutes before expiry (적합한 시간 for 3시간 토큰)

  var requiresRefresh: Bool {
    // 만료 30분 전 또는 이미 만료된 경우 모두 갱신 필요
    let now = Date()
    return now.addingTimeInterval(refreshLeadTime) >= expiration || now >= expiration
  }

  static func make(
    accessToken: String,
    refreshToken: String
  ) -> AccessTokenCredential {
    // JWT 디코딩을 시도하되, 실패하면 기본 만료시간 사용 (3시간 후)
    let fallbackExpiration = Date().addingTimeInterval(3 * 60 * 60) // 3시간
    let expiration = decodeExpiration(from: accessToken) ?? {
      #logDebug("⚠️ JWT decoding failed, using fallback expiration: 3 hours from now")
      return fallbackExpiration
    }()

    return AccessTokenCredential(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiration: expiration
    )
  }
}

private extension AccessTokenCredential {
  static func decodeExpiration(from token: String) -> Date? {
    let components = token.components(separatedBy: ".")
    guard components.count == 3 else {
      #logDebug("🚫 JWT decoding failed: Invalid JWT format (expected 3 parts, got \(components.count))")
      return nil
    }

    let payload = components[1]
    var base64 = payload
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let paddingLength = 4 - (base64.count % 4)
    if paddingLength < 4 {
      base64 += String(repeating: "=", count: paddingLength)
    }

    guard let data = Data(base64Encoded: base64) else {
      #logDebug("🚫 JWT decoding failed: Base64 decoding failed")
      return nil
    }

    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      #logDebug("🚫 JWT decoding failed: JSON parsing failed")
      return nil
    }

    guard let exp = json["exp"] as? TimeInterval else {
      #logDebug("🚫 JWT decoding failed: 'exp' claim not found or invalid type")
      #logDebug("🔍 Available keys in JWT payload: \(json.keys.joined(separator: ", "))")
      return nil
    }

    let expirationDate = Date(timeIntervalSince1970: exp)
    #logDebug("✅ JWT expiration decoded successfully: \(expirationDate)")
    #logDebug("🕐 Time until expiration: \(expirationDate.timeIntervalSinceNow / 3600) hours")

    return expirationDate
  }
}
