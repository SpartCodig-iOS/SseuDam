//
//  ProfileResponseDTO.swift
//  Data
//
//  Created by Wonji Suh  on 12/1/25.
//

import Foundation


struct ProfileResponseDTO: Decodable {
    let id, userID, email, name: String
    let role, createdAt, updatedAt: String
    let loginType: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case email, name, role, createdAt, updatedAt, loginType
        case avatarURL
    }
}
