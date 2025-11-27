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
      tooltip
        .offset(x: bubbleOffset)
        .opacity(showTooltip ? 1 : 0)
        .offset(y: showTooltip ? 0 : -6)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showTooltip)
        .onAppear { showTooltip = true }
    }
  }

  private var tooltip: some View {
    Text("마지막에 로그인한 계정이에요!")
      .font(.app(.caption2, weight: .medium))
      .foregroundColor(.gray8)
      .padding(.horizontal, 14)
      .padding(.vertical, 9)
      .frame(width: bubbleWidth, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(.white)
          .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .stroke(.gray2, lineWidth: 1)
          )
          .overlay(alignment: .topLeading) {
            pointer
              .offset(x: pointerOffset - pointerWidth / 2, y: -pointerHeight)
          }
      )
  }

  private var pointer: some View {
    ZStack(alignment: .topLeading) {
      UpTriangle()
        .fill(.white)
        .frame(width: pointerWidth, height: pointerHeight)
        .overlay(
          UpTriangle()
            .stroke(.gray2, lineWidth: 1)
        )
    }
  }

  private var pointerOffset: CGFloat { bubbleWidth - 24 }

  private var bubbleOffset: CGFloat {
    let halfGap = (circleSize + spacing) / 2
    let targetX: CGFloat
    switch socialType {
    case .apple:
      targetX = -halfGap
    case .google:
      targetX = halfGap
    case .none:
      targetX = 0
    }
    // Place bubble so that the pointer sits under the target icon center.
    return targetX + bubbleWidth / 2 - pointerOffset
  }

  private var bubbleWidth: CGFloat  = 150
  private var pointerWidth: CGFloat  = 14
  private var pointerHeight: CGFloat  = 8
}

// Triangle shape for the tooltip tail.
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
