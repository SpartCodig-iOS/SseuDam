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

    private enum CodingKeys: String, CodingKey {
        case total, page, limit, items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intTotal = try? container.decode(Int.self, forKey: .total) {
            self.total = intTotal
        } else if let stringTotal = try? container.decode(String.self, forKey: .total),
                  let intTotal = Int(stringTotal) {
            self.total = intTotal
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .total,
                in: container,
                debugDescription: "Expected total to be Int or numeric String."
            )
        }

        self.page = try container.decode(Int.self, forKey: .page)
        self.limit = try container.decode(Int.self, forKey: .limit)
        self.items = try container.decode([TravelDTO].self, forKey: .items)
    }
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
    let countryCurrencies: [String]?
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
            baseCurrency: baseCurrency,
            baseExchangeRate: baseExchangeRate,
            destinationCurrency: destinationCurrency,
            inviteCode: inviteCode,
            deepLink: deepLink,
            status: TravelStatus(rawValue: status) ?? .unknown,
            role: role,
            createdAt: dateTimeFormatter.date(from: createdAt) ?? Date(),
            ownerName: ownerName,
            members: members.map { $0.toDomain() },
            currencies: countryCurrencies
        )
    }
}
