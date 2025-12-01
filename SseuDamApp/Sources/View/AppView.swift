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
import ProfileFeature

struct AppView: View {
  var store: StoreOf<AppFeature>

  var body: some View {
    ZStack(alignment: .topLeading) {
      Color.primary50.ignoresSafeArea()
      
      switch store.state {
      case .splash:
        if let splashStore = store.scope(state: \.splash, action: \.scope.splash) {
          SplashView(store: splashStore)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }

      case .login:
        if let loginStore = store.scope(state: \.login, action: \.scope.login) {
          LoginCoordinatorView(store: loginStore)
            .transition(.asymmetric(
              insertion: .move(edge: .trailing),
              removal: .move(edge: .leading)
            ))
        }

      case .travel:
        if let travelStore = store.scope(state: \.travel, action: \.scope.travel) {
          TravelView(store: travelStore)
            .transition(.asymmetric(
              insertion: .move(edge: .trailing),
              removal: .move(edge: .leading)
            ))
        }

      case .profile:
        if let profileStore = store.scope(state: \.profile, action: \.scope.profile) {
          ProfileCoordinatorView(store: profileStore)
            .transition(.asymmetric(
              insertion: .move(edge: .trailing),
              removal: .move(edge: .leading)
            ))
        }
      }
    }
    .animation(
      .spring(response: 0.52, dampingFraction: 0.94, blendDuration: 0.14),
      value: store.caseKey
    )
  }
}
