//
//  Country.swift
//  Domain
//
//  Created by 김민희 on 11/27/25.
//

import Foundation

public struct Country: Equatable {
    public let code: String
    public let nameKo: String
    public let nameEn: String
    public let currencies: [String]

    public init(
        code: String,
        nameKo: String,
        nameEn: String,
        currencies: [String]
    ) {
        self.code = code
        self.nameKo = nameKo
        self.nameEn = nameEn
        self.currencies = currencies
    }
}
