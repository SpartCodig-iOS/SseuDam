//
//  TravelListFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 11/25/25.
//

import Domain
import ComposableArchitecture

@Reducer
public struct TravelListFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable {
        var travels: [Travel] = []
        var selectedTab: TravelTab = .ongoing

        var page = 1
        var hasNext = true

        var isLoading = false
        var isLoadingNextPage = false
        var uiError: String?

        @Presents var create: TravelCreateFeature.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case refresh
        case fetch
        case fetchNextPageIfNeeded(currentItemID: String?)

        case fetchResponse(Result<[Travel], Error>)

        case tabChanged(TravelTab)

        case createButtonTapped
        case create(PresentationAction<TravelCreateFeature.Action>)
    }

    @Dependency(\.fetchTravelsUseCase) var fetchTravelsUseCase: FetchTravelsUseCaseProtocol

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                if state.travels.isEmpty {
                    return .send(.refresh)
                }
                return .none

            case .tabChanged(let newTab):
                state.selectedTab = newTab
                return .send(.refresh)

            case .refresh:
                state.page = 1
                state.hasNext = true
                state.travels = []
                return .send(.fetch)

            case .fetch:
                guard state.hasNext else { return .none }
                if state.page == 1 {
                    state.isLoading = true
                } else {
                    state.isLoadingNextPage = true
                }

                let input = FetchTravelsInput(limit: 20, page: state.page)

                return .run { send in
                    do { 
                        let result = try await fetchTravelsUseCase.excute(input: input)
                        await send(.fetchResponse(.success(result)))
                    } catch {
                        await send(.fetchResponse(.failure(error)))
                    }
                }

            case .fetchNextPageIfNeeded(let id):
                guard !state.isLoadingNextPage,
                      state.hasNext,
                      let last = state.travels.last, last.id == id
                else { return .none }

                state.page += 1
                return .send(.fetch)

            case .fetchResponse(.success(let items)):
                state.isLoading = false
                state.isLoadingNextPage = false

                if items.isEmpty {
                    state.hasNext = false
                    return .none
                }

                if state.page == 1 {
                    state.travels = items
                } else {
                    state.travels.append(contentsOf: items)
                }

                return .none

            case .fetchResponse(.failure(let error)):
                state.isLoading = false
                state.isLoadingNextPage = false
                state.uiError = error.localizedDescription
                return .none

            case .createButtonTapped:
                state.create = TravelCreateFeature.State()
                return .none

            case .create(.dismiss):
                state.create = nil
                return .send(.refresh)

            case .create:
                return .none
            }
        }
        .ifLet(\.$create, action: \.create) {
            TravelCreateFeature()
        }
    }
}
