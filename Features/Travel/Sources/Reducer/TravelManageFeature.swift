//
//  TravelManageFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct TravelManageFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        let travelId: String
        let isOwner: Bool
        var isSubmitting = false

        public init(travelId: String, isOwner: Bool) {
            self.travelId = travelId
            self.isOwner = isOwner
        }
    }

    public enum Action {
        case leaveTapped
        case leaveResponse(Result<Void, Error>)

        case deleteTapped
        case deleteResponse(Result<Void, Error>)

        /// leave/delete 성공 시 상위에서 시트를 닫기 위한 액션
        case dismissRequested

        /// 상위로 에러/이벤트를 올리기 위한 delegate
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case errorOccurred(String)
        }
    }

    @Dependency(\.leaveTravelUseCase) var leaveTravelUseCase
    @Dependency(\.deleteTravelUseCase) var deleteTravelUseCase

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

                // MARK: - 여행 나가기

            case .leaveTapped:
                // 방장은 나가기 불가
                if state.isOwner {
                    return .send(.delegate(.errorOccurred(
                        "관리자는 여행 나가기가 불가능합니다.\n관리자 변경 후 다시 시도해주세요."
                    )))
                }

                state.isSubmitting = true

                return .run { [id = state.travelId] send in
                    do {
                        try await leaveTravelUseCase.execute(travelId: id)
                        await send(.leaveResponse(.success(())))
                    } catch {
                        await send(.leaveResponse(.failure(error)))
                    }
                }

            case .leaveResponse(.success):
                state.isSubmitting = false
                // 상위(Setting)에서 이걸 받아서 dismiss 로직 처리
                return .send(.dismissRequested)

            case .leaveResponse(.failure(let err)):
                state.isSubmitting = false
                return .send(.delegate(.errorOccurred(err.localizedDescription)))

                // MARK: - 여행 삭제

            case .deleteTapped:
                state.isSubmitting = true

                return .run { [id = state.travelId] send in
                    do {
                        try await deleteTravelUseCase.execute(id: id)
                        await send(.deleteResponse(.success(())))
                    } catch {
                        await send(.deleteResponse(.failure(error)))
                    }
                }

            case .deleteResponse(.success):
                state.isSubmitting = false
                return .send(.dismissRequested)

            case .deleteResponse(.failure(let err)):
                state.isSubmitting = false
                return .send(.delegate(.errorOccurred(err.localizedDescription)))

                // MARK: - 상위에서만 처리

            case .dismissRequested:
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
