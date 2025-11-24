//
//  TermsRowView.swift
//  LoginFeature
//
//  Created by Wonji Suh  on 11/24/25.
//

import SwiftUI
import DesignSystem

public struct TermsRowView: View {
  private let title: String
  private let isOn: Bool
  private let action: () -> Void

  public init(
    title: String,
    isOn: Bool,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.isOn = isOn
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        Image(systemName: isOn ? "checkmark" : "checkmark")
          .foregroundStyle(isOn ? .primary500: .gray2)


        Text(title)
          .font(.app(.body, weight: .semibold))
          .foregroundStyle(.gray8)
        Spacer()
      }
    }
    .buttonStyle(.plain)
    .contentShape(Rectangle())
    .allowsHitTesting(true)
  }
}
