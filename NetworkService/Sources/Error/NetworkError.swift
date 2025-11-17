//
//  NetworkError.swift
//  NetworkService
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation
import Moya

public enum NetworkError: Error {
  case customError(ResponseError)
  case unhandledStatusCode(Int)
  case moyaError(MoyaError)
  case noData
}
