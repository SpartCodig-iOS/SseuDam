//
//  FetchExchangeRateUseCaseProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Dependencies

public protocol FetchExchangeRateUseCaseProtocol {
    func execute(base: String) async throws -> ExchangeRate
}

public final class FetchExchangeRateUseCase: FetchExchangeRateUseCaseProtocol {
    @Dependency(\.exchangeRateRepository) private var repository: ExchangeRateRepositoryProtocol

    public init() {}
    public func execute(base: String) async throws -> ExchangeRate {
        try await repository.fetchExchangeRate(base: base)
    }
}

extension FetchExchangeRateUseCase: DependencyKey {
    public static var liveValue: FetchExchangeRateUseCaseProtocol = FetchExchangeRateUseCase()
    public static var previewValue: FetchExchangeRateUseCaseProtocol = FetchExchangeRateUseCase()
    public static var testValue: FetchExchangeRateUseCaseProtocol = FetchExchangeRateUseCase()
}

public extension DependencyValues {
    var fetchExchangeRateUseCase: FetchExchangeRateUseCaseProtocol {
        get { self[FetchExchangeRateUseCase.self] }
        set { self[FetchExchangeRateUseCase.self] = newValue }
    }
}


