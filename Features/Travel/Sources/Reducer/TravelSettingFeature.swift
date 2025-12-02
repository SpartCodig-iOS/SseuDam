//
//  TravelSettingFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct TravelSettingFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable {
        var basicInfo: BasicSettingFeature.State
        var memberSetting: MemberSettingFeature.State
        var manage: TravelManageFeature.State

        var shouldDismiss = false

        public init(travel: Travel) {
            self.basicInfo = .init(travel: travel)
            self.memberSetting = .init(travel: travel)
            self.manage = .init(
                travelId: travel.id,
                isOwner: travel.role == "owner"
            )
        }

    }

    public enum Action {
        case basicInfo(BasicSettingFeature.Action)
        case memberSetting(MemberSettingFeature.Action)
        case manage(TravelManageFeature.Action)

        case dismiss
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .basicInfo(.updated(let updatedTravel)):
                state.memberSetting.travel = updatedTravel
                return .none

            case .memberSetting(.updated(let updatedTravel)):
                return .none

            case .manage(.dismissRequested):
                state.shouldDismiss = true
                return .send(.dismiss)

            case .basicInfo, .memberSetting, .manage:
                return .none

            case .dismiss:
                state.shouldDismiss = true
                return .none
            }
        }
        Scope(state: \.basicInfo, action: \.basicInfo) {
            BasicSettingFeature()
        }
        Scope(state: \.memberSetting, action: \.memberSetting) {
            MemberSettingFeature()
        }
        Scope(state: \.manage, action: \.manage) {
            TravelManageFeature()
        }
    }
}
