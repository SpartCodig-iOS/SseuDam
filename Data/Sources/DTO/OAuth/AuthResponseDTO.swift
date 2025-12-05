//
//  OAuthResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/24/25.
//

import Foundation

public struct AuthResponseDTO: Decodable {
    let user: User
    let tokenPair: TokenPair?
    let accessToken: String?
    let refreshToken: String?
    let accessTokenExpiresAt: String?
    let refreshTokenExpiresAt: String?
    let session: Session?
    let sessionID: String?
    let sessionExpiresAt: String?
    let lastLoginAt: String?
    let loginType: String?

    enum CodingKeys: String, CodingKey {
        case user, tokenPair, session, accessToken, refreshToken, accessTokenExpiresAt, refreshTokenExpiresAt
        case sessionID = "sessionId"
        case sessionExpiresAt, lastLoginAt, loginType
    }

    public struct TokenPair: Decodable {
        let accessToken: String
        let refreshToken: String
        let accessTokenExpiresAt: String?
        let refreshTokenExpiresAt: String?
    }

    public struct Session: Decodable {
        let sessionId: String
        let expiresAt: String?
        let isActive: Bool?

        enum CodingKeys: String, CodingKey {
            case sessionId
            case expiresAt
            case isActive
        }
    }
}

public struct User: Decodable {
    let id: String
    let email: String
    let name: String?
    let username: String?
    let role: String
    let createdAt: String?
    let userID: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name, username, role, createdAt
        case userID = "userId"
        case avatarURL = "avatarUrl"
    }
}
