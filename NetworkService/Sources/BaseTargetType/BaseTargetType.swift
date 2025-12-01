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
  var requiresAuthorization: Bool { get }
}

public extension BaseTargetType {
  var requiresAuthorization: Bool { true }
   var baseURL: URL { URL(string: domain.baseURLString)! }
    var path: String { domain.url + urlPath }


  var headers: [String: String]? {
    requiresAuthorization
    ? APIHeaders.authorizedOrCached
    : APIHeaders.cached
  }

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
  public typealias TokenProvider = () -> String?

  private static var tokenProvider: TokenProvider?

  public static func setTokenProvider(_ provider: TokenProvider?) {
    tokenProvider = provider
  }

  public static var cached: [String: String] = [
    "Content-Type": "application/json"
  ]

  public static var authorizedOrCached: [String: String] {
    guard
      let token = tokenProvider?(),
      token.isEmpty == false
    else {
      return cached
    }

    return [
      "Content-Type": "application/json",
      "Authorization": "Bearer \(token)"
    ]
  }
}
