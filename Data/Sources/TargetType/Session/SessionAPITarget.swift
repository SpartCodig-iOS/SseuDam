//
//  SessionAPITarget.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import Moya
import NetworkService

public enum SessionAPITarget  {
    case checkSession(body: SessionRequestDTO)
}


extension SessionAPITarget : BaseTargetType {
    public typealias Domain = SseuDamDomain
    
    public var domain: SseuDamDomain {
        return .session
    }
    
    public var urlPath: String {
        switch self {
            case .checkSession:
                return SessionAPI.checkSessionLogin.description
        }
    }
    
    public var requiresAuthorization: Bool { false }
    
    public var error: [Int : NetworkService.NetworkError]? {
        return nil
    }
    
    public var parameters: [String : Any]? {
        switch self {
            case .checkSession(let body):
                return body.toDictionary
        }
    }
    
    public var method: Moya.Method {
        switch self {
            case .checkSession:
                return .get
        }
    }
    
    
}
