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
    case fetchTravelDetail(id: String)
    case deleteMember(travelId: String, memberId: String)
    case joinTravel(body: JoinTravelRequestDTO)
    case delegateOwner(travelId: String, body: DelegateOwnerRequestDTO)
    case leaveTravel(travelId: String)
    case fetchMember(travelId: String)
}

extension TravelAPI: BaseTargetType {

    public typealias Domain = SseuDamDomain

    public var domain: SseuDamDomain {
        return .travels
    }

  public var requiresAuthorization: Bool { true }

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
        case .fetchTravelDetail(let id):
            return "/\(id)"
        case .deleteMember(let travelId, let memberId):
            return "/\(travelId)/members/\(memberId)"
        case .joinTravel:
            return "/join"
        case .delegateOwner(let travelId, _):
            return "/\(travelId)/owner"
        case .leaveTravel(let travelId):
            return "/\(travelId)/leave"
        case .fetchMember(let travelId):
            return "/\(travelId)/members"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchTravels: return .get
        case .createTravel: return .post
        case .updateTravel: return .patch
        case .deleteTravel: return .delete
        case .fetchTravelDetail: return .get
        case .deleteMember: return .delete
        case .joinTravel: return .post
        case .delegateOwner: return .patch
        case .leaveTravel: return .delete
        case .fetchMember: return .get
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
        case .deleteTravel, .fetchTravelDetail:
            return nil
        case .deleteMember:
            return nil
        case .joinTravel(let body):
            return body.toDictionary
        case .delegateOwner(_, let body):
            return body.toDictionary
        case .leaveTravel:
            return nil
        case .fetchMember:
            return nil
        }
    }

    public var error: [Int : NetworkError]? { nil }

}
