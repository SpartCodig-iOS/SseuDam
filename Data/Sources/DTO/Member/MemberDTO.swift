//
//  TravelMemberDTO.swift
//  Data
//
//  Created by 홍석현 on 12/12/25.
//

import Foundation
import Domain

public struct MemberDTO: Codable {
    let userId: String
    let name: String
    let email: String?
    let role: String?
    let avatarUrl: String?
}

public extension MemberDTO {
    func toDomain() -> TravelMember {
        TravelMember(
            id: userId,
            name: name,
            role: MemberRole(value: role),
            email: email,
            avatarUrl: avatarUrl
        )
    }
}
