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
        .background(.primary50)
        .sheet(item: $store.scope(state: \.destination?.termsService, action: \.destination.termsService)) { termServiceStore in
          TermsAgreementView(store: termServiceStore)
            .presentationDetents([.height(UIScreen.main.bounds.height * 0.3)])
            .presentationCornerRadius(20)
            .presentationDragIndicator(.hidden)
            .presentationBackground(.clear)
        }
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
                        .font(.app(.largeTitle, weight: .semibold))
                        .foregroundStyle(.black)

                    Spacer()
                }

                HStack(spacing: .zero) {
                    Text("쓰담")
                        .font(.app(.body, weight: .regular))
                        .foregroundStyle(.primary500)

                    Text("에서 공금 정산을 빠르고 쉽게 확인해보세요")
                        .font(.app(.body, weight: .regular))
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
                SocialCircleButtonView(
                    store: store,
                    type: type
                ) {
                    store.send(.view(.signInWithSocial(social: type)))
                }
            }
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
