//
//  DSAlertState.swift
//  DesignSystem
//
//  Created by Wonji Suh on 12/01/25.
//

import SwiftUI

public struct DSAlertState<Action: Equatable>: Equatable, Identifiable {
    public struct ButtonAction: Equatable {
        public let title: String
        public let role: ButtonRole?
        public let action: Action

        public init(
            title: String,
            role: ButtonRole? = nil,
            action: Action
        ) {
            self.title = title
            self.role = role
            self.action = action
        }
    }

    public let id = UUID()
    public let title: String
    public let message: String
    public let primary: ButtonAction
    public let secondary: ButtonAction?

    public init(
        title: String,
        message: String,
        primary: ButtonAction,
        secondary: ButtonAction? = nil
    ) {
        self.title = title
        self.message = message
        self.primary = primary
        self.secondary = secondary
    }
}
