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
    case deleteAccount
    case registerDeviceToken(body: DeviceTokenRequestDTO)
}


extension AuthAPITarget: BaseTargetType {
    public typealias Domain = SseuDamDomain
    
    public var domain: SseuDamDomain {
        return .auth
    }
    
    public var requiresAuthorization: Bool {
        switch self {
          case .refreshToken, .registerDeviceToken:
                return false
            case .logout, .deleteAccount:
                return true
        }
    }
    
    public var urlPath: String {
        switch self {
            case .refreshToken:
                return AuthAPI.refresh.description
                
            case .logout:
                return AuthAPI.logOut.description
                
            case .deleteAccount:
                return AuthAPI.deleteAccount.description

          case .registerDeviceToken:
            return AuthAPI.registerDevice.description
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
                
            case .deleteAccount:
                return nil

          case .registerDeviceToken(let body):
            return body.toDictionary
        }
    }
    
    public var method: Moya.Method {
        switch self {
          case .refreshToken, .logout, .registerDeviceToken:
                return .post
                
            case .deleteAccount:
                return .delete
        }
    }
}
