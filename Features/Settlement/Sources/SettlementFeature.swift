//
//  SettlementFeature.swift
//  SettlementFeature
//
//  Created by 홍석현 on 11/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
public struct SettlementFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case onAppear
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
