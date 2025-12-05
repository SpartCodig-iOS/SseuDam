//
//  OAuthAPITarget.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Moya
import NetworkService

public enum OAuthAPITarget {
    case checkSignUpUser(body: LoginUserRequestDTO)
    case loginOAuth(body: LoginUserRequestDTO)
    case signUpOAuth(body: SignUpUserRequestDTO)
    case kakaoFinalize(body: KakaoFinalizeRequestDTO)
}

extension OAuthAPITarget: BaseTargetType {
    public typealias Domain = SseuDamDomain
    
    public var domain: SseuDamDomain {
        return .oauth
    }
    
    public var requiresAuthorization: Bool { false }
    
    public var urlPath: String {
        switch self {
            case .checkSignUpUser:
                return OAuthAPI.checkSignUpUser.description
                
            case .loginOAuth:
                return OAuthAPI.login.description
                
            case .signUpOAuth:
                return OAuthAPI.signUp.description

            case .kakaoFinalize:
                return OAuthAPI.kakaoFinalize.description
        }
    }
    
    public var error: [Int : NetworkService.NetworkError]? {
        return nil
    }
    
    public var parameters: [String : Any]? {
        switch self {
            case .checkSignUpUser(let body):
                return body.toDictionary
                
            case .loginOAuth(let body):
                return body.toDictionary
                
            case .signUpOAuth(let body):
                return body.toDictionary

            case .kakaoFinalize(let body):
                return body.toDictionary
        }
    }
    
    public var method: Moya.Method {
        switch self {
            case .checkSignUpUser, .loginOAuth, .signUpOAuth, .kakaoFinalize:
                return .post
        }
    }
}
