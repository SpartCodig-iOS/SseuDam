//
//  MemberManageFeature.swift
//  MemberFeature
//
//  Created by 김민희 on 12/9/25.
//

import Domain
import ComposableArchitecture

@Reducer
public struct MemberManageFeature {
    public init() {}

    @ObservableState
    public struct State {
        var members: [TravelMember]

        public init(members: [TravelMember]) {
            self.members = members
        }
    }

    public enum Action {

    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            }
        }
    }
}

