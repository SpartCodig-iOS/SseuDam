//
//  MemberRole.swift
//  Domain
//
//  Created by 김민희 on 12/10/25.
//

import Foundation

public enum MemberRole: String, Equatable, Hashable, Decodable {
    case owner = "owner"
    case member = "member"
    
    public init(value: String?) {
        self = .init(rawValue: value?.lowercased() ?? "member") ?? .member
    }

    public var displayName: String {
        switch self {
        case .owner: return "관리자"
        case .member: return "참여자"
        }
    }
}
