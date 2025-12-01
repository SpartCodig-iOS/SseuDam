//
//  ExchangeRate.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation

public struct ExchangeRate: Equatable {
    public let baseCurrency: String
    public let quoteCurrency: String
    public let rate: Double

    public init(
        baseCurrency: String,
        quoteCurrency: String,
        rate: Double
    ) {
        self.baseCurrency = baseCurrency
        self.quoteCurrency = quoteCurrency
        self.rate = rate
    }
}
