//
//  MemberRole.swift
//  Domain
//
//  Created by 김민희 on 12/10/25.
//

import Foundation

public enum MemberRole: String, Equatable, Hashable {
    case owner = "owner"
    case member = "member"

    public var displayName: String {
        switch self {
        case .owner: return "관리자"
        case .member: return "참여자"
        }
    }
}

extension MemberRole: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        let normalizedValue = value.lowercased()

        if let role = MemberRole(rawValue: normalizedValue) {
            self = role
            return
        }

        switch value {
        case "관리자":
            self = .owner
        case "참여자":
            self = .member
        default:
            self = .member
        }
    }
}
