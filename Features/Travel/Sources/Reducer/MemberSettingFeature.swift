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

        public init(travel: Travel) {
            self.travel = travel
            self.members = travel.members
        }

        mutating func applyUpdatedTravel(_ travel: Travel) {
            self.travel = travel
            self.members = travel.members
        }

        var ownerId: String {
            members.first(where: { $0.role == .owner })?.id ?? ""
        }
    }

    public enum Action {
        case editButtonTapped

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case openMemberManage(travelId: String)
        }
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .editButtonTapped:
                return .send(.delegate(.openMemberManage(travelId: state.travel.id)))

            case .delegate:
                return .none
            }
        }
    }
}
