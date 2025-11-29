//
//  DSInputAlertState.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/29/25.
//

import SwiftUI
import ComposableArchitecture

public struct DSInputAlertState<Action: Equatable>: Equatable, Identifiable {
  public let id: UUID
  public let title: String
  public let message: String
  public let placeholder: String
  public let confirmButton: DSAlertButton<Action>
  public let secondaryButton: DSAlertButton<Action>?

  public init(
    id: UUID = UUID(),
    title: String,
    message: String,
    placeholder: String,
    confirmButton: DSAlertButton<Action>,
    secondaryButton: DSAlertButton<Action>? = nil
  ) {
    self.id = id
    self.title = title
    self.message = message
    self.placeholder = placeholder
    self.confirmButton = confirmButton
    self.secondaryButton = secondaryButton
  }
}
