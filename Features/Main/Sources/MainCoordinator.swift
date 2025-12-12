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
//              state.routes.goBackTo(\.travelList)
            return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
              $0.goBackTo(\.travelList)
            }
            
            case let .routeAction(_, .travelSetting(.delegate(.openMemberManage(travelId)))):
                state.routes.push(.memberManage(.init(travelId: travelId)))
                return .none

            case let .routeAction(_, .travelSetting(.delegate(.navigateToTravelDetail(travelId)))):
                // 여행 수정 완료 후 해당 여행의 상세 페이지로 이동
                return .routeWithDelaysIfUnsupported(state.routes, action: \.router) {
                    $0.goBackTo(\.travelList)
                    $0.push(.settlementCoordinator(.init(travelId: travelId)))
                }

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
        guard let url = URL(string: urlString),
              url.scheme == "sseudam" else {
            #logDebug("❌ Invalid push deep link URL: \(urlString)")
            return .none
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }
        #logDebug("🔗 Path components: \(pathComponents)")

        // URL 구조: sseudam://travel/123/expense/456 또는 sseudam://invite?code=123
        if url.host == "invite" || pathComponents.first == "invite" {
            return handleInviteDeepLink(state: &state, url: url)
        } else if url.host == "travel" || pathComponents.first == "travel" {
            return handleTravelDeepLink(state: &state, url: url, pathComponents: pathComponents)
        } else {
            #logDebug("❌ Unknown deep link scheme. Host: \(url.host ?? "nil"), Path: \(pathComponents)")
            return .none
        }
    }

    private func handleTravelDeepLink(
        state: inout State,
        url: URL,
        pathComponents: [String]
    ) -> Effect<Action> {

        var travelId: String
        var remainingComponents: [String]

        // URL 구조 분석: sseudam://travel/123/expense/456 또는 sseudam://travel/{id}/...
        if pathComponents.first == "travel" && pathComponents.count >= 2 {
            // 표준 구조: ["travel", "123", "expense", "456"]
            travelId = pathComponents[1]
            remainingComponents = Array(pathComponents.dropFirst(2))
        } else if url.host == "travel" && pathComponents.count >= 1 {
            // 일부 푸시 페이로드는 host에만 travel이 있고 path는 ["{id}", "expense", "{expenseId}"] 형태
            travelId = pathComponents[0]
            remainingComponents = Array(pathComponents.dropFirst(1))
        } else {
            #logDebug("❌ Invalid travel deep link structure: \(pathComponents)")
            return .none
        }


        // settings 경로인 경우 바로 TravelSetting으로 이동
        if remainingComponents.count >= 1, remainingComponents[0] == "settings" {
            #logDebug("⚙️ Navigating to travel settings")
            // 기존 여행 관련 화면들 정리
            if let settlementIndex = state.routes.lastIndex(where: {
                if case .settlementCoordinator = $0.screen { return true }
                return false
            }) {
                state.routes.removeSubrange(settlementIndex...)
            }
            if let travelSettingIndex = state.routes.lastIndex(where: {
                if case .travelSetting = $0.screen { return true }
                return false
            }) {
                state.routes.removeSubrange(travelSettingIndex...)
            }
            // 여행 설정 페이지로 직접 이동
            state.routes.push(.travelSetting(.init(travelId: travelId)))
            return .none
        }

        // 일반적인 여행 상세 페이지 처리
        let currentTravelId = getCurrentTravelId(from: state)
        if currentTravelId != travelId {
            // 다른 여행이거나 여행 화면이 없으면 새로 열기
            if let settlementIndex = state.routes.lastIndex(where: {
                if case .settlementCoordinator = $0.screen { return true }
                return false
            }) {
                // 기존 여행 화면 제거하고 새로운 여행 화면 추가
                state.routes.removeSubrange(settlementIndex...)
            }
            state.routes.push(.settlementCoordinator(.init(travelId: travelId)))
        }

        // 추가 네비게이션 처리
        if remainingComponents.count >= 2, remainingComponents[0] == "expense" {
            let expenseId = remainingComponents[1]
            #logDebug("💰 Navigating to expense detail: \(expenseId)")

            // 지출 목록 탭으로 이동하고 특정 지출을 찾아서 표시
            let routeIndex = state.routes.count - 1
            return .send(.router(.routeAction(id: routeIndex, action: .settlementCoordinator(.navigateToExpenseTab(expenseId)))))

        } else if remainingComponents.count >= 1, remainingComponents[0] == "settlement" {
            #logDebug("📊 Navigating to settlement tab")
            // 정산 탭으로 이동
            let routeIndex = state.routes.count - 1
            return .send(.router(.routeAction(id: routeIndex, action: .settlementCoordinator(.navigateToSettlementTab))))
        }

        #logDebug("🏝️ Navigating to travel detail only")
        return .none
    }

    private func handleInviteDeepLink(
        state: inout State,
        url: URL
    ) -> Effect<Action> {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let inviteCode = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("❌ Invalid invite deep link: missing code")
            return .none
        }

        #logDebug("🎫 Processing invite code: \(inviteCode)")

        // 초대 코드 처리를 위해 TravelListFeature로 전달
        return .send(.router(.routeAction(id: 0, action: .travelList(.openInviteCode(inviteCode)))))
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
