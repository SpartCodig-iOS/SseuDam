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
        let travelId: String

        var basicInfo: BasicSettingFeature.State?
        var memberSetting: MemberSettingFeature.State?
        var manage: TravelManageFeature.State?

        var isLoading = false
        var shouldDismiss = false
        var errorMessage: String?

        public init(travelId: String) {
            self.travelId = travelId
        }
    }

    public enum Action {
        case onAppear

        case fetchDetail
        case fetchDetailResponse(Result<Travel, Error>)

        case basicInfo(BasicSettingFeature.Action)
        case memberSetting(MemberSettingFeature.Action)
        case manage(TravelManageFeature.Action)

        case clearError

        case dismiss

        case delegate(Delegate)

        public enum Delegate: Equatable {
            case done  
        }
    }

    @Dependency(\.fetchTravelDetailUseCase) var fetchTravelDetailUseCase

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

                // MARK: - Lifecycle

            case .onAppear:
                guard state.basicInfo == nil else { return .none }
                return .send(.fetchDetail)

            case .fetchDetail:
                state.isLoading = true
                return .run { [id = state.travelId] send in
                    do {
                        let travel = try await fetchTravelDetailUseCase.execute(id: id)
                        await send(.fetchDetailResponse(.success(travel)))
                    } catch {
                        await send(.fetchDetailResponse(.failure(error)))
                    }
                }

            case .fetchDetailResponse(.success(let travel)):
                state.isLoading = false

                state.basicInfo = BasicSettingFeature.State(travel: travel)
                state.memberSetting = MemberSettingFeature.State(travel: travel)
                state.manage = TravelManageFeature.State(
                    travelId: travel.id,
                    isOwner: travel.members.first(where: { $0.role == "owner" })?.id
                    == travel.members.first?.id
                )

                return .none

            case .fetchDetailResponse(.failure(let err)):
                state.isLoading = false
                state.errorMessage = err.localizedDescription
                return .none

                // MARK: - Child features

            case .basicInfo(.updated(let updatedTravel)):
                state.memberSetting?.travel = updatedTravel
                return .none

            case .manage(.dismissRequested):
                // 여행 나가기 / 삭제 성공 시
                state.shouldDismiss = true
                // 코디네이터에게도 알려줌
                return .send(.delegate(.done))

            case .manage(.delegate(.errorOccurred(let message))):
                state.errorMessage = message
                return .none

            case .memberSetting(.delegate(.needRefresh)):
                // 멤버 관련 변경 발생 → 서버에서 Travel 다시 가져오기
                return .send(.fetchDetail)

            case .clearError:
                state.errorMessage = nil
                return .none

                // 직접 dismiss (뒤로가기 버튼 등)
            case .dismiss:
                state.shouldDismiss = true
                return .none

            case .basicInfo, .memberSetting, .manage:
                return .none
            case .delegate:
                return .none
            }
        }
        .ifLet(\.basicInfo, action: \.basicInfo) {
            BasicSettingFeature()
        }
        .ifLet(\.memberSetting, action: \.memberSetting) {
            MemberSettingFeature()
        }
        .ifLet(\.manage, action: \.manage) {
            TravelManageFeature()
        }
    }
}
