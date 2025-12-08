//
//  SseuDamDomain.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import NetworkService

public enum SseuDamDomain {
  case auth
  case oauth
  case profile
  case session
  case travels
  case travelExpenses(travelId: String)
  case travelSettlements(travelId: String)
  case meta
  case version
}


extension SseuDamDomain: DomainType {
  public var baseURLString: String {
    return BaseAPI.base.description
  }

  public var url: String {
    switch self {
      case .auth:
        return "/auth"
      case .oauth:
        return "/oauth"
      case .profile:
        return "/profile"
      case .session:
        return "/session"
      case .travels:
        return "/travels"
      case .travelExpenses(let travelId):
        return "/travels/\(travelId)"
      case .travelSettlements(let travelId):
        return "/travels/\(travelId)"
      case .meta:
        return "/meta"
      case .version:
        return "/version"
    }
  }
}

