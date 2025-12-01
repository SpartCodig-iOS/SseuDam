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
    @ObservableState
    public struct State: Equatable {
        let travelId: String
        let isOwner: Bool   
        var isSubmitting = false
        var errorMessage: String?
    }

    public enum Action {
        case leaveTapped
        case leaveResponse(Result<Void, Error>)
        case deleteTapped
        case deleteResponse(Result<Void, Error>)

        case dismissRequested
    }

    @Dependency(\.leaveTravelUseCase) var leaveTravelUseCase
    @Dependency(\.deleteTravelUseCase) var deleteTravelUseCase

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .leaveTapped:
                state.isSubmitting = true
                return .run {
                    [leaveTravelUseCase,
                     id = state.travelId] send in
                    do {
                        try await leaveTravelUseCase.execute(travelId: id)
                        await send(.leaveResponse(.success(())))
                    } catch {
                        await send(.leaveResponse(.failure(error)))
                    }
                }

            case .leaveResponse(.success):
                state.isSubmitting = false
                return .send(.dismissRequested)

            case .leaveResponse(.failure(let err)):
                state.isSubmitting = false
                state.errorMessage = err.localizedDescription
                return .none

            case .deleteTapped:
                state.isSubmitting = true
                return .run {
                    [deleteTravelUseCase,
                     id = state.travelId] send in
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
                state.errorMessage = err.localizedDescription
                return .none

            case .dismissRequested:
                return .none
            }
        }
    }
}
