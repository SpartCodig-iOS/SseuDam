//
//  ProfileCoordinatorView.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 12/1/25.
//

import SwiftUI

import ComposableArchitecture
import TCACoordinators

public struct ProfileCoordinatorView: View {
  let store: StoreOf<ProfileCoordinator>

  public init(store: StoreOf<ProfileCoordinator>) {
    self.store = store
  }

  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
      switch screen.case {
        case .profile(let profileStore):
          ProfileView(store: profileStore)
            .navigationBarBackButtonHidden(true)
      }
    }
  }
}
