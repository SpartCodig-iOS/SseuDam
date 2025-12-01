//
//  CountryAPI.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//


import Foundation
import Moya
import NetworkService

public enum CountryAPI {
    case fetchCountries
}

extension CountryAPI: BaseTargetType {

    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        return .meta
    }
  
    public var requiresAuthorization: Bool {  false }

    public var urlPath: String {
        return "/countries"
    }

    public var method: Moya.Method {
        return .get
    }

    public var parameters: [String : Any]? {
        return nil
    }

    public var error: [Int : NetworkError]? { nil }
}
