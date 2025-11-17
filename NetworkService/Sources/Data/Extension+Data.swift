//
//  Extension+Data.swift
//  NetworkService
//
//  Created by Wonji Suh  on 11/17/25.
//

import Foundation

public extension Data {
  func decoded<T: Decodable>(as type: T.Type) throws -> T {
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: self)
  }
}
