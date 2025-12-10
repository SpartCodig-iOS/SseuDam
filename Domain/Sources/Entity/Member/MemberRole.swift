//
//  MemberRole.swift
//  Domain
//
//  Created by 김민희 on 12/10/25.
//

import Foundation

public enum MemberRole: String, Equatable, Hashable, Decodable {
    case owner = "관리자"
    case member = "참여자"
}
