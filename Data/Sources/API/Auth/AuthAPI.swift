//
//  AuthAPI.swift
//  Data
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public enum AuthAPI  {
  case refresh
  case logOut
  case deleteAccount
  case registerDevice

  var description: String {
    switch self {
      case .refresh:
        return "/refresh"

      case .logOut:
        return "/logout"

      case .deleteAccount:
        return "/account"

      case .registerDevice:
        return "/device-token"

    }
  }
}
