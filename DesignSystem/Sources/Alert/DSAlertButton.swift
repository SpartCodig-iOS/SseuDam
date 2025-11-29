//
//  DSAlertButton.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/29/25.
//

import SwiftUI
import ComposableArchitecture

public struct DSAlertButton<Action: Equatable>: Equatable {
  public enum Style: Equatable {
    case destructive
    case neutral
  }

  public let title: String
  public let style: Style
  public let action: Action?

  public init(
    title: String,
    style: Style = .neutral,
    action: Action? = nil
  ) {
    self.title = title
    self.style = style
    self.action = action
  }
}
