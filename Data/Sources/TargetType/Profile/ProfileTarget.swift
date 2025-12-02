//
//  ProfileTarget.swift
//  Data
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation
import Moya
import NetworkService

public enum ProfileTarget {
  case getProfile
}


extension ProfileTarget: BaseTargetType {
  public typealias Domain = SseuDamDomain

   public var domain: SseuDamDomain {
    return .profile
  }

  public var urlPath: String {
    switch self {
      case .getProfile:
        return ProfileAPI.getProfile.description
    }
  }

  public var requiresAuthorization: Bool {
    return true
  }

  public var error: [Int : NetworkService.NetworkError]? {
    return nil
  }
  
  public var parameters: [String : Any]? {
    switch self {
      case .getProfile:
        return nil
    }
  }
  
  public var method: Moya.Method {
    switch self {
      case .getProfile:
        return .get
    }
  }
}
