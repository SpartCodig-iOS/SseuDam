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
import PhotosUI

public struct ProfileView: View {
  @Bindable var store: StoreOf<ProfileFeature>
  public init(store: StoreOf<ProfileFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack {
      

      navigationHeader()

      profileHeader()

      accountSettingsSection()

      Spacer()

      signOutButton()

      Spacer()
        .frame(height: 43)

    }
    .background(.primary50)
    .padding(.horizontal, 16)
    .photosPicker(
      isPresented: $store.isPhotoPickerPresented,
      selection: $store.selectedPhotoItem,
      matching: .images,
      photoLibrary: .shared()
    )
    .onChange(of: store.selectedPhotoItem) { newItem, oldValue in
      guard let newItem else { return }

      Task { @MainActor in
        if let data = try? await newItem.loadTransferable(type: Data.self) {
          store.send(.view(.profileImageSelected(data)))
        } else {
          store.send(.view(.profileImageSelected(nil)))
        }
      }
    }
  }
}

extension ProfileView {
  @ViewBuilder
  fileprivate func navigationHeader() -> some View {
    VStack {
      Spacer()
        .frame(height: 20)

      HStack {
        Image(assetName: "chevronLeft")
          .resizable()
          .scaledToFit()
          .frame(height: 24)
          .foregroundColor(.appBlack)

        Text("프로필")
          .font(.app(.title1, weight: .semibold))
          .foregroundStyle(.appBlack)

        Spacer()
      }
      .onTapGesture {
        store.send(.delegate(.backToTravel))
      }
    }
  }

  @ViewBuilder
  fileprivate func profileHeader() -> some View {
    VStack {
      Spacer()
        .frame(height: 20)

      EditProfileImage() {
        store.send(.view(.photoPickerButtonTapped))
      }
      .buttonStyle(.plain)

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

      Spacer()
        .frame(height: 20)

      Divider()
        .frame(height: 1)
        .background(.gray2)

    }
  }

  @ViewBuilder
  fileprivate func accountSettingsSection() -> some View {
    VStack(alignment: .leading) {
      Spacer()
        .frame(height: 8)

      HStack {

        Text("계정관리")
          .font(.app(.title3, weight: .medium))
          .foregroundStyle(.appBlack)

        Spacer()
      }

      Spacer()
        .frame(height: 19)

      VStack {
        SettingRow(
          image: .terms,
          title: "이용약관",
          showArrow: true,
          action: {},
          tapTermAction: {}
        )

        Divider()
          .background(.gray1)
          .frame(height: 1)

        SettingRow(
          image: .userDelete,
          title: "회원탈퇴",
          showArrow: false,
          action: {},
          tapTermAction: {}
        )

      }
      .padding(.horizontal, 16)
      .background(.white)
      .cornerRadius(8)
      .shadow(color: .shadow ,radius: 5, x: 2, y: 2)
    }
  }

  @ViewBuilder
  fileprivate func signOutButton() -> some View {
    HStack(alignment: .center) {
      Image(asset: .signOut)
        .resizable()
        .scaledToFit()
        .frame(width: 15, height: 15)

      Spacer()
        .frame(width: 8)

      Text("로그아웃")
        .font(.app(.body))
        .foregroundStyle(.error)
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
