//
//  SocialCircleButton.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/20/25.
//


import SwiftUI
import Domain

struct SocialCircleButtonView: View {
  let type: SocialType
  let onTap: () -> Void

  private let circleSize: CGFloat = 44

  @ViewBuilder
  var body: some View {
    switch type {
    case .apple:
      Button(action: onTap) {
        Circle()
          .fill(.black)
          .frame(width: circleSize, height: circleSize)
          .overlay(
            Image(systemName: type.image)
              .resizable()
              .scaledToFit()
              .frame(width: 18, height: 30)
              .foregroundColor(.white)
          )
      }
      .buttonStyle(.plain)

    case .google:
      Button(action: onTap) {
        Circle()
          .fill(.white)
          .overlay(Circle().stroke(.gray2, lineWidth: 1))
          .frame(width: circleSize, height: circleSize)
          .overlay(
            Image(assetName: type.image)
              .resizable()
              .scaledToFit()
              .frame(width: 20, height: 20)
          )
      }
      .buttonStyle(.plain)

    case .none:
      EmptyView()
    }
  }
}
