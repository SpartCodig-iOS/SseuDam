import ComposableArchitecture
import Foundation

@Reducer
public struct OnBoardingFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var page: Page = .travel
        @Shared(.appStorage("isFirst")) var isFirst: Bool = true
        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case nextButtonTapped
        case delegate(DelegateAction)
    }

    public enum DelegateAction: Equatable {
        case presentMain
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
                case .binding:
                    return .none

                case .nextButtonTapped:
                    if let next = state.page.next {
                        state.page = next
                        return .none
                    } else {
                        state.$isFirst.withLock { $0 = false }
                        return .send(.delegate(.presentMain))
                    }

                case .delegate(let delegateAction):
                    return handleDelegateAction(state: &state, action: delegateAction)
            }
        }
    }
}

extension OnBoardingFeature {
    private func handleDelegateAction(
        state: inout State,
        action: DelegateAction
    ) -> Effect<Action> {
        switch action {
            case .presentMain:
                return .none
        }
    }
}


extension OnBoardingFeature.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(page)
    }
}
