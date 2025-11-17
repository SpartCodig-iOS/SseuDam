//
//  DeleteTravelResponseDTO.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

struct DeleteTravelResponseDTO: Codable {
    let code: Int
    let data: [String: String]
    let message: String
    let meta: DeleteMetaDTO
}

struct DeleteMetaDTO: Codable {
    let responseTime: String
    let cached: Bool
}
