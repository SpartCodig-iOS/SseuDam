//
//  ExchangeRateAPI.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//


import Foundation
import Moya
import NetworkService

public enum ExchangeRateAPI {
    case fetchRate(base: String)
}

extension ExchangeRateAPI: BaseTargetType {

    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        return .meta
    }

  public var requiresAuthorization: Bool { false }

    public var urlPath: String {
        return "/exchange-rate"
    }

    public var method: Moya.Method {
        return .get
    }

    public var parameters: [String : Any]? {
        switch self {
        case .fetchRate(let base):
            return [
                "base": base.uppercased(),
                "quote": "KRW",
                "baseAmount": 1
            ]
        }
    }

    public var error: [Int : NetworkError]? { nil }
}
