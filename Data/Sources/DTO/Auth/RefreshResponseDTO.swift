//
//  RefreshResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation

public struct RefreshResponseDTO: Decodable {
    let accessToken, refreshToken, accessTokenExpiresAt, refreshTokenExpiresAt: String
    let sessionID, sessionExpiresAt, loginType: String

    enum CodingKeys: String, CodingKey {
        case accessToken, refreshToken, accessTokenExpiresAt, refreshTokenExpiresAt
        case sessionID = "sessionId"
        case sessionExpiresAt, loginType
    }
}
