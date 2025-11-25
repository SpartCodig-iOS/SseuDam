//
//  SessionResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 11/25/25.
//

import Foundation

public struct SessionResponseDTO: Decodable {
  let sessionID, userID, loginType, createdAt: String
      let lastSeenAt, expiresAt, status: String
      let isActive, supabaseSessionValid: Bool

      enum CodingKeys: String, CodingKey {
          case sessionID = "sessionId"
          case userID = "userId"
          case loginType, createdAt
          case  lastSeenAt, expiresAt
          case status, isActive
          case supabaseSessionValid
      }
}
