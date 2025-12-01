//
//  DSAlertPresenter.swift
//  DesignSystem
//
//  Created by Wonji Suh on 12/01/25.
//

import SwiftUI

public struct DSAlertPresenter<Action: Equatable>: ViewModifier {
    @Binding var alert: DSAlertState<Action>?
    let onAction: (Action) -> Void
    
    public func body(content: Content) -> some View {
        content.alert(item: $alert) { alertState in
            Alert(
                title: Text(alertState.title),
                message: Text(alertState.message),
                primaryButton: makeButton(alertState.primary),
                secondaryButton: secondaryButton(from: alertState)
            )
        }
    }
    
    private func secondaryButton(from state: DSAlertState<Action>) -> Alert.Button {
        guard let secondary = state.secondary else {
            return .cancel()
        }
        
        return makeButton(secondary, defaultRole: .cancel)
    }
    
    private func makeButton(
        _ button: DSAlertState<Action>.ButtonAction,
        defaultRole: ButtonRole? = nil
    ) -> Alert.Button {
        let perform = { onAction(button.action) }
        
        switch button.role ?? defaultRole {
            case .cancel:
                return .cancel(Text(button.title), action: perform)
            case .destructive:
                return .destructive(Text(button.title), action: perform)
            default:
                return .default(Text(button.title), action: perform)
        }
    }
}

public extension View {
    func dsAlert<Action: Equatable>(
        _ alert: Binding<DSAlertState<Action>?>,
        onAction: @escaping (Action) -> Void
    ) -> some View {
        modifier(DSAlertPresenter(alert: alert, onAction: onAction))
    }
}
