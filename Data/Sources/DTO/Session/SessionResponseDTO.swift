//
//  SessionResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

public struct SessionResponseDTO: Decodable {
    let sessionID: String
    let userID: String
    let loginType: String
    let createdAt: String
    let lastSeenAt: String?
    let expiresAt: String?
    let status: String
    let isActive: Bool
    let supabaseSessionValid: Bool?
    let revokedAt: String?

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
        case userID = "userId"
        case loginType, createdAt
        case lastSeenAt, expiresAt
        case status, isActive
        case supabaseSessionValid
        case revokedAt
    }
}
