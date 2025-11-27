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
        var privacyAgreed: Bool = false
        var serviceAgreed: Bool = false
        var allAgreed: Bool {
            get { privacyAgreed && serviceAgreed }
            set {
                privacyAgreed = newValue
                serviceAgreed = newValue
            }
        }
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
        case allAgreementTapped
        case privacyAgreementTapped
        case serviceAgreementTapped

    }

    @CasePathable
    public enum ScopeAction: Equatable {
        case close
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
            case .allAgreementTapped:
                toggleAll(state: &state)
                return .none

            case .privacyAgreementTapped:
                state.privacyAgreed.toggle()
                return .none

            case .serviceAgreementTapped:
                state.serviceAgreed.toggle()
                return .none
        }
    }

    private func handleScopeAction(
        state: inout State,
        action: ScopeAction
    ) -> Effect<Action> {
        switch action {
            case .close:
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
    private func toggleAll(state: inout State) {
        state.allAgreed.toggle()
    }
}
