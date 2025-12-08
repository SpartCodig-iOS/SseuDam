//
//  Travel.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public struct Travel: Equatable, Hashable {
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let countryCode: String
    public let koreanCountryName: String
    public let baseCurrency: String
    public let baseExchangeRate: Double
    public let destinationCurrency: String
    public let inviteCode: String?
    public let deepLink: String?
    public let status: TravelStatus
    public let role: String?
    public let createdAt: Date
    public let ownerName: String
    public let members: [TravelMember]
    public let currencies: [String]?

    public init(
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        countryCode: String,
        koreanCountryName:String,
        baseCurrency: String,
        baseExchangeRate: Double,
        destinationCurrency: String,
        inviteCode: String? = nil,
        deepLink: String? = nil,
        status: TravelStatus,
        role: String? = nil,
        createdAt: Date,
        ownerName: String,
        members: [TravelMember],
        currencies: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.countryCode = countryCode
        self.koreanCountryName = koreanCountryName
        self.baseCurrency = baseCurrency
        self.baseExchangeRate = baseExchangeRate
        self.destinationCurrency = destinationCurrency
        self.inviteCode = inviteCode
        self.deepLink = deepLink
        self.status = status
        self.role = role
        self.createdAt = createdAt
        self.ownerName = ownerName
        self.members = members
        self.currencies = currencies
    }
}
