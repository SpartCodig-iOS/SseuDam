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
    public struct State: Equatable, Hashable {
        var travels: [Travel] = []
        var selectedTab: TravelTab = .ongoing

        var isMenuOpen = false

        var page = 1
        var hasNext = true

        var isLoading = false
        var isLoadingNextPage = false
        var uiError: String?

        var isInviteModalPresented: Bool = false
        var inviteCode: String = ""

        @Presents var create: TravelCreateFeature.State?
//        @Presents var profile: ProfileCoordinator.State?

        public init() {}
    }

    public enum Action {
        case onAppear
        case refresh
        case fetch
        case fetchNextPageIfNeeded(currentItemID: String?)

        case fetchTravelsResponse(Result<[Travel], Error>)

        case travelTabSelected(TravelTab)

        case travelSelected(travelId: String)

        case floatingButtonTapped
        case selectCreateTravel
        case selectInviteCode

        case inviteModalDismiss
        case inviteCodeChanged(String)
        case inviteConfirm

        case joinTravelResponse(Result<Travel, Error>)

        case create(PresentationAction<TravelCreateFeature.Action>)

//        case profileButtonTapped
//        case profile(PresentationAction<ProfileCoordinator.Action>)
//        case presentToLogin
    }

    @Dependency(\.fetchTravelsUseCase) var fetchTravelsUseCase
    @Dependency(\.joinTravelUseCase) var joinTravelUseCase

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                case .onAppear:
                    if state.travels.isEmpty {
                        return .send(.refresh)
                    }
                    return .none

                case .travelTabSelected(let newTab):
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

                let input = FetchTravelsInput(
                    page: state.page,
                    status: state.selectedTab.status
                )

                    return .run { send in
                        do {
                            let result = try await fetchTravelsUseCase.excute(input: input)
                            await send(.fetchTravelsResponse(.success(result)))
                        } catch {
                            await send(.fetchTravelsResponse(.failure(error)))
                        }
                    }

                case .fetchNextPageIfNeeded(let id):
                    guard !state.isLoadingNextPage,
                          state.hasNext,
                          let last = state.travels.last, last.id == id
                    else { return .none }

                    state.page += 1
                    return .send(.fetch)

                case .fetchTravelsResponse(.success(let items)):
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

                case .fetchTravelsResponse(.failure(let error)):
                    state.isLoading = false
                    state.isLoadingNextPage = false
                    state.uiError = error.localizedDescription
                    return .none

                case .travelSelected:
                    return .none

                case .floatingButtonTapped:
                    state.isMenuOpen.toggle()
                    return .none

                case .selectCreateTravel:
                    state.isMenuOpen = false
                    state.create = TravelCreateFeature.State()
                    return .none

                case .selectInviteCode:
                    state.isMenuOpen = false
                    state.isInviteModalPresented = true
                    return .none

                case .inviteModalDismiss:
                    state.isInviteModalPresented = false
                    state.inviteCode = ""
                    return .none

                case .inviteCodeChanged(let code):
                    state.inviteCode = code
                    return .none

                case .inviteConfirm:
                    let code = state.inviteCode
                    state.isInviteModalPresented = false

                    return .run { send in
                        do {
                            let travel = try await joinTravelUseCase.execute(inviteCode: code)
                            await send(.joinTravelResponse(.success(travel)))
                        } catch {
                            await send(.joinTravelResponse(.failure(error)))
                        }
                    }

                case .joinTravelResponse(.success(let travel)):
                    state.inviteCode = ""
                    // TODO: TravelDetail 화면으로 이동
                    print(travel.id)
                    return .none

                case .joinTravelResponse(.failure(let error)):
                    state.inviteCode = ""
                    // TODO: 에러 Alert or Toast
                    return .none


                case .create(.dismiss):
                    state.create = nil
                    return .send(.refresh)

                case .create:
                    return .none

//                case .profileButtonTapped:
//                    state.profile = ProfileCoordinator.State()
//                    return .none
//
//                case .profile(.presented(.delegate(.backToTravel))):
//                    state.profile = nil
//                    return .send(.refresh)
//
//                case .profile(.presented(.delegate(.presentLogin))):
//                    return .send(.presentToLogin)
//
//                case .profile:
//                    return .none

//                case .presentToLogin:
//                    return .none
            }
        }
        .ifLet(\.$create, action: \.create) {
            TravelCreateFeature()
        }
//        .ifLet(\.$profile, action: \.profile) {
//            ProfileCoordinator()
//        }
    }
}
