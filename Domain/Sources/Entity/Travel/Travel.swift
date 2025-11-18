//
//  Travel.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public struct Travel {
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let countryCode: String
    public let baseCurrency: String
    public let baseExchangeRate: Double
    public let inviteCode: String
    public let status: String
    public let role: String
    public let createdAt: Date
    public let ownerName: String
    public let members: [TravelMember]

    public init(id: String, title: String, startDate: Date, endDate: Date, countryCode: String, baseCurrency: String, baseExchangeRate: Double, inviteCode: String, status: String, role: String, createdAt: Date, ownerName: String, members: [TravelMember]) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.countryCode = countryCode
        self.baseCurrency = baseCurrency
        self.baseExchangeRate = baseExchangeRate
        self.inviteCode = inviteCode
        self.status = status
        self.role = role
        self.createdAt = createdAt
        self.ownerName = ownerName
        self.members = members
    }
}
