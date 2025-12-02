//
//  WebView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture


public struct WebView: View {
  @Bindable var store: StoreOf<WebFeature>

  public init(
    store: StoreOf<WebFeature>,
  ) {
    self.store = store
  }

  public var body: some View {
    ZStack {
      Color.primary50
        .edgesIgnoringSafeArea(.all)

      VStack {
        Spacer()
          .frame(height: 14)

        HStack {
            Image(assetName: "chevronLeft")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
                .foregroundColor(.appBlack)


            Spacer()
        }
        .onTapGesture {
          store.send(.backToRoot)
        }

        Spacer()
          .frame(height: 16)

        WebRepresentableView(urlToLoad: store.url)
      }
      .navigationBarBackButtonHidden(true)
//      .onAppear {
//        store.send(.startLoading)
//      }
    }
  }
}

