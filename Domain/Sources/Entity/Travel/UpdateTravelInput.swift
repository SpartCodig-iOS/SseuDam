//
//  UpdateTravelInput.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public struct UpdateTravelInput {
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let countryCode: String
    public let baseCurrency: String
    public let baseExchangeRate: Double
}
