//
//  ExchangeRateResponseDTO.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//


import Foundation

public struct ExchangeRateResponseDTO: Decodable {
    public let baseCurrency: String
    public let quoteCurrency: String
    public let rate: Double
    public let date: String
    public let baseAmount: Double
    public let quoteAmount: Double
}
