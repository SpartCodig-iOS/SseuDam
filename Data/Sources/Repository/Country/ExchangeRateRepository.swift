//
//  ExchangeRateRepository.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Domain

public final class ExchangeRateRepository: ExchangeRateRepositoryProtocol {
    private let remote: ExchangeRateRemoteDataSourceProtocol

    public init(remote: ExchangeRateRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func fetchExchangeRate(base: String) async throws -> ExchangeRate {
        let dto = try await remote.fetchExchangeRate(base: base)
        return ExchangeRate(
            baseCurrency: dto.baseCurrency,
            quoteCurrency: dto.quoteCurrency,
            rate: dto.quoteAmount
        )
    }
}
