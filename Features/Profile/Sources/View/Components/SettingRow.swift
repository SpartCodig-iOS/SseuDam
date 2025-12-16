//
//  SettingRow.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 12/1/25.
//

import SwiftUI
import DesignSystem

public struct SettingRow: View {
  private var image: ImageAsset
  private var title: String
  private var showArrow: Bool
  private var action: () -> Void
  private var tapTermAction: () -> Void

  public init(
    image: ImageAsset,
    title: String,
    showArrow: Bool,
    action: @escaping () -> Void,
    tapTermAction: @escaping () -> Void
  ) {
    self.image = image
    self.title = title
    self.showArrow = showArrow
    self.action = action
    self.tapTermAction = tapTermAction
  }

  public var body: some View {
    VStack {
      HStack {
       Image(asset: image)
          .resizable()
          .scaledToFit()
          .frame(width: 20, height: 20)

        Spacer()
          .frame(width: 12)

        Text(title)
          .font(.app(.title3, weight: .regular))
          .foregroundStyle(.appBlack)

        Spacer()

        if showArrow {
          Image(asset: .chevronRight)
            .resizable()
            .scaledToFit()
            .frame(height: 24)
            .foregroundColor(.appBlack)
        }
      }
    }
    .padding(.vertical, 12)
    .onTapGesture {
      if showArrow {
        tapTermAction()
      } else {
        action()
      }
    }
  }
}


#Preview {
  SettingRow(
    image: .signOut,
    title: "회원탈퇴",
    showArrow: true,
    action: {},
    tapTermAction: {}
  )
  .padding(.horizontal, 16)
}
