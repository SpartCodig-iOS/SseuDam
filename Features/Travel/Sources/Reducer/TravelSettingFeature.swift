//
//  TravelSettingFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import Domain
import DesignSystem
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
        var alert: DSAlertState<AlertAction>?

        public init(travelId: String) {
            self.travelId = travelId
        }
    }

    public enum Action {
        case onAppear

        case fetchDetail
        case cachedDetailLoaded(Travel)
        case fetchDetailResponse(Result<Travel, Error>)

        case basicInfo(BasicSettingFeature.Action)
        case memberSetting(MemberSettingFeature.Action)
        case manage(TravelManageFeature.Action)

        case clearError

        case dismiss

        case delegate(Delegate)
        case alert(AlertAction)

        public enum Delegate: Equatable {
            case done
            case openMemberManage(travelId: String)
            case openUpdateTravel(travel: Travel)
        }
    }

    public enum AlertAction: Equatable {
        case confirmLeave
        case confirmDelete
        case cancel
        case dismiss
    }

    @Dependency(\.fetchTravelDetailUseCase) var fetchTravelDetailUseCase
    @Dependency(\.loadTravelDetailCacheUseCase) var loadTravelDetailCacheUseCase

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

                // MARK: - Lifecycle

            case .onAppear:
                return .send(.fetchDetail)

            case .fetchDetail:
                state.isLoading = true
                return .run { [id = state.travelId] send in
                    if let cached = try? await loadTravelDetailCacheUseCase.execute(id: id) {
                        await send(.cachedDetailLoaded(cached))
                    }
                    do {
                        let travel = try await fetchTravelDetailUseCase.execute(id: id)
                        await send(.fetchDetailResponse(.success(travel)))
                    } catch {
                        await send(.fetchDetailResponse(.failure(error)))
                    }
                }

            case .cachedDetailLoaded(let travel):
                state.isLoading = false
                state.applyTravel(travel)
                return .none

            case .fetchDetailResponse(.success(let travel)):
                state.isLoading = false
                state.applyTravel(travel)
                return .none

            case .fetchDetailResponse(.failure(let err)):
                state.isLoading = false
                state.errorMessage = err.localizedDescription
                return .none

                // MARK: - Child features

            case .manage(.dismissRequested):
                // 여행 나가기 / 삭제 성공 시
                state.shouldDismiss = true
                // 코디네이터에게도 알려줌
                return .send(.delegate(.done))

            case .manage(.delegate(.errorOccurred(let message))):
                state.errorMessage = message
                return .none

            case .manage(.delegate(.showLeaveAlert)):
                state.alert = state.confirmLeaveAlert()
                return .none

            case .manage(.delegate(.showDeleteAlert)):
                state.alert = state.confirmDeleteAlert()
                return .none

            case .basicInfo(.delegate(.openUpdate(let travel))):
                return .send(.delegate(.openUpdateTravel(travel: travel)))

            case .basicInfo(.updated(let updatedTravel)):
                if var memberSetting = state.memberSetting {
                    memberSetting.applyUpdatedTravel(updatedTravel)
                    state.memberSetting = memberSetting
                }
                return .none

            case let .memberSetting(.delegate(.openMemberManage(travelId))):
                return .send(.delegate(.openMemberManage(travelId: travelId)))

            case .clearError:
                state.errorMessage = nil
                return .none

                // 직접 dismiss (뒤로가기 버튼 등)
            case .dismiss:
                state.shouldDismiss = true
                return .none

            case .alert(.confirmLeave):
                state.alert = nil
                return .send(.manage(.performLeave))

            case .alert(.confirmDelete):
                state.alert = nil
                return .send(.manage(.performDelete))

            case .alert(.cancel), .alert(.dismiss):
                state.alert = nil
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

private extension TravelSettingFeature.State {
    mutating func applyTravel(_ travel: Travel) {
        basicInfo = BasicSettingFeature.State(travel: travel)
        memberSetting = MemberSettingFeature.State(travel: travel)
        let ownerId = travel.members.first(where: { $0.role == .owner })?.id
        manage = TravelManageFeature.State(
            travelId: travel.id,
            isOwner: ownerId == travel.members.first?.id
        )
    }

    func confirmLeaveAlert() -> DSAlertState<TravelSettingFeature.AlertAction> {
        DSAlertState(
            title: "여행을 나가시겠어요?",
            message: "여행을 나가면 다시 초대받기 전까지 접근할 수 없어요.",
            primary: .init(
                title: "나가기",
                role: .destructive,
                action: .confirmLeave
            ),
            secondary: .init(
                title: "취소",
                role: .cancel,
                action: .cancel
            )
        )
    }

    func confirmDeleteAlert() -> DSAlertState<TravelSettingFeature.AlertAction> {
        DSAlertState(
            title: "여행을 삭제할까요?",
            message: "모든 여행 기록이 삭제되며 복구할 수 없어요.",
            primary: .init(
                title: "삭제하기",
                role: .destructive,
                action: .confirmDelete
            ),
            secondary: .init(
                title: "취소",
                role: .cancel,
                action: .cancel
            )
        )
    }
}
