//
//  UpdateTravelRequestDTO.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

struct UpdateTravelRequestDTO: Encodable {
  let title: String
  let startDate: String
  let endDate: String
  let countryCode: String
  let baseCurrency: String
  let baseExchangeRate: Double
}
