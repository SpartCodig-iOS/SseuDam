//
//  OAuthAPI.swift
//  Data
//
//  Created by Wonji Suh  on 11/21/25.
//

import Foundation

public enum OAuthAPI {
  case checkSignUpUser
  case signUp
  case login
  case kakaoFinalize

  public var description: String {
    switch self {
      case .checkSignUpUser:
        return "/lookup"
      case .signUp:
        return "/signup"
      case .login:
        return "/login"
      case .kakaoFinalize:
        return "/kakao/finalize"
    }
  }
}
