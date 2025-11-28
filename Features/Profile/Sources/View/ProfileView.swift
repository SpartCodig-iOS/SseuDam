//
//  ProfileView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

public struct ProfileView: View {
  @Bindable var store: StoreOf<ProfileFeature>
  public init(store: StoreOf<ProfileFeature>) {
    self.store = store
  }

    public var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Profile Feature")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    NavigationView {
      ProfileView(
        store: .init(
          initialState: ProfileFeature.State(),
          reducer: {
            ProfileFeature()
          })
      )
    }
}
