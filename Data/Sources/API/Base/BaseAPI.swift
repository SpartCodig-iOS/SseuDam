//
//  BaseAPI.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation

public enum BaseAPI: String {
  case base

  var description: String {
    switch self {
      case .base:
        return "https://sseudam.up.railway.app/api/v1"
    }
  }
}
