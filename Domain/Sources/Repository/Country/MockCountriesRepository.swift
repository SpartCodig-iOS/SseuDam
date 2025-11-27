//
//  MockCountriesRepository.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//


import Foundation

public final class MockCountriesRepository: CountryRepositoryProtocol {

    public init() {}

    public func fetchCountries() async throws -> [Country] {
        return [
            Country(code: "KR", nameKo: "한국", nameEn: "Korea", currencies: ["KRW"]),
            Country(code: "JP", nameKo: "일본", nameEn: "Japan", currencies: ["JPY"]),
            Country(code: "US", nameKo: "미국", nameEn: "United States", currencies: ["USD"]),
            Country(code: "GB", nameKo: "영국", nameEn: "United Kingdom", currencies: ["GBP"]),
            Country(code: "AR", nameKo: "아르헨티나", nameEn: "Argentina", currencies: ["ARS", "USD"])
        ]
    }
}
