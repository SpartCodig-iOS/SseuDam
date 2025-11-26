//
//  OAuthService.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Moya
import NetworkService

public enum OAuthAPITarget {
  case checkSignUpUser(body: OAuthCheckUserRequestDTO)
}

extension OAuthAPITarget: BaseTargetType {
  public typealias Domain = SseuDamDomain

  public var domain: SseuDamDomain {
    return .oauth
  }

  public var urlPath: String {
    switch self {
      case .checkSignUpUser:
        return OAuthAPI.checkSignUpUser.description
    }
  }
  
  public var error: [Int : NetworkService.NetworkError]? {
    return nil
  }
  
  public var parameters: [String : Any]? {
    switch self {
      case .checkSignUpUser(let body):
        return body.toDictionary
    }
  }
  
  public var method: Moya.Method {
    switch self {
      case .checkSignUpUser:
        return .post
    }
  }
}
