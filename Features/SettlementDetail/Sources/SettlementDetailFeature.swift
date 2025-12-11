//
//  SettlementDetailFeature.swift
//  SettlementDetailFeature
//
//  Created by 홍석현 on 2025.
//

import Foundation
import ComposableArchitecture
import Domain

@Reducer
public struct SettlementDetailFeature {
    @ObservableState
    public struct State: Equatable {
        var memberDetails: [MemberSettlementDetail]
        var currentUserId: String
        var expandedMemberIds: Set<String> = []

        public init(
            memberDetails: [MemberSettlementDetail],
            currentUserId: String
        ) {
            self.memberDetails = memberDetails
            self.currentUserId = currentUserId
            // 내 정보는 기본으로 펼쳐놓기
            self.expandedMemberIds = [currentUserId]
        }

        var myDetail: MemberSettlementDetail? {
            memberDetails.first { $0.memberId == currentUserId }
        }

        var otherMemberDetails: [MemberSettlementDetail] {
            memberDetails.filter { $0.memberId != currentUserId }
        }
    }

    public enum Action: Equatable {
        case toggleMemberExpansion(String)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .toggleMemberExpansion(let memberId):
                if state.expandedMemberIds.contains(memberId) {
                    state.expandedMemberIds.remove(memberId)
                } else {
                    state.expandedMemberIds.insert(memberId)
                }
                return .none
            }
        }
    }
}
