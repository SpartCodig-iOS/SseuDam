//
//  TermsAgreementView.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/24/25.
//

import SwiftUI

import DesignSystem

import ComposableArchitecture

public struct TermsAgreementView: View {
  @Bindable var store: StoreOf<TermsAgreementFeature>

  init(
    store: StoreOf<TermsAgreementFeature>
  ) {
    self.store = store
  }
  public var body: some View {
    VStack(alignment: .leading) {
      Spacer()
        .frame(height: 32)

      termsText()

      termsAgreeButton()

      signUpButton()

      Spacer()
        .frame(height: 32)
    }
    .frame(maxWidth: .infinity)
    .background(.white)

  }
}

extension TermsAgreementView {

  @ViewBuilder
  private func termsText() -> some View {
    HStack {
      Text("약관에 동의해주세요")
        .font(.app(.title3, weight: .semibold))
        .foregroundStyle(.gray8)

      Spacer()
    }
    .padding(.horizontal, 20)
  }

  @ViewBuilder
  private func termsAgreeButton() -> some View {
    VStack(spacing: 12) {
      Spacer()
        .frame(height: 12)

      TermsRowView(
        title: "약관 전체 동의",
        isOn: store.allAgreed
      ) {
        store.send(.view(.didTapAll))
      }

      Divider()
        .background(.gray2)
        .frame(height: 1)
        .bold()

      TermsRowView(
        title: "개인정보 처리방침 동의 (필수)",
        isOn: store.privacyAgreed,
        action: {
          store.send(.view(.didTapPrivacy))
        },
        onArrowTap: {
          store.send(.navigation(.presentPrivacyWeb))
        }
      )


      TermsRowView(
        title: "서비스 이용 약관 동의 (필수)",
        isOn: store.serviceAgreed,
        action: {
          store.send(.view(.didTapService))
        },
        onArrowTap: {
          store.send(.navigation(.presentServiceWeb))
        }
      )

    }
    .padding(.horizontal, 20)
  }


  @ViewBuilder
  private func signUpButton() -> some View {
    VStack {
      Spacer()
        .frame(height: 24)

      Button(action: {
        store.send(.scope(.closeModel))
      }) {
        RoundedRectangle(cornerRadius: 8)
          .fill(store.allAgreed ? .primary500 : .gray2)
          .frame(height: 51)
          .overlay {
            Text("회원가입하기")
              .foregroundStyle(.white)
          }
      }
      .buttonStyle(.plain)
      .contentShape(Rectangle())
      .allowsHitTesting(true)
      .disabled(!store.allAgreed)
    }
    .padding(.horizontal, 20)
  }
}

#Preview {
  TermsAgreementView(
    store: .init(
      initialState: TermsAgreementFeature.State(),
      reducer: {
        TermsAgreementFeature()
      })
  )
}
