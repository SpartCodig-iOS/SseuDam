//
//  Country.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation

public struct Country: Equatable, Hashable {
    public let code: String
    public let koreanName: String
    public let englishName: String
    public let currencies: [String]

    public init(
        code: String,
        koreanName: String,
        englishName: String,
        currencies: [String]
    ) {
        self.code = code
        self.koreanName = koreanName
        self.englishName = englishName
        self.currencies = currencies
    }
}
