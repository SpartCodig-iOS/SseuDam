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
  static var accesstokenHeader: [String: String] = [
    "Content-Type": "application/json",
    "Authorization": "Bearer \(KeychainManager.loadAccessToken)"
  ]
}
