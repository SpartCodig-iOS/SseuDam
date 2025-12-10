//
//  MemberSettingFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import UIKit
import Domain
import ComposableArchitecture

@Reducer
public struct MemberSettingFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable {
        var travel: Travel
        var members: [TravelMember]
        var ownerId: String
        var isSubmitting = false
        var errorMessage: String?
        var deletingMemberId: String?

        public init(travel: Travel) {
            self.travel = travel
            self.members = travel.members
            self.ownerId = travel.members.first(where: { $0.role == .owner })?.id ?? ""
        }

        mutating func applyUpdatedTravel(_ travel: Travel) {
            self.travel = travel
            self.members = travel.members
            self.ownerId = travel.members.first(where: { $0.role == .owner })?.id ?? ""
        }
    }

    public enum Action {
        case delegateOwnerTapped(String)
        case delegateOwnerResponse(Result<Travel, Error>)
        case deleteMemberTapped(String)
        case deleteMemberResponse(Result<Void, Error>)
        case copyDeepLinkTapped

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case needRefresh
        }
    }

    @Dependency(\.delegateOwnerUseCase) var delegateOwnerUseCase
    @Dependency(\.deleteTravelMemberUseCase) var deleteTravelMemberUseCase

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .delegateOwnerTapped(let newId):
                state.isSubmitting = true
                return .run {
                    [travelId = state.travel.id,
                     delegateOwnerUseCase] send in
                    do {
                        let updated = try await delegateOwnerUseCase.execute(travelId: travelId, newOwnerId: newId)
                        await send(.delegateOwnerResponse(.success(updated)))
                    } catch {
                        await send(.delegateOwnerResponse(.failure(error)))
                    }
                }

            case .delegateOwnerResponse(.success(let updated)):
                state.isSubmitting = false
                state.travel = updated
                state.members = updated.members
                state.ownerId = updated.ownerName
                return .send(.delegate(.needRefresh))

            case .delegateOwnerResponse(.failure(let err)):
                state.isSubmitting = false
                state.errorMessage = err.localizedDescription
                return .none

            case .deleteMemberTapped(let id):
                state.isSubmitting = true
                state.deletingMemberId = id
                let travelId = state.travel.id

                return .run { send in
                    do {
                        try await deleteTravelMemberUseCase.execute(travelId: travelId, memberId: id)
                        await send(.deleteMemberResponse(.success(())))
                    } catch {
                        await send(.deleteMemberResponse(.failure(error)))
                    }
                }

            case .deleteMemberResponse(.success):
                state.isSubmitting = false
                if let id = state.deletingMemberId {
                    state.members.removeAll { $0.id == id }
                }
                state.deletingMemberId = nil
                return .send(.delegate(.needRefresh))

            case .deleteMemberResponse(.failure(let err)):
                state.isSubmitting = false
                state.errorMessage = err.localizedDescription
                state.deletingMemberId = nil
                return .none
                
            case .copyDeepLinkTapped:
                // 딥링크 복사 기능
                if let deepLink = state.travel.deepLink {
                    let shareMessage = """
   🚀 \(state.travel.title) 여행에 초대합니다!

기간: \(DateFormatters.display.string(from: state.travel.startDate)) ~ \(DateFormatters.display.string(from: state.travel.endDate))

아래 링크를 클릭하면 바로 참여할 수 있어요:
\(deepLink)
"""
                    UIPasteboard.general.string = shareMessage
                }
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

private enum DateFormatters {
    static let display: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
}
