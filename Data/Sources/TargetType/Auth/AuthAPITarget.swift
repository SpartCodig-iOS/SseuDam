//
//  AuthAPITarget.swift
//  Data
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation
import Moya
import NetworkService

public enum AuthAPITarget {
    case refreshToken(body: RefreshRequestDTO)
    case logout(body: SessionRequestDTO)
}


extension AuthAPITarget: BaseTargetType {
    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        return .auth
    }

    public var requiresAuthorization: Bool {
      switch self {
        case .refreshToken:
          return false
        case .logout:
          return true
      }
    }

    public var urlPath: String {
        switch self {
            case .refreshToken:
                return AuthAPI.refresh.description

          case .logout:
            return AuthAPI.logOut.description
        }
    }

    public var error: [Int : NetworkService.NetworkError]? {
        return nil
    }

    public var parameters: [String : Any]? {
        switch self {
            case .refreshToken(let body):
                return body.toDictionary

          case .logout(let body):
            return body.toDictionary
        }
    }

    public var method: Moya.Method {
        switch self {
          case .refreshToken, .logout:
                return .post
        }
    }
}
