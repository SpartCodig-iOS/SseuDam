//
//  SessionAPI.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

public enum SessionAPI  {
  case checkSessionLogin

  var description: String {
    switch self {
      case .checkSessionLogin:
        return ""
    }
  }
}
