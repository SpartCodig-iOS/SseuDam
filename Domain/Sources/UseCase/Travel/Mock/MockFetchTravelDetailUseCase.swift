//
//  MockFetchTravelDetailUseCase.swift
//  Domain
//
//  Created by SseuDam on 2025.
//

import Foundation

public final class MockFetchTravelDetailUseCase: FetchTravelDetailUseCaseProtocol {
    private var mockTravel: Travel?
    private var shouldThrowError = false
    private var errorToThrow: Error?

    public init() {}

    // MARK: - Configuration Methods

    public func setMockTravel(_ travel: Travel) {
        self.mockTravel = travel
    }

    public func setShouldThrowError(_ error: Error) {
        self.shouldThrowError = true
        self.errorToThrow = error
    }

    public func reset() {
        mockTravel = nil
        shouldThrowError = false
        errorToThrow = nil
    }

    // MARK: - FetchTravelDetailUseCaseProtocol

    public func execute(id: String) async throws -> Travel {
        if shouldThrowError {
            throw errorToThrow ?? MockTravelError.fetchFailed
        }

        if let mockTravel = mockTravel {
            return mockTravel
        }

        // 기본 Mock 데이터 반환
        return Travel.mockDefault
    }
}

// MARK: - Mock Error

public enum MockTravelError: Error {
    case fetchFailed
    case notFound
}

// MARK: - Travel Mock Extension

public extension Travel {
    static var mockDefault: Travel {
        Travel(
            id: "mock-travel-1",
            title: "일본 도쿄 여행",
            startDate: Date().addingTimeInterval(-86400 * 3), // 3일 전
            endDate: Date().addingTimeInterval(86400 * 3), // 3일 후
            countryCode: "JP",
            koreanCountryName: "일본",
            baseCurrency: "KRW",
            baseExchangeRate: 900.0, // 1 JPY = 900 KRW
            destinationCurrency: "JPY",
            inviteCode: "TOKYO2025",
            status: .active,
            role: "owner",
            createdAt: Date().addingTimeInterval(-86400 * 30), // 30일 전
            ownerName: "홍석현",
            members: [
                TravelMember(id: "member-1", name: "홍석현", role: "owner"),
                TravelMember(id: "member-2", name: "김철수", role: "member"),
                TravelMember(id: "member-3", name: "이영희", role: "member"),
                TravelMember(id: "member-4", name: "박민수", role: "member")
            ]
        )
    }

    static var mockUSA: Travel {
        Travel(
            id: "mock-travel-2",
            title: "미국 뉴욕 출장",
            startDate: Date().addingTimeInterval(86400 * 14), // 14일 후
            endDate: Date().addingTimeInterval(86400 * 21), // 21일 후
            countryCode: "US",
            koreanCountryName: "미국",
            baseCurrency: "KRW",
            baseExchangeRate: 1350.0, // 1 USD = 1350 KRW
            destinationCurrency: "USD",
            inviteCode: "NYC2025",
            status: .archived,
            role: "member",
            createdAt: Date().addingTimeInterval(-86400 * 7), // 7일 전
            ownerName: "김철수",
            members: [
                TravelMember(id: "member-1", name: "김철수", role: "owner"),
                TravelMember(id: "member-2", name: "홍석현", role: "member")
            ]
        )
    }

    static var mockEurope: Travel {
        Travel(
            id: "mock-travel-3",
            title: "유럽 배낭여행",
            startDate: Date().addingTimeInterval(-86400 * 7), // 7일 전 (진행 중)
            endDate: Date().addingTimeInterval(86400 * 14), // 14일 후
            countryCode: "FR",
            koreanCountryName: "프랑스",
            baseCurrency: "KRW",
            baseExchangeRate: 1450.0, // 1 EUR = 1450 KRW
            destinationCurrency: "EUR",
            inviteCode: "EUROPE2025",
            status: .active,
            role: "owner",
            createdAt: Date().addingTimeInterval(-86400 * 60), // 60일 전
            ownerName: "이영희",
            members: [
                TravelMember(id: "member-1", name: "이영희", role: "owner"),
                TravelMember(id: "member-2", name: "박민수", role: "member"),
                TravelMember(id: "member-3", name: "홍석현", role: "member")
            ]
        )
    }

    static var mockCompleted: Travel {
        Travel(
            id: "mock-travel-4",
            title: "제주도 여행",
            startDate: Date().addingTimeInterval(-86400 * 14), // 14일 전
            endDate: Date().addingTimeInterval(-86400 * 7), // 7일 전 (완료)
            countryCode: "KR",
            koreanCountryName: "한국",
            baseCurrency: "KRW",
            baseExchangeRate: 1.0, // 원화는 환율 변환 불필요
            destinationCurrency: "KRW",
            inviteCode: "JEJU2024",
            status: .active,
            role: "member",
            createdAt: Date().addingTimeInterval(-86400 * 90), // 90일 전
            ownerName: "박민수",
            members: [
                TravelMember(id: "member-1", name: "박민수", role: "owner"),
                TravelMember(id: "member-2", name: "홍석현", role: "member"),
                TravelMember(id: "member-3", name: "김철수", role: "member"),
                TravelMember(id: "member-4", name: "이영희", role: "member")
            ]
        )
    }
}
