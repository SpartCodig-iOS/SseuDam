//
//  AppView.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 11/19/25.
//

import SwiftUI

import ComposableArchitecture
import LoginFeature
import SplashFeature
import TravelFeature

struct AppView: View {
    var store: StoreOf<AppFeature>

    var body: some View {
        SwitchStore(store) { state in
            switch state {
              case .splash:
                if let store = store.scope(state: \.splash, action: \.scope.splash) {
                  SplashView(store: store)
                }

                case .login:
                    if let store = store.scope(state: \.login, action: \.scope.login) {
                      LoginCoordinatorView(store: store)
                    }



              case .travel:
                if let store  = store.scope(state: \.travel, action: \.scope.travel) {
                  TravelView(store: store)
                }
            }
        }
    }
}


