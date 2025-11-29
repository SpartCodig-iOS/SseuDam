//
//  DSAlertState.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/29/25.
//

import SwiftUI
import ComposableArchitecture

public struct DSAlertState<Action: Equatable>: Equatable, Identifiable {
  public let id: UUID
  public let title: String
  public let message: String
  public let primaryButton: DSAlertButton<Action>
  public let secondaryButton: DSAlertButton<Action>

  public init(
    id: UUID = UUID(),
    title: String,
    message: String,
    primaryButton: DSAlertButton<Action>,
    secondaryButton: DSAlertButton<Action>
  ) {
    self.id = id
    self.title = title
    self.message = message
    self.primaryButton = primaryButton
    self.secondaryButton = secondaryButton
  }
}
