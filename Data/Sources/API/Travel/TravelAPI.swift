//
//  TravelAPI.swift
//  Data
//
//  Created by 김민희 on 11/18/25.
//

import Foundation
import Moya
import NetworkService

public enum TravelAPI {
    case fetchTravels(body: FetchTravelsRequestDTO)
    case createTravel(body: CreateTravelRequestDTO)
    case updateTravel(id: String, body: UpdateTravelRequestDTO)
    case deleteTravel(id: String)
}

extension TravelAPI: BaseTargetType {

    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        return .travels
    }

    public var urlPath: String {
        switch self {
        case .fetchTravels:
            return ""
        case .createTravel:
            return ""
        case .updateTravel(let id, _):
            return "/\(id)"
        case .deleteTravel(let id):
            return "/\(id)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchTravels: return .get
        case .createTravel: return .post
        case .updateTravel: return .patch
        case .deleteTravel: return .delete
        }
    }

    public var parameters: [String: Any]? {
        switch self {
        case .fetchTravels(let body):
            return body.toDictionary
        case .createTravel(let body):
            return body.toDictionary
        case .updateTravel(_, let body):
            return body.toDictionary
        case .deleteTravel:
            return nil
        }
    }

    public var error: [Int : NetworkError]? { nil }

  public var headers: [String : String]? {
    return APIHeaders.accessTokenHeader
  }
}
