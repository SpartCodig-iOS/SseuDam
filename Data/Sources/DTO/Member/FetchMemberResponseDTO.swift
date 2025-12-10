//
//  FetchMemberResponseDTO.swift
//  Data
//
//  Created by 김민희 on 12/10/25.
//

import Foundation
import Domain

public struct FetchMemberResponseDTO: Decodable {
    let userId: String
    let name: String
    let email: String
    let role: MemberRole
    let avatarUrl: String?
}

extension FetchMemberResponseDTO {
    func toDomain() -> TravelMember {
        TravelMember(
            id: userId,
            name: name,
            role: role,
            email: email,
            avatarUrl: avatarUrl
        )
    }
}
