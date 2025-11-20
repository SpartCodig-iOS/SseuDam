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
  static var accessTokenHeader: [String: String] {
    guard let token = KeychainManager.shared.loadAccessToken() else {
      return ["Content-Type": "application/json"]
    }

    return [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)"
    ]
  }
}
