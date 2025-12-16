//
//  LoginCoordinatorView.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/27/25.
//

import SwiftUI

import TCACoordinators
import ComposableArchitecture
import DesignSystem
import WebFeature
import OnBoardingFeature


public struct LoginCoordinatorView: View {
  @Bindable var store: StoreOf<LoginCoordinator>

  public init(
    store: StoreOf<LoginCoordinator>
  ) {
    self.store = store
  }

  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screens in
      switch screens.case {
        case .login(let loginStore):
          LoginView(store: loginStore)


        case .web(let webStore):
          WebView(store: webStore)
            .navigationBarBackButtonHidden(true)
            .enableSwipeBack()

        case .onBoarding(let onBoardingStore):
          OnBoardingView(store: onBoardingStore)
            .navigationBarBackButtonHidden(true)

      }
    }
  }
}
