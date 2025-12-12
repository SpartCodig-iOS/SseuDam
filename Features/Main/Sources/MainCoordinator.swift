//
//  MainCoordinator.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import TCACoordinators
import ComposableArchitecture
import SettlementFeature
import LogMacro
import MemberFeature
import Domain

@Reducer
public struct MainCoordinator {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var routes: [Route<Screen.State>]

        public init(pendingInviteCode: String? = nil) {
            self.routes = [.root(.travelList(.init(pendingInviteCode: pendingInviteCode)), embedInNavigationView: true)]
        }
    }

    public enum Action {
        case router(IndexedRouterActionOf<Screen>)
        case delegate(DelegateAction)
        case refreshTravelList
        case handlePushDeepLink(String)
    }


    public enum DelegateAction {
        case presentLogin
    }

    @Dependency(\.deeplinkRouter) var deeplinkRouter

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                case .router(let routeAction):
                    return routerAction(state: &state, action: routeAction)

                case .delegate(let delegateAction):
                    return handleDelegateAction(state: &state, action: delegateAction)

                case .refreshTravelList:
                    return refreshTravelList(state: &state)

                case .handlePushDeepLink(let urlString):
                    return handlePushDeepLink(state: &state, urlString: urlString)

            }
        }
        .forEachRoute(\.routes, action: \.router)
    }
}


extension MainCoordinator {
    private func routerAction(
        state: inout State,
        action: IndexedRouterActionOf<Screen>
    ) -> Effect<Action> {
        switch action {
            case .routeAction(_, .travelList(.selectCreateTravel)):
                state.routes.push(.createTravel(.init()))
                return .none

            case .routeAction(_, .createTravel(.dismiss)):
                state.routes.pop()
                return .none

            case let .routeAction(_, .travelList(.travelSelected(travelId))):
                state.routes.push(.settlementCoordinator(.init(travelId: travelId)))
                return .none

            case .routeAction(id: _, action: .travelList(.profileButtonTapped)):
                state.routes.push(.profile(.init()))
                return .none

            case .routeAction(id: _, action: .profile(.delegate(.backToTravel))):
                state.routes.goBack()
                return .none

            case .routeAction(id: _, action: .profile(.delegate(.presentLogin))):
                return .send(.delegate(.presentLogin))

            case .routeAction(_, .settlementCoordinator(.delegate(.onTapTravelSettingsButton(let travelId)))):
                state.routes.push(.travelSetting(.init(travelId: travelId)))
                return .none

            case .routeAction(_, .travelSetting(.delegate(.done))):
            return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
              $0.goBackTo(\.travelList)
            }

            case let .routeAction(_, .travelSetting(.delegate(.openUpdateTravel(travel)))):
                state.routes.push(.updateTravel(.init(travel: travel)))
                return .none
            
            case let .routeAction(_, .travelSetting(.delegate(.openMemberManage(travelId)))):
                state.routes.push(.memberManage(.init(travelId: travelId)))
                return .none


//           case .routeAction(_, .travelSetting(.delegate(.navigateToTravelDetail(_)))):
//                 return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
//                     $0.goBackTo(\.travelList)
//                 }

//            case let .routeAction(_, .travelSetting(.delegate(.navigateToTravelDetail(travelId)))):
//                return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
//                    $0.goBackTo(\.travelList)
//                }


            case .routeAction(_, .memberManage(.delegate(.back))):
                state.routes.goBack()
                return .none

            case .routeAction(_, .memberManage(.delegate(.finish))):
                state.routes.goBack()
                if let travelSettingIndex = state.routes.lastIndex(where: {
                    if case .travelSetting = $0.screen { return true }
                    return false
                }) {
                    return .send(.router(.routeAction(
                        id: travelSettingIndex,
                        action: .travelSetting(.fetchDetail)
                    )))
                } else {
                    return .none
                }
            
            case .routeAction(_, .updateTravel(.updated)):
                state.routes.goBack()
                if let travelSettingIndex = state.routes.lastIndex(where: {
                    if case .travelSetting = $0.screen { return true }
                    return false
                }) {
                    return .send(.router(.routeAction(
                        id: travelSettingIndex,
                        action: .travelSetting(.fetchDetail)
                    )))
                } else {
                    return .none
                }

          case .routeAction(id: _, action: .settlementCoordinator(.delegate(.onTapBackButton))):
            state.routes.goBack()
            return .none

            default:
                return .none
        }
    }

    private func handleDelegateAction(
        state: inout State,
        action: DelegateAction
    ) -> Effect<Action> {
        switch action {
            case .presentLogin:
                return .none
        }
    }

    private func refreshTravelList(state: inout State) -> Effect<Action> {
        return .send(.router(.routeAction(id: 0, action: .travelList(.refresh))))
    }

    private func handlePushDeepLink(state: inout State, urlString: String) -> Effect<Action> {
        #logDebug("🔗 Processing deeplink: \(urlString)")

        let result = deeplinkRouter.parse(urlString)

        switch result {
        case .success(let destination):
            return routeToDestination(state: &state, destination: destination)
        case .requiresLogin(let destination):
            return handleRequiresLogin(state: &state, destination: destination)
        case .invalid(let url, let reason):
            #logDebug("❌ Invalid deeplink: \(url) - \(reason)")
            return .none
        }
    }

    // MARK: - DeepLink Routing

    private func routeToDestination(
        state: inout State,
        destination: DeeplinkDestination
    ) -> Effect<Action> {
        switch destination {
        case .travel(let travelDeeplink):
            return handleTravelDestination(state: &state, travelDeeplink: travelDeeplink)
        case .invite(let code):
            // 이미 로그인된 상태에서 초대 코드 처리
            return .send(.router(.routeAction(id: 0, action: .travelList(.openInviteCode(code)))))
        case .unknown(let url):
            #logDebug("🤷‍♂️ Unknown deeplink: \(url)")
            return .none
        }
    }

    private func handleRequiresLogin(
        state: inout State,
        destination: DeeplinkDestination
    ) -> Effect<Action> {
        // 초대 코드의 경우 AppFeature로 전달하여 로그인 상태 체크
        // TODO: 필요시 다른 destination들도 처리
        guard case .invite(_) = destination else {
            #logDebug("❌ Unhandled requiresLogin destination: \(destination)")
            return .none
        }

        // AppFeature의 기존 로직을 사용하기 위해 다시 전달
        return .send(.delegate(.presentLogin))
    }

    private func handleTravelDestination(
        state: inout State,
        travelDeeplink: TravelDeeplink
    ) -> Effect<Action> {
        switch travelDeeplink {
        case .detail(let travelId):
            return navigateToTravelDetail(state: &state, travelId: travelId)
        case .settings(let travelId):
            return navigateToTravelSettings(state: &state, travelId: travelId)
        case .expense(let travelId, let expenseId):
            return navigateToExpenseDetail(state: &state, travelId: travelId, expenseId: expenseId)
        case .settlement(let travelId):
            return navigateToSettlementTab(state: &state, travelId: travelId)
        }
    }

    private func navigateToTravelSettings(state: inout State, travelId: String) -> Effect<Action> {
        #logDebug("⚙️ Navigating to travel settings")
        clearTravelRelatedScreens(state: &state)
        state.routes.push(.travelSetting(.init(travelId: travelId)))
        return .none
    }

    private func navigateToTravelDetail(state: inout State, travelId: String) -> Effect<Action> {
        #logDebug("🏝️ Navigating to travel detail")
        _ = ensureSettlementCoordinatorRoute(state: &state, travelId: travelId)
        return .none
    }

    private func navigateToExpenseDetail(state: inout State, travelId: String, expenseId: String) -> Effect<Action> {
        #logDebug("💰 Navigating to expense detail: \(expenseId)")
        let routeIndex = ensureSettlementCoordinatorRoute(state: &state, travelId: travelId)
        return .send(.router(.routeAction(id: routeIndex, action: .settlementCoordinator(.navigateToExpenseTab(expenseId)))))
    }

    private func navigateToSettlementTab(state: inout State, travelId: String) -> Effect<Action> {
        #logDebug("📊 Navigating to settlement tab")
        let routeIndex = ensureSettlementCoordinatorRoute(state: &state, travelId: travelId)
        return .send(.router(.routeAction(id: routeIndex, action: .settlementCoordinator(.navigateToSettlementTab))))
    }

    private func clearTravelRelatedScreens(state: inout State) {
        clearSettlementScreens(state: &state)
        if let travelSettingIndex = state.routes.lastIndex(where: {
            if case .travelSetting = $0.screen { return true }
            return false
        }) {
            state.routes.removeSubrange(travelSettingIndex...)
        }
    }

    private func ensureSettlementCoordinatorRoute(state: inout State, travelId: String) -> Int {
        if let existingIndex = state.routes.lastIndex(where: {
            if case let .settlementCoordinator(settlementState) = $0.screen {
                return settlementState.travelId == travelId
            }
            return false
        }) {
            if existingIndex < state.routes.count - 1 {
                state.routes.removeSubrange((existingIndex + 1)...)
            }
            return existingIndex
        }

        clearSettlementScreens(state: &state)
        state.routes.push(.settlementCoordinator(.init(travelId: travelId)))
        return state.routes.count - 1
    }

    private func clearSettlementScreens(state: inout State) {
        if let settlementIndex = state.routes.lastIndex(where: {
            if case .settlementCoordinator = $0.screen { return true }
            return false
        }) {
            state.routes.removeSubrange(settlementIndex...)
        }
    }


    private func getCurrentTravelId(from state: State) -> String? {
        // 현재 열려있는 SettlementCoordinator에서 travelId 추출
        for route in state.routes.reversed() {
            if case .settlementCoordinator(let settlementState) = route.screen {
                return settlementState.travelId
            }
        }
        return nil
    }
}
