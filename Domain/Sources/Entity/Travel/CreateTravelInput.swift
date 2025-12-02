//
//  CreateTravelInput.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public struct CreateTravelInput {
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let countryCode: String
    public let koreanCountryName: String
    public let baseCurrency: String
    public let baseExchangeRate: Double
    public let destinationCurrency: String?

    public init(
        title: String,
        startDate: Date,
        endDate: Date,
        countryCode: String,
        koreanCountryName: String,
        baseCurrency: String,
        baseExchangeRate: Double,
        destinationCurrency: String? = nil
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.countryCode = countryCode
        self.koreanCountryName = koreanCountryName
        self.baseCurrency = baseCurrency
        self.baseExchangeRate = baseExchangeRate
        self.destinationCurrency = destinationCurrency
    }
}
