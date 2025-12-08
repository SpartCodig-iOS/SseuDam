//
//  MockSettlementRepository.swift
//  Domain
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation

final public actor MockSettlementRepository: SettlementRepositoryProtocol {
    private var mockSettlement: TravelSettlement?
    private var shouldFail = false

    public init() {}

    public func setShouldFail(_ value: Bool) {
        shouldFail = value
    }

    public func setMockSettlement(_ settlement: TravelSettlement) {
        mockSettlement = settlement
    }

    public func reset() {
        mockSettlement = nil
        shouldFail = false
    }

    public func fetchSettlement(travelId: String) async throws -> TravelSettlement {
        if shouldFail {
            throw SettlementRepositoryError.fetchFailed(reason: "Mock fetch failed")
        }

        if let mockSettlement = mockSettlement {
            return mockSettlement
        }

        // Return default mock data
        return TravelSettlement.mock
    }
}

// MARK: - Mock Data
extension TravelSettlement {
    public static var mock: TravelSettlement {
        TravelSettlement(
            balances: [
                MemberBalance(
                    id: "1",
                    memberId: "member1",
                    name: "홍길동",
                    balance: 50000
                ),
                MemberBalance(
                    id: "2",
                    memberId: "member2",
                    name: "김철수",
                    balance: -30000
                ),
                MemberBalance(
                    id: "3",
                    memberId: "member3",
                    name: "이영희",
                    balance: -20000
                )
            ],
            savedSettlements: [],
            recommendedSettlements: [
                Settlement(
                    id: "1",
                    fromMemberId: "member2",
                    fromMemberName: "김철수",
                    toMemberId: "member1",
                    toMemberName: "홍길동",
                    amount: 30000,
                    status: .pending
                ),
                Settlement(
                    id: "2",
                    fromMemberId: "member3",
                    fromMemberName: "이영희",
                    toMemberId: "member1",
                    toMemberName: "홍길동",
                    amount: 20000,
                    status: .pending
                )
            ]
        )
    }
}

// MARK: - Error
public enum SettlementRepositoryError: Error, LocalizedError {
    case fetchFailed(reason: String)

    public var errorDescription: String? {
        switch self {
        case .fetchFailed(let reason):
            return "정산 데이터 조회 실패: \(reason)"
        }
    }
}
