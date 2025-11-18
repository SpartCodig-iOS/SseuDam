//
//  NetworkError.swift
//  NetworkService
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Moya

public enum NetworkError: Error {
  case noResponse               // HTTPURLResponse 없음
  case noData                   // 데이터 없음
  case decodingError(underlying: Error)
  case server(ResponseError)
  case clientError(statusCode: Int)    // 4xx
  case serverError(statusCode: Int)    // 5xx
  case unauthorized                      // 401
  case unknown(statusCode: Int?)
  case underlying(Error)               // 기타 에러 래핑 (로그용)
}
