//
//  TravelMapper.swift
//  Data
//
//  Created by 김민희 on 11/17/25.
//

import Foundation
import Domain

extension TravelMemberDTO {
    func toDomain() -> TravelMember {
        TravelMember(
            id: userId,
            name: name,
            role: role
        )
    }
}

extension TravelResponseDTO {
    func toDomain() -> Travel {
        let dateFormatter = DateFormatters.apiDate
        let dateTimeFormatter = DateFormatters.apiDateTime

        return Travel(
            id: id,
            title: title,
            startDate: dateFormatter.date(from: startDate) ?? Date(),
            endDate: dateFormatter.date(from: endDate) ?? Date(),
            countryCode: countryCode,
            baseCurrency: baseCurrency,
            baseExchangeRate: baseExchangeRate,
            inviteCode: inviteCode,
            status: TravelStatus(rawValue: status) ?? .unknown,
            role: role,
            createdAt: dateTimeFormatter.date(from: createdAt) ?? Date(),
            ownerName: ownerName,
            members: members.map { $0.toDomain() }
        )
    }
}

extension FetchTravelsInput {
    func toDTO() -> FetchTravelsRequestDTO {
        FetchTravelsRequestDTO(limit: limit, page: page)
    }
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

extension UpdateTravelInput {
    func toDTO() -> UpdateTravelRequestDTO {
        let formatter = DateFormatters.apiDate

        return UpdateTravelRequestDTO(
            title: title,
            startDate: formatter.string(from: startDate),
            endDate: formatter.string(from: endDate),
            countryCode: countryCode,
            baseCurrency: baseCurrency,
            baseExchangeRate: baseExchangeRate
        )
    }
}

