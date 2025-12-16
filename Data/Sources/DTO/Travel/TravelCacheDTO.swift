//
//  TravelCacheDTO.swift
//  Data
//
//  Created by 김민희 on 12/15/25.
//

import Foundation
import Domain

public struct TravelCacheDTO: Codable {
    let statusRawValue: String
    let cachedAt: Date
    let travels: [TravelCacheItemDTO]

    var status: TravelStatus {
        TravelStatus(rawValue: statusRawValue) ?? .unknown
    }

    var isExpired: Bool {
        Date().timeIntervalSince(cachedAt) > TravelCacheConstants.expiration
    }
}

public struct TravelCacheItemDTO: Codable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let countryCode: String
    let koreanCountryName: String
    let baseCurrency: String
    let baseExchangeRate: Double
    let destinationCurrency: String
    let inviteCode: String?
    let deepLink: String?
    let statusRawValue: String
    let role: String?
    let createdAt: Date
    let ownerName: String
    let members: [TravelCacheMemberDTO]
    let currencies: [String]?

    var status: TravelStatus {
        TravelStatus(rawValue: statusRawValue) ?? .unknown
    }
}

struct TravelCacheMemberDTO: Codable {
    let id: String
    let name: String
    let role: String
    let email: String?
    let avatarUrl: String?
}

enum TravelCacheConstants {
    static let directoryName = "travels"
    static let expiration: TimeInterval = 60 * 60 * 6 // 6 hours
}

extension TravelCacheItemDTO {
    func toDomain() -> Travel {
        Travel(
            id: id,
            title: title,
            startDate: startDate,
            endDate: endDate,
            countryCode: countryCode,
            koreanCountryName: koreanCountryName,
            baseCurrency: baseCurrency,
            baseExchangeRate: baseExchangeRate,
            destinationCurrency: destinationCurrency,
            inviteCode: inviteCode,
            deepLink: deepLink,
            status: status,
            role: role,
            createdAt: createdAt,
            ownerName: ownerName,
            members: members.map { $0.toDomain() },
            currencies: currencies
        )
    }
}

extension TravelCacheMemberDTO {
    func toDomain() -> TravelMember {
        TravelMember(
            id: id,
            name: name,
            role: MemberRole(value: role),
            email: email,
            avatarUrl: avatarUrl
        )
    }
}

extension Travel {
    func toCacheItem() -> TravelCacheItemDTO {
        TravelCacheItemDTO(
            id: id,
            title: title,
            startDate: startDate,
            endDate: endDate,
            countryCode: countryCode,
            koreanCountryName: koreanCountryName,
            baseCurrency: baseCurrency,
            baseExchangeRate: baseExchangeRate,
            destinationCurrency: destinationCurrency,
            inviteCode: inviteCode,
            deepLink: deepLink,
            statusRawValue: status.rawValue,
            role: role,
            createdAt: createdAt,
            ownerName: ownerName,
            members: members.map { $0.toCacheItem() },
            currencies: currencies
        )
    }
}

extension TravelMember {
    func toCacheItem() -> TravelCacheMemberDTO {
        TravelCacheMemberDTO(
            id: id,
            name: name,
            role: role.rawValue,
            email: email,
            avatarUrl: avatarUrl
        )
    }
}
