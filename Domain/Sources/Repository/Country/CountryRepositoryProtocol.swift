//
//  CountryRepositoryProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Dependencies

public protocol CountryRepositoryProtocol {
    func fetchCountries() async throws -> [Country]
}

// MARK: - Dependencies
public struct CountryRepositoryDependencyKey: DependencyKey {
    public static var liveValue: CountryRepositoryProtocol {
        fatalError("CountryRepositoryDependency liveValue not implemented")
    }
    public static var previewValue: CountryRepositoryProtocol = MockCountryRepository()
    public static var testValue: CountryRepositoryProtocol = MockCountryRepository()
}

public extension DependencyValues {
    var countryRepository: CountryRepositoryProtocol {
        get { self[CountryRepositoryDependencyKey.self] }
        set { self[CountryRepositoryDependencyKey.self] = newValue }
    }
}
