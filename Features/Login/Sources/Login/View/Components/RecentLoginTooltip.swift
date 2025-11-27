//
//  RecentLoginTooltip.swift
//  LoginFeature
//
//  Created by Wonji Suh on 11/25/25.
//

import SwiftUI
import DesignSystem
import Domain

struct RecentLoginTooltip: View {
  let socialType: SocialType
  let isVisible: Bool
  private let circleSize: CGFloat
  private let spacing: CGFloat

  @State private var showTooltip = false

  init(
    socialType: SocialType = .google,
    isVisible: Bool = false,
    circleSize: CGFloat = 44,
    spacing: CGFloat = 24
  ) {
    self.socialType = socialType
    self.isVisible = isVisible
    self.circleSize = circleSize
    self.spacing = spacing
  }

  var body: some View {
    if isVisible {
      VStack(spacing: -1) {
        pointer
        bubble
      }
      .opacity(showTooltip ? 1 : 0)
      .offset(y: showTooltip ? 0 : -6)
      .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showTooltip)
      .onAppear { showTooltip = true }
    }
  }

  private var bubble: some View {
    Text("마지막에 로그인한 계정이에요!")
      .font(.app(.caption2, weight: .medium))
      .foregroundColor(.gray8)
      .padding(.horizontal, 14)
      .padding(.vertical, 9)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(.white)
          .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
              .stroke(.gray2, lineWidth: 1)
          )
      )
  }

  private var pointer: some View {
    HStack(spacing: 0) {
      Spacer()
        .frame(width: pointerOffset - pointerWidth / 2)

      UpTriangle()
        .fill(.white)
        .frame(width: pointerWidth, height: 8)
        .overlay(
          UpTriangle()
            .stroke(.gray2, lineWidth: 1)
        )

      Spacer()
    }
    .frame(width: iconRowWidth, alignment: .leading)
  }

  private var iconRowWidth: CGFloat {
    (circleSize * 2) + spacing
  }

  private var pointerOffset: CGFloat {
    switch socialType {
    case .apple:
      return circleSize / 2
    case .google:
      return circleSize + spacing + (circleSize / 2)
    case .none:
      return circleSize / 2
    }
  }

  private var pointerWidth: CGFloat { 14 }
}

// 툴팁 화살표를 위한 Triangle Shape (위쪽 방향)
struct UpTriangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.midX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

#Preview {
  VStack(spacing: 12) {
    HStack(spacing: 24) {
      Circle()
        .fill(.black)
        .frame(width: 44, height: 44)
        .overlay(Image(systemName: "apple.logo").foregroundStyle(.white))

      Circle()
        .stroke(.gray2, lineWidth: 1)
        .background(Circle().fill(.white))
        .frame(width: 44, height: 44)
        .overlay(Image(assetName: "google"))
    }

    RecentLoginTooltip(
      socialType: .google,
      isVisible: true
    )
  }
  .padding(32)
  .background(.primary50)
}
