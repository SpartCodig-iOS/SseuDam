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
    ScrollView {
      VStack(spacing: 24) {
        profileHeaderView()

        Text("Profile Feature")
          .font(.title)
          .fontWeight(.bold)
          .foregroundStyle(.primary700)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 32)
    }
    .padding(.horizontal, 24)
  }
}

extension ProfileView {
  fileprivate func profileHeaderView() -> some View {
    VStack {
      EditProfileImage() {
        store.send(.view(.editProfileImageTapped))
      }

      Spacer()
        .frame(height: 16)

      Text("테스터")
        .font(.app(.title3, weight: .semibold))
        .foregroundStyle(.appBlack)

      Spacer()
        .frame(height: 5)

      Text("test @test.com")
        .font(.app(.body, weight: .medium))
        .foregroundStyle(.gray6)


    }
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
