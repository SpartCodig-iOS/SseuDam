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

        public init(pendingInviteCode: String? = nil) {
            if let code = pendingInviteCode {
                self.inviteCode = code
                self.isInviteModalPresented = true
            }
        }
    }

    public enum Action {
        case onAppear
        case refresh
        case fetch
        case fetchNextPageIfNeeded(currentItemID: String?)

        case fetchTravelsResponse(Result<[Travel], Error>)

        case travelTabSelected(TravelTab)

        case travelSelected(travelId: String)
        case openInviteCode(String)

        case floatingButtonTapped
        case selectCreateTravel
        case selectInviteCode

        case inviteModalDismiss
        case inviteCodeChanged(String)
        case inviteConfirm

        case joinTravelResponse(Result<Travel, Error>)

        case create(PresentationAction<TravelCreateFeature.Action>)

        case profileButtonTapped
    }

    @Dependency(\.fetchTravelsUseCase) var fetchTravelsUseCase
    @Dependency(\.joinTravelUseCase) var joinTravelUseCase

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.refresh)

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

                // 동일 여행이 중복 노출되지 않도록 ID 기준으로 정리
                var seen = Set<String>()
                state.travels = state.travels.filter { travel in
                    guard !seen.contains(travel.id) else { return false }
                    seen.insert(travel.id)
                    return true
                }

                return .none

            case .fetchTravelsResponse(.failure(let error)):
                state.isLoading = false
                state.isLoadingNextPage = false
                state.uiError = error.localizedDescription
                return .none

            case .travelSelected:
                return .none

            case .openInviteCode(let code):
                state.inviteCode = code
                state.isInviteModalPresented = true
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

                // 가입한 여행을 즉시 목록에 반영해 사용자 체감 속도 개선
                if !state.travels.contains(where: { $0.id == travel.id }) {
                    state.travels.insert(travel, at: 0)
                }

                // 서버 최신화는 별도로 다시 가져온다
                state.page = 1
                state.hasNext = true
                state.isLoading = true
                return .send(.fetch)

            case .joinTravelResponse(.failure(let error)):
                state.inviteCode = ""
                // TODO: 에러 Alert or Toast
                return .none


            case .create(.dismiss):
                state.create = nil
                return .send(.refresh)

            case .create:
                return .none

                case .profileButtonTapped:
                    return .none
            }
        }
        .ifLet(\.$create, action: \.create) {
            TravelCreateFeature()
        }
    }
}
