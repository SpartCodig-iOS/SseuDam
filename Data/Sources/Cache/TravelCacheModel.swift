//
//  TravelCacheModel.swift
//  Data
//
//  Created by 김민희 on 12/15/25.
//

import Foundation
import SwiftData
import Domain

@Model
final class TravelCacheEntity {
    @Attribute(.unique) var statusRawValue: String
    var cachedAt: Date
    @Relationship(deleteRule: .cascade)
    var travels: [TravelCacheItemEntity]

    init(
        status: TravelStatus,
        cachedAt: Date,
        travels: [TravelCacheItemEntity] = []
    ) {
        self.statusRawValue = status.rawValue
        self.cachedAt = cachedAt
        self.travels = travels
    }

    var status: TravelStatus {
        TravelStatus(rawValue: statusRawValue) ?? .unknown
    }

    // 현재 시간 기준으로 6시간이 지났으면 만료
    var isExpired: Bool {
        Date().timeIntervalSince(cachedAt) > TravelCacheConstants.expiration
    }
}

@Model
final class TravelCacheItemEntity {
    // 여행 기본 정보
    var id: String
    var title: String
    var startDate: Date
    var endDate: Date
    // 국가 / 통화 관련
    var countryCode: String
    var koreanCountryName: String
    var baseCurrency: String
    var baseExchangeRate: Double
    var destinationCurrency: String
    // 초대 관련
    var inviteCode: String?
    var deepLink: String?
    // 상태 / 역할
    var statusRawValue: String
    var role: String?
    // 생성 정보
    var createdAt: Date
    var ownerName: String
    // 사용 통화 목록
    var currencies: [String]
    // 정렬 순서 (UI 표시용)
    var orderIndex: Int
    // 여행 멤버 목록
    // 여행 삭제 시 멤버도 함께 삭제
    @Relationship(deleteRule: .cascade)
    var members: [TravelCacheMemberEntity]

    init(
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        countryCode: String,
        koreanCountryName: String,
        baseCurrency: String,
        baseExchangeRate: Double,
        destinationCurrency: String,
        inviteCode: String?,
        deepLink: String?,
        statusRawValue: String,
        role: String?,
        createdAt: Date,
        ownerName: String,
        members: [TravelCacheMemberEntity] = [],
        currencies: [String] = [],
        orderIndex: Int
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.countryCode = countryCode
        self.koreanCountryName = koreanCountryName
        self.baseCurrency = baseCurrency
        self.baseExchangeRate = baseExchangeRate
        self.destinationCurrency = destinationCurrency
        self.inviteCode = inviteCode
        self.deepLink = deepLink
        self.statusRawValue = statusRawValue
        self.role = role
        self.createdAt = createdAt
        self.ownerName = ownerName
        self.members = members
        self.currencies = currencies
        self.orderIndex = orderIndex
    }

    var status: TravelStatus {
        TravelStatus(rawValue: statusRawValue) ?? .unknown
    }

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
            currencies: currencies.isEmpty ? nil : currencies
        )
    }
}

@Model
final class TravelCacheMemberEntity {
    var id: String
    var name: String
    var roleRawValue: String
    var email: String?
    var avatarUrl: String?
    init(
        id: String,
        name: String,
        roleRawValue: String,
        email: String?,
        avatarUrl: String?
    ) {
        self.id = id
        self.name = name
        self.roleRawValue = roleRawValue
        self.email = email
        self.avatarUrl = avatarUrl
    }

    var role: MemberRole {
        MemberRole(rawValue: roleRawValue) ?? .member
    }

    func toDomain() -> TravelMember {
        TravelMember(
            id: id,
            name: name,
            role: role,
            email: email,
            avatarUrl: avatarUrl
        )
    }
}

enum TravelCacheConstants {
    static let expiration: TimeInterval = 60 * 60 * 6 // 6 시간
}

extension Travel {
    func toCacheModel(orderIndex: Int) -> TravelCacheItemEntity {
        TravelCacheItemEntity(
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
            members: members.map { $0.toCacheModel() },
            currencies: currencies ?? [],
            orderIndex: orderIndex
        )
    }
}

extension TravelMember {
    func toCacheModel() -> TravelCacheMemberEntity {
        TravelCacheMemberEntity(
            id: id,
            name: name,
            roleRawValue: role.rawValue,
            email: email,
            avatarUrl: avatarUrl
        )
    }
}
