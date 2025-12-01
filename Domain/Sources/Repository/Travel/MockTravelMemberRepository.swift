//
//  MockTravelMemberRepository.swift
//  Domain
//
//  Created by 김민희 on 12/1/25.
//

import Foundation

public final class MockTravelMemberRepository: TravelMemberRepositoryProtocol {
    private var travels: [Travel] = []
    private var counter: Int = 1

    public init() {
        // 초기 mock 데이터
        self.travels = Self.mockTravelList()
    }

    public func deleteMember(travelId: String, memberId: String) async throws {
        guard let index = travels.firstIndex(where: { $0.id == travelId }) else {
            throw NSError(domain: "Mock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Travel not found"])
        }

        let current = travels[index]
        let updatedMembers = current.members.filter { $0.id != memberId }
        let updated = Travel(
            id: current.id,
            title: current.title,
            startDate: current.startDate,
            endDate: current.endDate,
            countryCode: current.countryCode,
            baseCurrency: current.baseCurrency,
            baseExchangeRate: current.baseExchangeRate,
            inviteCode: current.inviteCode,
            status: current.status,
            role: current.role,
            createdAt: current.createdAt,
            ownerName: current.ownerName,
            members: updatedMembers
        )
        travels[index] = updated
    }

    public func joinTravel(inviteCode: String) async throws -> Travel {
        guard let index = travels.firstIndex(where: { $0.inviteCode == inviteCode }) else {
            throw NSError(domain: "Mock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid invite code"])
        }

        let current = travels[index]

        let newMember = TravelMember(
            id: "MOCK_JOIN_\(UUID().uuidString.prefix(6))",
            name: "NewMember-\(counter)",
            role: "member"
        )
        counter += 1

        var updatedMembers = current.members
        updatedMembers.append(newMember)

        let updated = Travel(
            id: current.id,
            title: current.title,
            startDate: current.startDate,
            endDate: current.endDate,
            countryCode: current.countryCode,
            baseCurrency: current.baseCurrency,
            baseExchangeRate: current.baseExchangeRate,
            inviteCode: current.inviteCode,
            status: current.status,
            role: current.role,
            createdAt: current.createdAt,
            ownerName: current.ownerName,
            members: updatedMembers
        )
        travels[index] = updated
        return updated
    }

    public func delegateOwner(travelId: String, newOwnerId: String) async throws -> Travel {
        guard let index = travels.firstIndex(where: { $0.id == travelId }) else {
            throw NSError(domain: "Mock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Travel not found"])
        }

        let current = travels[index]
        let newOwnerName: String = current.members.first(where: { $0.id == newOwnerId })?.name ?? current.ownerName

        let updated = Travel(
            id: current.id,
            title: current.title,
            startDate: current.startDate,
            endDate: current.endDate,
            countryCode: current.countryCode,
            baseCurrency: current.baseCurrency,
            baseExchangeRate: current.baseExchangeRate,
            inviteCode: current.inviteCode,
            status: current.status,
            role: current.role,
            createdAt: current.createdAt,
            ownerName: newOwnerName,
            members: current.members
        )
        travels[index] = updated
        return updated
    }

    public func leaveTravel(travelId: String) async throws {
        guard let index = travels.firstIndex(where: { $0.id == travelId }) else {
            throw NSError(domain: "Mock", code: 404, userInfo: [NSLocalizedDescriptionKey: "Travel not found"])
        }

        let current = travels[index]
        // 본인이 member라고 가정하고 id를 "MOCK_LEAVE"라고 가정 (실제 구현에서는 사용자 id 필요)
        let updatedMembers = current.members.filter { $0.id != "MOCK_LEAVE" }
        let updated = Travel(
            id: current.id,
            title: current.title,
            startDate: current.startDate,
            endDate: current.endDate,
            countryCode: current.countryCode,
            baseCurrency: current.baseCurrency,
            baseExchangeRate: current.baseExchangeRate,
            inviteCode: current.inviteCode,
            status: current.status,
            role: current.role,
            createdAt: current.createdAt,
            ownerName: current.ownerName,
            members: updatedMembers
        )
        travels[index] = updated
    }
}

private extension MockTravelMemberRepository {
    static func mockTravelList() -> [Travel] {
        _ = DateFormatters.apiDate
        let today = Date()

        return (1...25).map { i in
            Travel(
                id: "MOCK-\(i)",
                title: "여행 \(i)",
                startDate: today,
                endDate: Calendar.current.date(byAdding: .day, value: 5, to: today)!,
                countryCode: ["KR", "JP", "US"].randomElement()!,
                baseCurrency: "KRW",
                baseExchangeRate: 1.0,
                inviteCode: "INV-000\(i)",
                status: .active,
                role: "owner",
                createdAt: today,
                ownerName: "김민희",
                members: [TravelMember(id: "MOCKmember-\(i)", name: "친구1", role: "member")]
            )
        }
    }

    enum DateFormatters {
        static let apiDate: DateFormatter = {
            let f = DateFormatter()
            f.calendar = .init(identifier: .gregorian)
            f.locale = Locale(identifier: "ko_KR")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            f.dateFormat = "yyyy-MM-dd"
            return f
        }()

        static let apiDateTime: ISO8601DateFormatter = {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return f
        }()
    }
}
