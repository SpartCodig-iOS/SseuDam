//
//  LoginView.swift
//  TestApp
//
//  Created by TestDev on 09-11-25.
//  Copyright © 2025 TestDev. All rights reserved.
//

import SwiftUI

import AuthenticationServices

import DesignSystem
import ComposableArchitecture
import Domain

public struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>

    public init(
        store: StoreOf<LoginFeature>
    ) {
        self.store = store
    }

    public var body: some View {
        VStack {

            loginLogoText()

            Spacer()

            loginSocialButton()

            Spacer()
                .frame(height: 58)

        }
        .background(Color.primary50)
    }
}


extension LoginView {

    @ViewBuilder
    private func loginLogoText() -> some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 105)

            HStack {
                Text("쓰담")
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary500)

                Spacer()
            }

            Spacer()
                .frame(height: 34)

            VStack(spacing: 11) {
                HStack {
                    Text("쓰담에 오신것을 환영합니다")
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)

                    Spacer()
                }

                HStack(spacing: .zero) {
                    Text("쓰담")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary500)

                    Text("에서 공금 정산을 빠르고 쉽게 확인해보세요")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)

                    Spacer()

                }

            }

        }
        .padding(.horizontal, 20)
    }


    @ViewBuilder
    private func loginSocialButton() -> some View {
        HStack (alignment: .center, spacing: 24){
            ForEach(SocialType.allCases.filter { $0 != .none } ) { type in
                socialCircleButton(type: type) {
                    store.send(.view(.signInWithSocial(social: type)))
                }
            }
        }
    }


    @ViewBuilder
    private func socialCircleButton(
        type: SocialType,
        onTap: @escaping () -> Void
    ) -> some View {
        let circleSize: CGFloat = 44
        switch type {
            case .apple:
                ZStack {
                    Circle()
                        .fill(.black)
                        .frame(width: circleSize, height: circleSize)

                    Image(systemName: type.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 30)
                        .foregroundColor(.white)


                    SignInWithAppleButton(.signIn) { request in
                        store.send(.async(.prepareAppleRequest(request)))
                    } onCompletion: { result in
                        store.send(.async(.appleCompletion(result)))
                    }
                    .frame(width: circleSize, height: circleSize)
                    .clipShape(Circle())
                    .opacity(0.02)
                    .allowsHitTesting(true)
                }

            case .google:
                Button(action: onTap) {
                    Circle()
                        .fill(.white)
                        .overlay(Circle().stroke(.gray2, lineWidth: 1))
                        .frame(width: circleSize, height: circleSize)
                        .overlay(
                            Image(assetName: type.image)
                                .resizable().scaledToFit()
                                .frame(width: 20, height: 20)
                        )
                }
                .buttonStyle(.plain)

            case .none:
                EmptyView()
        }
    }
}

#Preview {
    LoginView(store:  Store(
        initialState: LoginFeature.State(),
        reducer: {
            LoginFeature()
        }
    ))
}
