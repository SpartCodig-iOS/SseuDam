//
//  DSAlertStorePresenter.swift
//  DesignSystem
//
//  Created by Wonji Suh on 12/01/25.
//

import SwiftUI
import ComposableArchitecture

/// TCA 전용 OS Alert Presenter
public struct DSAlertStorePresenter<Action: Equatable>: ViewModifier {
    let store: Store<DSAlertState<Action>?, Action>
    let dismissAction: Action

    @ObservedObject private var viewStore: ViewStore<DSAlertState<Action>?, Action>

    public init(
        store: Store<DSAlertState<Action>?, Action>,
        dismissAction: Action
    ) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        self.dismissAction = dismissAction
    }

    public func body(content: Content) -> some View {
        content.alert(
            item: Binding(
                get: { viewStore.state },
                set: { _ in _ = viewStore.send(dismissAction) }
            )
        ) { alertState in
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
            return .cancel {
                _ = viewStore.send(dismissAction)
            }
        }

        return makeButton(secondary, defaultRole: .cancel)
    }

    private func makeButton(
        _ button: DSAlertState<Action>.ButtonAction,
        defaultRole: ButtonRole? = nil
    ) -> Alert.Button {
        let send = { _ = viewStore.send(button.action) }

        switch button.role ?? defaultRole {
            case .cancel:
                return .cancel(Text(button.title), action: send)
            case .destructive:
                return .destructive(Text(button.title), action: send)
            default:
                return .default(Text(button.title), action: send)
        }
    }
}

public extension View {
    func dsAlert<Action: Equatable>(
        _ store: Store<DSAlertState<Action>?, Action>,
        dismissAction: Action
    ) -> some View {
        modifier(DSAlertStorePresenter(store: store, dismissAction: dismissAction))
    }
}
