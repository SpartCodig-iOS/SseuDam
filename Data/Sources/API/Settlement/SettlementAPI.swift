//
//  SettlementAPI.swift
//  Data
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Moya
import NetworkService

public enum SettlementAPI {
    case fetchSettlement(travelId: String)
}

extension SettlementAPI: BaseTargetType {

    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        switch self {
        case .fetchSettlement(let travelId):
            return .travelSettlements(travelId: travelId)
        }
    }

    public var requiresAuthorization: Bool { true }

    public var urlPath: String {
        switch self {
        case .fetchSettlement:
            return "/settlements"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchSettlement:
            return .get
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .fetchSettlement:
            return nil
        }
    }

    public var error: [Int: NetworkError]? { nil }
}
