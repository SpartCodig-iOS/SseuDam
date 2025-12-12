//
//  MemberManageFeature.swift
//  MemberFeature
//
//  Created by 김민희 on 12/9/25.
//

import Domain
import DesignSystem
import ComposableArchitecture

@Reducer
public struct MemberManageFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var members: [TravelMember] = []
        var myInfo: TravelMember? = nil
        var alert: DSAlertState<AlertAction>?

        var travelId: String

        public init(
            travelId: String,
            members: [TravelMember] = [],
            myInfo: TravelMember? = nil
        ) {
            self.travelId = travelId
            self.members = members
            self.myInfo = myInfo
        }
    }

    public enum Action {
        case onAppear

        case fetchMemberResponse(Result<MyTravelMember, Error>)

        case deleteButtonTapped(TravelMember)
        case deleteMemberTapped(TravelMember)
        case deleteMemberResponse(Result<String, Error>)

        case delegateOwnerButtonTapped(TravelMember)
        case delegateOwnerTapped(TravelMember)
        case delegateOwnerResponse(Result<Travel, Error>)

        case alert(AlertAction)

        case backButtonTapped

        case delegate(Delegate)
    }

    public enum Delegate: Equatable {
        case back
        case finish
    }

    public enum AlertAction: Equatable {
        case confirmDelegate(TravelMember)
        case confirmDelete(TravelMember)
        case cancel
        case dismiss
    }

    @Dependency(\.fetchMemberUseCase) var fetchMemberUseCase
    @Dependency(\.deleteTravelMemberUseCase) var deleteTravelMemberUseCase
    @Dependency(\.delegateOwnerUseCase) var delegateOwnerUseCase
//    @Dependency(\.analyticsUseCase) var analyticsUseCase

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            // MARK: 화면 진입 시 멤버 목록 불러오기
            case .onAppear:
                return .run { [travelId = state.travelId] send in
                    do {
                        let result = try await fetchMemberUseCase.execute(travelId: travelId)
                        await send(.fetchMemberResponse(.success(result)))
                    } catch {
                        await send(.fetchMemberResponse(.failure(error)))
                    }
                }

            case let .fetchMemberResponse(.success(response)):
                state.myInfo = response.myInfo
                state.members = response.memberInfo
                return .none

            case .fetchMemberResponse(.failure):
                state.alert = DSAlertState(
                    title: "멤버 정보를 불러오지 못했어요.",
                    message: "잠시 후 다시 시도해주세요.",
                    primary: .init(
                        title: "확인",
                        action: .dismiss
                    )
                )
                return .none

            case let .deleteButtonTapped(member):
                state.alert = DSAlertState(
                    title: "\(member.name)님을 삭제하시겠습니까?",
                    message: "해당 멤버는 그룹에 더 이상 접근할 수 없습니다.",
                    primary: .init(
                        title: "삭제하기",
                        role: .destructive,
                        action: .confirmDelete(member)
                    ),
                    secondary: .init(
                        title: "취소",
                        role: .cancel,
                        action: .cancel
                    )
                )
                return .none

            // MARK: 멤버 삭제 버튼
            case let .deleteMemberTapped(member):
                return .run { [travelId = state.travelId] send in
                    do {
                        try await deleteTravelMemberUseCase.execute(
                            travelId: travelId,
                            memberId: member.id
                        )
                        await send(.deleteMemberResponse(.success(member.id)))
                    } catch {
                        await send(.deleteMemberResponse(.failure(error)))
                    }
                }

            case let .deleteMemberResponse(.success(memberId)):
                state.members.removeAll { $0.id == memberId }
//                analyticsUseCase.track(.travel(.memberLeave, TravelEventData(travelId: state.travelId, memberId: memberId)))
                return .none

            case .deleteMemberResponse(.failure):
                return .none

            case let .delegateOwnerButtonTapped(member):
                state.alert = DSAlertState(
                    title: "\(member.name)님으로 관리자를 변경할까요?",
                    message: "기존 관리자는 자동으로 권한이 해제됩니다.",
                    primary: .init(
                        title: "변경하기",
                        action: .confirmDelegate(member)
                    ),
                    secondary: .init(
                        title: "취소",
                        role: .cancel,
                        action: .cancel
                    )
                )
                return .none

            case let .alert(.confirmDelegate(member)):
                state.alert = nil
                return .send(.delegateOwnerTapped(member))

            case let .alert(.confirmDelete(member)):
                state.alert = nil
                return .send(.deleteMemberTapped(member))

            case .alert(.cancel), .alert(.dismiss):
                state.alert = nil
                return .none

            // MARK: 관리자 위임 버튼
            case let .delegateOwnerTapped(member):
                return .run { [travelId = state.travelId] send in
                    do {
                        let travel = try await delegateOwnerUseCase.execute(
                            travelId: travelId,
                            newOwnerId: member.id
                        )
                        await send(.delegateOwnerResponse(.success(travel)))
                    } catch {
                        await send(.delegateOwnerResponse(.failure(error)))
                    }
                }

            case let .delegateOwnerResponse(.success(travel)):
                // 서버에서 내려준 최신 멤버 정보로 상태 업데이트
                if let myId = state.myInfo?.id,
                   let updatedMyInfo = travel.members.first(where: { $0.id == myId }) {
                    state.myInfo = updatedMyInfo
                }
                let excludedId = state.myInfo?.id
                state.members = travel.members.filter { $0.id != excludedId }

                // 새 관리자 ID 찾기
                if let newOwnerId = travel.members.first(where: { $0.role == .owner })?.id {
//                    analyticsUseCase.track(.travel(.ownerDelegate, TravelEventData(travelId: state.travelId, newOwnerId: newOwnerId)))
                }

                return .send(.delegate(.finish))

            case .delegateOwnerResponse(.failure):
                return .none

            case .backButtonTapped:
                return .send(.delegate(.back))

            case .delegate:
                return .none
            }
        }
    }
}
