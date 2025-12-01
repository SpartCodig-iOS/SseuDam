//
//  FetchExchangeRateUseCaseProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Dependencies

public protocol FetchExchangeRateUseCaseProtocol {
    func execute(quote: String) async throws -> ExchangeRate
}

public final class FetchExchangeRateUseCase: FetchExchangeRateUseCaseProtocol {
    private let repository: ExchangeRateRepositoryProtocol

    public init(repository: ExchangeRateRepositoryProtocol) {
        self.repository = repository
    }
    public func execute(quote: String) async throws -> ExchangeRate {
        try await repository.fetchExchangeRate(quote: quote)
    }
}

extension FetchExchangeRateUseCase: DependencyKey {
    public static var liveValue: FetchExchangeRateUseCaseProtocol = {
        FetchExchangeRateUseCase(repository: MockExchangeRateRepository())
    }()

    public static var previewValue: FetchExchangeRateUseCaseProtocol = {
        FetchExchangeRateUseCase(repository: MockExchangeRateRepository())
    }()

    public static var testValue: FetchExchangeRateUseCaseProtocol = {
        FetchExchangeRateUseCase(repository: MockExchangeRateRepository())
    }()
}

public extension DependencyValues {
    var fetchExchangeRateUseCase: FetchExchangeRateUseCaseProtocol {
        get { self[FetchExchangeRateUseCase.self] }
        set { self[FetchExchangeRateUseCase.self] = newValue }
    }
}


