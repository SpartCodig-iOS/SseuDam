//
//  MemberSettingFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
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
            self.ownerId = travel.ownerName
        }
    }

    public enum Action {
        case delegateOwnerTapped(String)
        case delegateOwnerResponse(Result<Travel, Error>)
        case deleteMemberTapped(String)
        case deleteMemberResponse(Result<Void, Error>)

        case updated(Travel)
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
                return .send(.updated(updated))

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
                return .none

            case .deleteMemberResponse(.failure(let err)):
                state.isSubmitting = false
                state.errorMessage = err.localizedDescription
                state.deletingMemberId = nil
                return .none

            case .updated:
                return .none
            }
        }
    }
}
