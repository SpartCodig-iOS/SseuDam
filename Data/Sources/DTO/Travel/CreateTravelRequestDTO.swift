//
//  CreateTravelRequestDTO.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain

public struct CreateTravelRequestDTO: Encodable {
    let title: String
    let startDate: String
    let endDate: String
    let countryCode: String
    let baseCurrency: String
    let baseExchangeRate: Double
}

extension CreateTravelInput {
    func toDTO() -> CreateTravelRequestDTO {
        let formatter = DateFormatters.apiDate

        return CreateTravelRequestDTO(
            title: title,
            startDate: formatter.string(from: startDate),
            endDate: formatter.string(from: endDate),
            countryCode: countryCode,
            baseCurrency: baseCurrency,
            baseExchangeRate: baseExchangeRate
        )
    }
}
