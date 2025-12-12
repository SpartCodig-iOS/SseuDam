//
//  FetchMemberResponseDTO.swift
//  Data
//
//  Created by 김민희 on 12/10/25.
//

import Foundation
import Domain

public struct FetchMemberResponseDTO: Decodable {
    let currentUser: MemberDTO
    let members: [MemberDTO]
}

extension FetchMemberResponseDTO {
    func toDomain() -> MyTravelMember {
        MyTravelMember(
            myInfo: currentUser.toDomain(),
            memberInfo: members.map { $0.toDomain() }
        )
    }
}
