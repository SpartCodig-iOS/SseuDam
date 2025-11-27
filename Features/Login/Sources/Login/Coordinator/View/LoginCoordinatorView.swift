//
//  LoginCoordinatorView.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/27/25.
//

import SwiftUI

import TCACoordinators
import ComposableArchitecture


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
        case .login:
          LoginView(store: self.store.scope(state: \.login, action: \.scope.login))
            .onAppear {
              store.send(.view(.onAppear))
            }
      }
    }
  }
}
