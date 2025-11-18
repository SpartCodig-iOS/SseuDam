//
//  TravelResponseDTO.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain

struct TravelResponseDTO: Decodable {
    let id: String
    let title: String
    let startDate: String
    let endDate: String
    let countryCode: String
    let baseCurrency: String
    let baseExchangeRate: Double
    let inviteCode: String
    let status: String
    let role: String
    let createdAt: String
    let ownerName: String
    let members: [TravelMemberDTO]
}
