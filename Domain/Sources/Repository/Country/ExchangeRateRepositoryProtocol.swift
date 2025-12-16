//
//  ExchangeRateRepositoryProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Dependencies

public protocol ExchangeRateRepositoryProtocol {
    func fetchExchangeRate(base: String) async throws -> ExchangeRate
}

public struct ExchangeRateRepositoryDependencyKey: DependencyKey {
    public static var liveValue: ExchangeRateRepositoryProtocol {
        fatalError("ExchangeRateRepositoryDependencyKey liveValue not implemented")
    }
    public static var previewValue: ExchangeRateRepositoryProtocol = MockExchangeRateRepository()
    public static var testValue: ExchangeRateRepositoryProtocol = MockExchangeRateRepository()
}

public extension DependencyValues {
    var exchangeRateRepository: ExchangeRateRepositoryProtocol {
        get { self[ExchangeRateRepositoryDependencyKey.self] }
        set { self[ExchangeRateRepositoryDependencyKey.self] = newValue }
    }
}
