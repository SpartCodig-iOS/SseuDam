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
  private let onArrowTap: (() -> Void)?

  public init(
    title: String,
    isOn: Bool,
    action: @escaping () -> Void,
    onArrowTap: (() -> Void)? = nil
  ) {
    self.title = title
    self.isOn = isOn
    self.action = action
    self.onArrowTap = onArrowTap
  }

  public var body: some View {
    HStack(spacing: 8) {
      Button(action: action) {
        HStack(spacing: 8) {
          Image(systemName: isOn ? "checkmark" : "checkmark")
            .foregroundStyle(isOn ? .primary500: .gray2)

          Text(title)
            .font(.app(.body, weight: .semibold))
            .foregroundStyle(.gray8)
        }
      }
      .buttonStyle(.plain)

      Spacer()

      if let onArrowTap = onArrowTap {
        Button(action: onArrowTap) {
          Image(systemName: "chevron.right")
            .foregroundStyle(.primary500)
            .font(.system(size: 14, weight: .medium))
        }
        .buttonStyle(.plain)
      }
    }
  }
}
