//
//  TravelMember.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public struct TravelMember {
    public let id: String
    public let name: String
    public let role: String

    public init(id: String, name: String, role: String) {
        self.id = id
        self.name = name
        self.role = role
    }
}
