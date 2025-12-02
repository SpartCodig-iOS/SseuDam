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
        ZStack {
            if store.isLoadingProfile {
                ProfileSkeletonView()
            } else {
                VStack {

                    navigationHeader()

                    profileHeader()

                    termsSection()

                  accountSection()

                  Spacer()

                }
                .navigationBarBackButtonHidden(true)
                .photosPicker(
                    isPresented: $store.isPhotoPickerPresented,
                    selection: $store.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                )

            }
        }
        .onAppear {
            store.send(.view(.onAppear))
        }
        .background(.primary50)
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
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    fileprivate func profileHeader() -> some View {
        VStack {
            Spacer()
                .frame(height: 20)

            EditProfileImage(
              imageURL: store.profile?.profileImage
            ) {
                store.send(.view(.photoPickerButtonTapped))
            }
            .buttonStyle(.plain)

            Spacer()
                .frame(height: 16)

            Text(store.profile?.name ?? "")
                .font(.app(.title3, weight: .semibold))
                .foregroundStyle(.appBlack)

            Spacer()
                .frame(height: 5)

            Text(store.profile?.email ?? "")
                .font(.app(.body, weight: .medium))
                .foregroundStyle(.gray6)

            Spacer()
                .frame(height: 20)

            Divider()
                .frame(height: 1)
                .background(.gray2)

        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    fileprivate func termsSection() -> some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 16)

            HStack {

                Text("이용약관")
                    .font(.app(.title3, weight: .semibold))
                    .foregroundStyle(.appBlack)

                Spacer()
            }

            Spacer()
                .frame(height: 10)

            VStack {
                SettingRow(
                    image: .lock,
                    title: "개인정보 처리 방침",
                    showArrow: true,
                    action: {},
                    tapTermAction: {}
                )

                Divider()
                    .background(.gray1)
                    .frame(height: 1)

                SettingRow(
                    image: .list,
                    title: "서비스 이용",
                    showArrow: true,
                    action: {},
                    tapTermAction: {}
                )

            }
            .padding(.horizontal, 16)
            .background(.white)
            .cornerRadius(8)
            .shadow(color: .shadow ,radius: 5, x: 2, y: 2)
        }
        .padding(.horizontal, 16)
    }

  @ViewBuilder
  fileprivate func accountSection() -> some View {
      VStack(alignment: .leading) {
          Spacer()
              .frame(height: 20)

          HStack {

              Text("계정관리")
                  .font(.app(.title3, weight: .semibold))
                  .foregroundStyle(.appBlack)

              Spacer()
          }

          Spacer()
              .frame(height: 10)

          VStack {
              SettingRow(
                  image: .signOut,
                  title: "로그아웃",
                  showArrow: false,
                  action: {
                    store.send(.async(.logout))
                  },
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
      .padding(.horizontal, 16)
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
