//
//  CountryRepository.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Domain

public final class CountryRepository: CountryRepositoryProtocol {
    private let remote: CountryRemoteDataSourceProtocol

    public init(remote: CountryRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func fetchCountries() async throws -> [Country] {
        try await remote.fetchCountries().map {
            Country(
                code: $0.code,
                nameKo: $0.nameKo,
                nameEn: $0.nameEn,
                currencies: $0.currencies
            )
        }
    }
}
