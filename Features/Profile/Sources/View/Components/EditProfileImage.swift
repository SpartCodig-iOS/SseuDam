//
// EditProfileImage.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 11/30/25.
//

import SwiftUI
import UIKit
import DesignSystem

public struct EditProfileImage: View {
  private let size: CGFloat
  private let imageURL: String?
  private let action: (() -> Void)?
  private let onLoadingStateChanged: ((Bool) -> Void)?

  public init(
    size: CGFloat = 100,
    imageURL: String? = nil,
    action: (() -> Void)? = nil,
    onLoadingStateChanged: ((Bool) -> Void)? = nil
  ) {
    self.size = size
    self.imageURL = imageURL
    self.action = action
    self.onLoadingStateChanged = onLoadingStateChanged
  }

  @ViewBuilder
  public var body: some View {
    if let action {
      Button(action: action) {
        content()
      }
      .buttonStyle(.plain)
    } else {
      content()
    }
  }

  private func content() -> some View {
    let iconSize = size * 0.55

    return ZStack {

      Circle()
        .fill(imageURL != nil ? .clear : .gray1)
        .frame(width: size, height: size)

      imageContent(iconSize: iconSize)
        .frame(width: size, height: size)
        .clipShape(Circle())

      editBadge()
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .contentShape(Circle())

  }

  @ViewBuilder
  private func imageContent(iconSize: CGFloat) -> some View {
    if let imageURL, let url = URL(string: imageURL) {
      // 🚀 최적화된 DesignSystemAsyncImage - ImageCacheService 직접 사용!
      DesignSystemAsyncImage(
        url: url,
        transaction: Transaction(animation: .easeInOut(duration: 0.25))
      ) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .onAppear {
              onLoadingStateChanged?(false)
            }
        case .failure(_):
          placeholder(iconSize: iconSize)
            .onAppear {
              onLoadingStateChanged?(false)
            }
        case .empty:
          placeholder(iconSize: iconSize)
            .opacity(0.3)
            .overlay(
              ProgressView()
                .scaleEffect(0.8)
            )
            .onAppear {
              onLoadingStateChanged?(true)
            }
        @unknown default:
          placeholder(iconSize: iconSize)
        }
      }
    } else {
      placeholder(iconSize: iconSize)
    }
  }

  private func editBadge() -> some View {
    let badgeHeight: CGFloat = 22

    return VStack(spacing: 0) {
      Spacer(minLength: 0)
      Rectangle()
        .fill(.shadow)
        .frame(height: badgeHeight)
        .overlay {
          Image(systemName: "pencil")
            .font(.system(size: 12, weight: .semibold))
            .fontWeight(.heavy)
            .foregroundColor(.white)
        }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())        // 전체를 다시 원 모양으로 잘라줌
  }

  private func placeholder(iconSize: CGFloat) -> some View {
    Image(asset: .person)
      .resizable()
      .scaledToFit()
      .offset(y: 11)
      .frame(width: 82, height: 90)
      .foregroundStyle(.primary500)
  }

}


#Preview {
  EditProfileImage()
    .padding()
    .background(Color.gray1.opacity(0.2))
}
