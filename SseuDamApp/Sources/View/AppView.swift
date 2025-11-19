//
//  AppView.swift
//  SseuDamApp
//
//  Created by Wonji Suh  on 11/19/25.
//

import SwiftUI

import ComposableArchitecture
import LoginFeature

struct AppView: View {
    var store: StoreOf<AppFeature>

    var body: some View {
        SwitchStore(store) { state in
            switch state {
                case .login:
                    if let store = store.scope(state: \.login, action: \.scope.login) {
                        LoginView(store: store)
                    }
            }
        }
    }
}


