//
//  OAuthResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/24/25.
//

import Foundation

public struct AuthResponseDTO: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresAt: String?
    let refreshTokenExpiresAt: String?
    let sessionID: String
    let sessionExpiresAt: String?
    let lastLoginAt: String?
    let loginType: String?

    enum CodingKeys: String, CodingKey {
        case user, accessToken, refreshToken, accessTokenExpiresAt, refreshTokenExpiresAt
        case sessionID = "sessionId"
        case sessionExpiresAt, lastLoginAt, loginType
    }
}


public struct User: Decodable {
    let id, email, name, role: String
    let createdAt: String
    let userID: String
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name, role, createdAt
        case userID = "userId"
        case avatarURL
    }
}
