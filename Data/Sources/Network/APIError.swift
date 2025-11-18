//
//  APIError.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case unknown(Error)
}
