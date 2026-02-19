//
//  AccessTokenCredential.swift
//  Data
//
//  Created by Wonji Suh on 01/14/26.
//

import Foundation
import Alamofire

struct AccessTokenCredential: AuthenticationCredential, Sendable {
  let accessToken: String
  let refreshToken: String
  let expiration: Date

  private let refreshLeadTime: TimeInterval = 30 * 60 // refresh 30 minutes before expiry

  var requiresRefresh: Bool {
    Date().addingTimeInterval(refreshLeadTime) >= expiration
  }

  static func make(
    accessToken: String,
    refreshToken: String
  ) -> AccessTokenCredential? {
    guard let expiration = decodeExpiration(from: accessToken) else { return nil }
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
      print("JWT: Invalid token format - expected 3 components, got \(components.count)")
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
      print("JWT: Failed to decode base64 payload")
      return nil
    }

    do {
      let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
      guard let exp = json?["exp"] as? TimeInterval else {
        print("JWT: Missing or invalid 'exp' field in payload")
        return nil
      }

      let expirationDate = Date(timeIntervalSince1970: exp)
      let now = Date()
      let timeUntilExpiry = expirationDate.timeIntervalSince(now)

      print("JWT: Token expires at \(expirationDate), current time: \(now), time until expiry: \(timeUntilExpiry/3600) hours")

      // Sanity check: token should not be expired already and should not expire more than 24 hours from now
      guard timeUntilExpiry > 0 && timeUntilExpiry < 24 * 60 * 60 else {
        print("JWT: Token expiration time seems invalid - timeUntilExpiry: \(timeUntilExpiry)")
        return nil
      }

      return expirationDate
    } catch {
      print("JWT: Failed to parse JSON payload - \(error)")
      return nil
    }
  }
}
