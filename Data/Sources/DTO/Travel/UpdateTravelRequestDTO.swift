//
//  UpdateTravelRequestDTO.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain

public struct UpdateTravelRequestDTO: Encodable {
    let title: String
    let startDate: String
    let endDate: String
    let countryCode: String
    let countryNameKr: String
    let baseCurrency: String
    let baseExchangeRate: Double
}

extension UpdateTravelInput {
    func toDTO() -> UpdateTravelRequestDTO {
        let formatter = DateFormatters.apiDate

        return UpdateTravelRequestDTO(
            title: title,
            startDate: formatter.string(from: startDate),
            endDate: formatter.string(from: endDate),
            countryCode: countryCode,
            countryNameKr: koreanCountryName,
            baseCurrency: baseCurrency,
            baseExchangeRate: baseExchangeRate
        )
    }
}
