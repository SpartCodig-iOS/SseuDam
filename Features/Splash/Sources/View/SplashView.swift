//
//  SplashView.swift
//  SseuDam
//
//  Created by Wonji Suh  on 11/27/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

public struct SplashView: View {
  @Bindable var store: StoreOf<SplashFeature>

  public init(
    store: StoreOf<SplashFeature>
  ) {
    self.store = store
  }

    public var body: some View {
      GeometryReader { geometry in
        ZStack {
          // 기본 배경색
          Color.primary500
            .edgesIgnoringSafeArea(.all)

          // 전환될 색상이 옆에서 슬라이드
          Color.white
            .edgesIgnoringSafeArea(.all)
            .offset(x: store.isAnimated ? 0 : geometry.size.width)
            .animation(.easeInOut(duration: 0.6), value: store.isAnimated)

          // 로고
          VStack {
            Spacer()

            HStack {
              Spacer()

              Image(asset: store.isAnimated ? .logo : .whiteLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 48)
                .animation(.easeInOut(duration: 0.3), value: store.isAnimated)

              Spacer()
            }

            Spacer()
          }
        }
      }
      .onAppear {
        store.send(.startAnimation)
      }
    }
}

#Preview {
  SplashView(
    store: .init(
      initialState: SplashFeature.State(),
      reducer: {
        SplashFeature()
      })
  )
}
