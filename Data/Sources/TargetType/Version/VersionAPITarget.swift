//
//  VersionAPITarget.swift
//  Data
//
//  Created by Wonji Suh  on 12/8/25.
//

import Foundation
import Moya
import NetworkService

public enum VersionAPITarget {
    case getVersion(body: VersionRequestDTO)

}


extension VersionAPITarget: BaseTargetType {
    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        return .version
    }

    public var urlPath: String {
        switch self {
            case .getVersion:
                return VersionAPI.getVersion.description
        }
    }

    public var error: [Int : NetworkService.NetworkError]? {
        return nil
    }

    public var parameters: [String : Any]? {
        switch self {
            case .getVersion(let body):
                return body.toDictionary
        }
    }

    public var method: Moya.Method {
        switch self {
            case .getVersion:
                return .get
        }
    }
}
