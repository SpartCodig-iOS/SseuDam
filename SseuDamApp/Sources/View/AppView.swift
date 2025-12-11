//
//  AppView.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 11/19/25.
//

import SwiftUI
import ComposableArchitecture
import LoginFeature
import MainFeature
import SplashFeature
import TravelFeature
import ProfileFeature

struct AppView: View {
    var store: StoreOf<AppFeature>
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.primary50.ignoresSafeArea()
            
            switch store.state.flow {
            case .main:
                if let mainStore = store.scope(state: \.main, action: \.scope.main) {
                    MainCoordinatorView(store: mainStore)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }

            case .login:
                if let loginStore = store.scope(state: \.login, action: \.scope.login) {
                    LoginCoordinatorView(store: loginStore)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                }

            case .splash:
                if let splashStore = store.scope(state: \.splash, action: \.scope.splash) {
                    SplashView(store: splashStore)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
        }
        .animation(
            .spring(response: 0.52, dampingFraction: 0.94, blendDuration: 0.14),
            value: store.caseKey
        )
        .onAppear {
            store.send(.inner(.setupPushNotificationObserver))
            store.send(.inner(.checkPendingPushDeepLink))
        }
    }
}
