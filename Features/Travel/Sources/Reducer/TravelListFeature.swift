//
//  TravelListFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 11/25/25.
//

import Domain
import ComposableArchitecture
import DesignSystem

@Reducer
public struct TravelListFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable, Hashable {
        var travels: [Travel] = []
        var selectedTab: TravelTab = .ongoing
        var cachedTravelsByTab: [TravelTab: [Travel]] = [:]
        
        var isMenuOpen = false
        
        var page = 1
        var hasNext = true
        
        var isLoading = false
        var isLoadingNextPage = false
        var uiError: String?

        var isPresentInvitationView: Bool = false
        var inviteCode: String = ""

        var hasCacheForSelectedTab: Bool {
            cachedTravelsByTab[selectedTab] != nil
        }

        var shouldShowSkeleton: Bool {
            isLoading && !hasCacheForSelectedTab && travels.isEmpty
        }

        @Presents var create: TravelCreateFeature.State?

        public init(pendingInviteCode: String? = nil) {
            if let code = pendingInviteCode {
                self.inviteCode = code
                self.isPresentInvitationView = true
            }
        }
    }
    
    public enum Action {
        case onAppear
        case refresh
        case fetch
        case fetchNextPageIfNeeded(currentItemID: String?)
        case cachedTravelsUpdated(tab: TravelTab, travels: [Travel])
        
        case fetchTravelsResponse(tab: TravelTab, page: Int, Result<[Travel], Error>)
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
    @Dependency(\.loadTravelCacheUseCase) var loadTravelCacheUseCase
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.refresh)

            case .cachedTravelsUpdated(let tab, let travels):
                state.cachedTravelsByTab[tab] = travels
                if state.selectedTab == tab {
                    state.travels = travels
                    state.isLoading = false
                }
                return .none
                
            case .travelTabSelected(let newTab):
                guard state.selectedTab != newTab else { return .none }
                state.selectedTab = newTab
                state.page = 1
                state.hasNext = true
                state.isLoadingNextPage = false
                let cached = state.cachedTravelsByTab[newTab]
                state.travels = cached ?? []
                state.isLoading = (cached == nil)
                return .send(.refresh)
                
            case .refresh:
                state.page = 1
                state.hasNext = true
                state.isLoadingNextPage = false
                if state.travels.isEmpty {
                    state.isLoading = true
                }
                return .send(.fetch)
                
            case .fetch:
                guard state.hasNext else { return .none }
                let currentTab = state.selectedTab
                let currentPage = state.page
                state.uiError = nil
                if currentPage == 1 {
                    state.isLoading = true
                } else {
                    state.isLoadingNextPage = true
                }
                
                let input = FetchTravelsInput(
                    page: currentPage,
                    status: currentTab.status
                )
                
                let loadCacheUseCase = loadTravelCacheUseCase
                return .run { [currentTab, currentPage, loadCacheUseCase] send in
                    if currentPage == 1,
                       let cached = try? await loadCacheUseCase.execute(status: currentTab.status),
                       !cached.isEmpty {
                        await send(.cachedTravelsUpdated(tab: currentTab, travels: cached))
                    }
                    do {
                        let result = try await fetchTravelsUseCase.execute(input: input)
                        await send(.fetchTravelsResponse(tab: currentTab, page: currentPage, .success(result)))
                    } catch {
                        await send(.fetchTravelsResponse(tab: currentTab, page: currentPage, .failure(error)))
                    }
                }
                
            case .fetchNextPageIfNeeded(let id):
                guard !state.isLoadingNextPage,
                      state.hasNext,
                      let last = state.travels.last, last.id == id
                else { return .none }
                
                state.page += 1
                return .send(.fetch)
                
            case .fetchTravelsResponse(let tab, let page, .success(let items)):
                if tab == state.selectedTab {
                    state.isLoading = false
                    state.isLoadingNextPage = false
                }
                
                if items.isEmpty {
                    if tab == state.selectedTab {
                        state.hasNext = false
                        if page == 1 {
                            state.travels = []
                        }
                    }
                    if page == 1 {
                        state.cachedTravelsByTab[tab] = []
                    }
                    return .none
                }
                
                var existing = page == 1 ? [] : state.cachedTravelsByTab[tab] ?? []
                existing.append(contentsOf: items)
                let deduped = deduplicate(existing)
                state.cachedTravelsByTab[tab] = deduped
                
                if tab == state.selectedTab {
                    state.travels = deduped
                }
                return .none
                
            case .fetchTravelsResponse(let tab, _, .failure(let error)):
                if tab == state.selectedTab {
                    state.isLoading = false
                    state.isLoadingNextPage = false
                    state.uiError = error.localizedDescription
                }
                return .none
                
            case .travelSelected:
                return .none

            case .openInviteCode(let code):
                state.inviteCode = code
                state.isPresentInvitationView = true
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
                state.isPresentInvitationView = true
                return .none
                
            case .inviteModalDismiss:
                state.isPresentInvitationView = false
                state.inviteCode = ""
                return .none
                
            case .inviteCodeChanged(let code):
                state.inviteCode = code
                return .none
                
            case .inviteConfirm:
                let code = state.inviteCode

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
                state.isPresentInvitationView = false

                // 가입한 여행을 즉시 목록에 반영해 사용자 체감 속도 개선
                if !state.travels.contains(where: { $0.id == travel.id }) {
                    state.travels.insert(travel, at: 0)
                }

                // 서버 최신화는 별도로 다시 가져온다
                state.page = 1
                state.hasNext = true
                state.isLoading = true
                return .send(.fetch)

            case .joinTravelResponse(.failure):
                state.inviteCode = ""
                return .run { _ in
                    await MainActor.run {
                        ToastManager.shared.showError("잘못된 초대 코드예요. 다시 확인해주세요.")
                    }
                }


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

// 서버에서 동일 데이터를 여러 번 수신하더라도 한 번만 노출되도록 ID 기준으로 정리
private func deduplicate(_ travels: [Travel]) -> [Travel] {
    var seen = Set<String>()
    return travels.filter { travel in
        guard !seen.contains(travel.id) else { return false }
        seen.insert(travel.id)
        return true
    }
}
