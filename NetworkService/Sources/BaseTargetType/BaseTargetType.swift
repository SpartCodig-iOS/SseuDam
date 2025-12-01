//
//  BaseTargetType.swift
//  NetworkService
//
//  Created by Wonji Suh  on 11/17/25.
//

import Moya
import Foundation

public protocol DomainType {
    var url: String { get }
    var baseURLString: String { get }
}

public protocol BaseTargetType: TargetType {
    associatedtype Domain: DomainType
    var domain: Domain { get }
    var urlPath: String { get }
    var error: [Int: NetworkError]? { get }
    var parameters: [String: Any]? { get }
}

public extension BaseTargetType {
    var baseURL: URL { URL(string: domain.baseURLString)! }
    var path: String { domain.url + urlPath }
    var headers: [String: String]? { APIHeaders.cached }
    
    var task: Moya.Task {
        if let parameters {
            return method == .get
            ? .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            : .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
        return .requestPlain
    }
}

// 순수 캐시
public enum APIHeaders {
  static var cached: [String: String] = [
    "Content-Type": "application/json"
  ]
}
