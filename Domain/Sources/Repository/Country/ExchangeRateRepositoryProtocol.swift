//
//  ExchangeRateRepositoryProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation

public protocol ExchangeRateRepositoryProtocol {
    func fetchExchangeRate(quote: String) async throws -> ExchangeRate
}
