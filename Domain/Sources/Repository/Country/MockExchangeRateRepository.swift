//
//  MockExchangeRateRepository.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//


import Foundation

public final class MockExchangeRateRepository: ExchangeRateRepositoryProtocol {
    public init() {}

    public func fetchExchangeRate(base: String) async throws -> ExchangeRate {

        let mockRates: [String: Double] = [
            "JPY": 8.77,
            "USD": 1330.5,
            "ARS": 1.52,
            "GBP": 1643.2
        ]

        let baseValue = mockRates[base] ?? 1.0

        return ExchangeRate(
            baseCurrency: base,
            quoteCurrency: "KRW",
            rate: baseValue
        )
    }
}
