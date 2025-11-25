//
//  TermsAgreementFeature.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/24/25.
//


import Foundation
import ComposableArchitecture


@Reducer
public struct TermsAgreementFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var allAgreed: Bool = false
        var privacyAgreed: Bool = false
        var serviceAgreed: Bool = false
        public init() {}
    }

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        case scope(ScopeAction)
        case navigation(NavigationAction)

    }

    //MARK: - ViewAction
    @CasePathable
    public enum View {
        case didTapAll
        case didTapPrivacy
        case didTapService

    }

    //MARK: - AsyncAction 비동기 처리 액션
    @CasePathable
    public enum ScopeAction: Equatable {
        case closeModel
    }

    @CasePathable
    public enum NavigationAction: Equatable {
        case presentServiceWeb
        case presentPrivacyWeb
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding(_):
                    return .none

                case .view(let viewAction):
                    return handleViewAction(state: &state, action: viewAction)

                case .scope(let scopeAction):
                    return handleScopeAction(state: &state, action: scopeAction)

                case .navigation(let navigationAction):
                    return handleNavigationAction(state: &state, action: navigationAction)
            }
        }
    }
}

extension TermsAgreementFeature {
    private func handleViewAction(
        state: inout State,
        action: View
    ) -> Effect<Action> {
        switch action {
            case .didTapAll:
                toggleAll(state: &state)
                return .none

            case .didTapPrivacy:
                state.privacyAgreed.toggle()
                syncAllState(state: &state)
                return .none

            case .didTapService:
                state.serviceAgreed.toggle()
                syncAllState(state: &state)
                return .none
        }
    }

    private func handleScopeAction(
        state: inout State,
        action: ScopeAction
    ) -> Effect<Action> {
        switch action {
            case .closeModel:
                return .none
        }
    }

    private func handleNavigationAction(
        state: inout State,
        action: NavigationAction
    )  -> Effect<Action> {
        switch action {
            case .presentPrivacyWeb:
                return .none
            case .presentServiceWeb:
                return .none
        }
    }
}


extension TermsAgreementFeature {
    /// 약관 전체 동의 토글
    private func toggleAll(state: inout State) {
        let newValue = !state.allAgreed
        state.allAgreed = newValue
        state.privacyAgreed = newValue
        state.serviceAgreed = newValue
    }

    /// 개별 선택 시 전체동의 상태 동기화
    private func syncAllState(state: inout State) {
        state.allAgreed = state.privacyAgreed && state.serviceAgreed
    }
}

