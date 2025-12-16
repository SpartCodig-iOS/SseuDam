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
    @Dependency(\.countryRepository) private var repository: CountryRepositoryProtocol

    public init() {}
    public func execute() async throws -> [Country] {
        try await repository.fetchCountries()
    }
}

extension FetchCountriesUseCase: DependencyKey {
    public static var liveValue: FetchCountriesUseCaseProtocol = FetchCountriesUseCase()
    public static var previewValue: FetchCountriesUseCaseProtocol = FetchCountriesUseCase()
    public static var testValue: FetchCountriesUseCaseProtocol = FetchCountriesUseCase()
}

public extension DependencyValues {
    var fetchCountriesUseCase: FetchCountriesUseCaseProtocol {
        get { self[FetchCountriesUseCase.self] }
        set { self[FetchCountriesUseCase.self] = newValue }
    }
}
