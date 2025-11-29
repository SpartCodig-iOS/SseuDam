//
//  Extension+APIHeader.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import NetworkService
import Domain

public extension APIHeaders {
  static let registerKeychainTokenProvider: Void = {
    APIHeaders.setTokenProvider {
      KeychainManager.shared.loadAccessToken()
    }
  }()

  static var accessTokenHeader: [String: String] {
    _ = registerKeychainTokenProvider

    guard let token = KeychainManager.shared.loadAccessToken() else {
      return ["Content-Type": "application/json"]
    }

    return [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)"
    ]
  }
}

public extension BaseTargetType where Domain == SseuDamDomain {
  var headers: [String: String]? {
    _ = APIHeaders.registerKeychainTokenProvider
    return requiresAuthorization
    ? APIHeaders.authorizedOrCached
    : APIHeaders.cached
  }
}
