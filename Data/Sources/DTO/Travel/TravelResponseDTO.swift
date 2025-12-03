//
//  TravelResponseDTO.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain

public struct TravelResponseDTO: Decodable {
    let total: Int
    let page: Int
    let limit: Int
    let items: [TravelDTO]
}

public struct TravelDTO: Decodable {
    let id: String
    let title: String
    let startDate: String
    let endDate: String
    let countryCode: String
    let countryNameKr: String
    let baseCurrency: String
    let baseExchangeRate: Double
    let destinationCurrency: String
    let inviteCode: String?
    let deepLink: String?
    let status: String
    let role: String?
    let createdAt: String
    let ownerName: String
    let members: [TravelMemberDTO]
}

extension TravelDTO {
    func toDomain() -> Travel {
        let dateFormatter = DateFormatters.apiDate
        let dateTimeFormatter = DateFormatters.apiDateTime

        return Travel(
            id: id,
            title: title,
            startDate: dateFormatter.date(from: startDate) ?? Date(),
            endDate: dateFormatter.date(from: endDate) ?? Date(),
            countryCode: countryCode,
            koreanCountryName: countryNameKr,
            baseCurrency: destinationCurrency,
            baseExchangeRate: baseExchangeRate,
            destinationCurrency: destinationCurrency,
            inviteCode: inviteCode,
            deepLink: deepLink,
            status: TravelStatus(rawValue: status) ?? .unknown,
            role: role,
            createdAt: dateTimeFormatter.date(from: createdAt) ?? Date(),
            ownerName: ownerName,
            members: members.map { $0.toDomain() }
        )
    }
}
