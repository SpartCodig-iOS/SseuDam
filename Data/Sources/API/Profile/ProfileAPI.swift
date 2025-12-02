//
//  ProfileAPI.swift
//  Data
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation

public enum ProfileAPI {
  case getProfile
  case editProfile

  var description: String {
    switch self {
      case .getProfile:
        return "/me"
      case .editProfile:
        return "/me"
    }
  }
}
