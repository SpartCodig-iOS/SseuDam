//
//  MemberDemoApp.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import MemberFeature
import Domain
import ComposableArchitecture

@main
struct MemberDemoApp: App {
    let memberStore = Store(initialState: MemberManageFeature.State(
        travelId: "123",
        members: [
            TravelMember(
                id: "A123",
                name: "이영희",
                role: .member,
                email: "123@example.com"
            ),
            TravelMember(
                id: "B456",
                name: "김철수",
                role: .member,
                email: "456@example.com"
            )
        ],
        myInfo: TravelMember(
            id: "7896",
            name: "박철수",
            role: .owner,
            email: "789@example.com"
        )
    )){
        MemberManageFeature()
    }


    var body: some Scene {
        WindowGroup {
            NavigationView {
                MemberView(store: memberStore)
            }
        }
    }
}
