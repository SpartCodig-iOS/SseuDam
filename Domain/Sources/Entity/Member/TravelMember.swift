//
//  TravelMember.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public struct TravelMember: Identifiable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let role: MemberRole
    public let email: String?
    public let avatarUrl: String?

    public init(
        id: String,
        name: String,
        role: MemberRole,
        email: String? = nil,
        avatarUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.email = email
        self.avatarUrl = avatarUrl
    }
}
