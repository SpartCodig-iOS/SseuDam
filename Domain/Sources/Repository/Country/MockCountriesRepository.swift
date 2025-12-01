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
            Country(code: "KR", koreanName: "한국", englishName: "Korea", currencies: ["KRW"]),
            Country(code: "JP", koreanName: "일본", englishName: "Japan", currencies: ["JPY"]),
            Country(code: "US", koreanName: "미국", englishName: "United States", currencies: ["USD"]),
            Country(code: "GB", koreanName: "영국", englishName: "United Kingdom", currencies: ["GBP"]),
            Country(code: "AR", koreanName: "아르헨티나", englishName: "Argentina", currencies: ["ARS", "USD"])
        ]
    }
}
