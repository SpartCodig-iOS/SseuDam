//
//  OnBoardingView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

public struct OnBoardingView: View {
  @Bindable var store: StoreOf<OnBoardingFeature>

  public init(
    store: StoreOf<OnBoardingFeature>
  ) {
    self.store = store
  }

    public var body: some View {
      VStack {
        skipOnboarding()

        TabView(selection: $store.page) {
          onBoardingText(page: store.page)
            .tag(Page.travel)

          onBoardingText(page: store.page)
            .tag(Page.travelDetail)

          onBoardingText(page: store.page)
            .tag(Page.travelExpense)

        }
        .tabViewStyle(.page(indexDisplayMode: .never))

        PageIndicator(current: store.page, all: Page.allCases)
          .padding(.top, 8)

        skipButton(page: store.page) { _ in
          withAnimation(.easeInOut(duration: 0.25)) {
            _ = store.send(.nextButtonTapped)
          }
        }
        .padding(.top, 18)
      }
      .background(.primary50)
    }
}

extension OnBoardingView {
  @ViewBuilder
  private func skipOnboarding() -> some View {
    HStack {
      Spacer()

      Text("건너띄기")
        .font(.app(.body, weight: .medium))
        .foregroundStyle(.gray2)
    }
    .padding(.vertical, 20)
    .padding(.horizontal, 20)
  }

  @ViewBuilder
  private func onBoardingText(page: Page) -> some View {
    switch page {
      case .travel:
        pageText(text: "홈에서 여행을 추가하고\n 초대받은 코드를 입력할 수 있어요")
      case .travelDetail:
        pageText(text: "지출을 확인하고 싶은 여행 카드를 선택해\n 지출 세부 내역을 확인할 수 있어요")
      case .travelExpense:
        pageText(text: "여행 설정을 통해 여행 기본 설정을 변경하고\n 멤버를 관리할 수 있어요")
    }
  }

  @ViewBuilder
  private func pageText(text: String) -> some View {
    VStack {
      HStack(alignment: .center) {
        Text(text)
          .font(.app(.title2, weight: .semibold))
          .foregroundStyle(.primary300)
          .multilineTextAlignment(.center)
      }
    }
  }

  @ViewBuilder
  private func skipButton(
    page: Page,
    action: @escaping (Page) -> Void
  ) -> some View {
    RoundedRectangle(cornerRadius: 10)
      .fill(.primary500)
      .frame(height: 52)
      .padding(.horizontal, 20)
      .overlay {
        Text(page.ctaTitle)
          .font(.app(.title3, weight: .semibold))
          .foregroundStyle(.appWhite)
      }
      .onTapGesture { action(page) }
  }
}



#Preview {
    NavigationView {
      OnBoardingView(
        store: .init(
          initialState: OnBoardingFeature.State(),
          reducer: {
          OnBoardingFeature()
        })
      )
    }
}
