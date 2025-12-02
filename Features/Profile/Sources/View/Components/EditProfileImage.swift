//
// EditProfileImage.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 11/30/25.
//

import SwiftUI
import UIKit

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
        .fill(.appWhite)
        .frame(width: size, height: size)

      if let imageURL, let url = URL(string: imageURL) {
        AsyncImage(url: url) { phase in
          switch phase {
          case .empty:
            ProgressView()
              .onAppear { onLoadingStateChanged?(true) }
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
              .onAppear { onLoadingStateChanged?(false) }
          case .failure:
            placeholder(iconSize: iconSize)
              .onAppear { onLoadingStateChanged?(false) }
          @unknown default:
            placeholder(iconSize: iconSize)
              .onAppear { onLoadingStateChanged?(false) }
          }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
      } else {
        placeholder(iconSize: iconSize)
      }

      editBadge()
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .contentShape(Circle())
    .shadow(radius: 10)

  }

  private func editBadge() -> some View {
    let badgeHeight: CGFloat = 29
    let pencilBadgeSize = size * 0.34

    return VStack(spacing: 0) {
      Spacer(minLength: 0)      // 위는 비워두고
      Rectangle()               // 아래 29만 회색
        .fill(Color.shadow)
        .frame(height: badgeHeight)
        .overlay {
          Image(systemName: "pencil")
            .font(.system(size: pencilBadgeSize * 0.45, weight: .semibold))
            .fontWeight(.heavy)
            .foregroundColor(.white)
        }
    }
    .frame(width: size, height: size)
    .clipShape(Circle())        // 전체를 다시 원 모양으로 잘라줌
  }

  private func placeholder(iconSize: CGFloat) -> some View {
    Image(systemName: "person.fill")
      .resizable()
      .scaledToFit()
      .frame(width: iconSize, height: 90)
      .foregroundStyle(.primary500)
  }
}


#Preview {
  EditProfileImage()
    .padding()
    .background(Color.gray1.opacity(0.2))
}
