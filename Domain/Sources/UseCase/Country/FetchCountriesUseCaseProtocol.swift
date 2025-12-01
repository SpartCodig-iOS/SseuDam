//
//  FetchCountriesUseCaseProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Dependencies

public protocol FetchCountriesUseCaseProtocol {
    func execute() async throws -> [Country]
}

public final class FetchCountriesUseCase: FetchCountriesUseCaseProtocol {
    private let repository: CountryRepositoryProtocol

    public init(repository: CountryRepositoryProtocol) {
        self.repository = repository
    }
    public func execute() async throws -> [Country] {
        try await repository.fetchCountries()
    }
}

extension FetchCountriesUseCase: DependencyKey {
    public static var liveValue: FetchCountriesUseCaseProtocol = {
        FetchCountriesUseCase(repository: MockCountriesRepository())
    }()

    public static var previewValue: FetchCountriesUseCaseProtocol = {
        FetchCountriesUseCase(repository: MockCountriesRepository())
    }()

    public static var testValue: FetchCountriesUseCaseProtocol = {
        FetchCountriesUseCase(repository: MockCountriesRepository())
    }()
}

public extension DependencyValues {
    var fetchCountriesUseCase: FetchCountriesUseCaseProtocol {
        get { self[FetchCountriesUseCase.self] }
        set { self[FetchCountriesUseCase.self] = newValue }
    }
}
