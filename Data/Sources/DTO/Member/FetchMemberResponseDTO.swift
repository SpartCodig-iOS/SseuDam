//
//  FetchMemberResponseDTO.swift
//  Data
//
//  Created by 김민희 on 12/10/25.
//

import Foundation
import Domain

public struct FetchMemberResponseDTO: Decodable {
    let currentUser: MemberInfo
    let members: [MemberInfo]

    struct MemberInfo: Decodable {
        let userId: String
        let name: String
        let email: String
        let role: String
        let avatarUrl: String
    }
}

extension FetchMemberResponseDTO {
    func toDomain() -> MyTravelMember {
        MyTravelMember(
            myInfo: currentUser,
            memberInfo: members
        )
    }
}
