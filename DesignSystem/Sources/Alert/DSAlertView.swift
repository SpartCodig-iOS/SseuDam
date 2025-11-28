//
//  DSAlertView.swift
//  DesignSystem
//
//  Created by Wonji Suh on 11/28/25.
//

import SwiftUI
import ComposableArchitecture

public struct DSAlertView<Action: Equatable>: View {
  let state: DSAlertState<Action>
  let onPrimaryTap: () -> Void
  let onSecondaryTap: () -> Void
  let onBackgroundTap: () -> Void

  @State private var isPresented = false

  public init(
    state: DSAlertState<Action>,
    onPrimaryTap: @escaping () -> Void,
    onSecondaryTap: @escaping () -> Void,
    onBackgroundTap: @escaping () -> Void
  ) {
    self.state = state
    self.onPrimaryTap = onPrimaryTap
    self.onSecondaryTap = onSecondaryTap
    self.onBackgroundTap = onBackgroundTap
  }

  public var body: some View {
    ZStack {
      Color.black.opacity(0.35)
        .ignoresSafeArea()
        .onTapGesture(perform: onBackgroundTap)

      contentView
        .padding(.horizontal, 32)
        .offset(y: isPresented ? 0 : 220)
        .scaleEffect(isPresented ? 1 : 0.95)
        .opacity(isPresented ? 1 : 0)
        .transition(
          .move(edge: .bottom)
            .combined(with: .opacity)
        )
        .animation(
          .spring(response: 0.28, dampingFraction: 0.85),
          value: isPresented
        )
    }
    .transition(
      .opacity
        .combined(with: .scale(scale: 0.98))
    )
    .onAppear { isPresented = true }
  }

  private var contentView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(state.title)
        .font(.app(.title2, weight: .semibold))
        .foregroundStyle(.gray8)
        .padding(.top, 4)

      Text(state.message)
        .font(.app(.body))
        .foregroundStyle(Color.gray8)
        .lineSpacing(6)
        .multilineTextAlignment(.leading)

      VStack(spacing: 12) {
        alertButton(for: state.primaryButton, action: onPrimaryTap)
        alertButton(for: state.secondaryButton, action: onSecondaryTap)
      }
      .padding(.top, 8)
    }
    .padding(24)
    .frame(maxWidth: 360)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
  }

  private func alertButton(
    for button: DSAlertButton<Action>,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Text(button.title)
        .font(.app(.title3, weight: .semibold))
        .foregroundStyle(foregroundColor(for: button.style))
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(buttonBackground(for: button.style))
        .clipShape(Capsule())
    }
    .buttonStyle(.plain)
  }

  private func foregroundColor(for style: DSAlertButton<Action>.Style) -> Color {
    switch style {
    case .destructive:
      return Color(red: 0.89, green: 0.22, blue: 0.26)
    case .neutral:
      return .gray8
    }
  }

  private func buttonBackground(for style: DSAlertButton<Action>.Style) -> some ShapeStyle {
    switch style {
    case .destructive:
      return Color(red: 0.95, green: 0.95, blue: 0.95)
    case .neutral:
      return Color(red: 0.94, green: 0.94, blue: 0.94)
    }
  }
}

public struct DSAlertPresenter<Action: Equatable>: ViewModifier {
  private let store: Store<DSAlertState<Action>?, Action>
  @ObservedObject private var viewStore: ViewStore<DSAlertState<Action>?, Action>
  private let dismissAction: Action?

  public init(
    store: Store<DSAlertState<Action>?, Action>,
    dismissAction: Action?
  ) {
    self.store = store
    self.dismissAction = dismissAction
    self._viewStore = ObservedObject(
      wrappedValue: ViewStore(store, observe: { $0 })
    )
  }

  public func body(content: Content) -> some View {
    content
      .overlay {
        if let state = viewStore.state {
          DSAlertView(
            state: state,
            onPrimaryTap: { handleTap(button: state.primaryButton) },
            onSecondaryTap: { handleTap(button: state.secondaryButton) },
            onBackgroundTap: { sendDismiss() }
          )
          .animation(.easeInOut(duration: 0.2), value: state.id)
        }
      }
  }

  private func handleTap(
    button: DSAlertButton<Action>
  ) {
    if let action = button.action {
      store.send(action)
    }
    sendDismiss()
  }

  private func sendDismiss() {
    if let dismissAction {
      store.send(dismissAction)
    }
  }
}

public extension View {
  /// Present a design system alert that works with a TCA `Store`.
  /// - Parameters:
  ///   - store: A store holding the optional alert state.
  ///   - dismissAction: Action that should nil-out the alert in your reducer.
  func dsAlert<Action: Equatable>(
    store: Store<DSAlertState<Action>?, Action>,
    dismissAction: Action? = nil
  ) -> some View {
    modifier(
      DSAlertPresenter(
        store: store,
        dismissAction: dismissAction
      )
    )
  }
}



private enum PreviewAction: Equatable {
  case confirm
  case cancel
}

private struct PreviewFeature: Reducer {
  struct State: Equatable {
    var alert: DSAlertState<PreviewAction>?
  }

  enum Action: Equatable {
    case showAlert
    case alert(PreviewAction)
    case dismiss
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .showAlert:
        state.alert = DSAlertState<PreviewAction>(
          title: "계정을 삭제하시겠어요?",
          message: """
          회원 탈퇴 시 정보가 삭제되며, 복구할 수 없습니다.
          이용 중인 정산 기록도 삭제됩니다.
          """,
          primaryButton: DSAlertButton(
            title: "탈퇴하기",
            style: .destructive,
            action: .confirm
          ),
          secondaryButton: DSAlertButton(
            title: "취소",
            style: .neutral,
            action: .cancel
          )
        )
        return .none

      case .alert:
        state.alert = nil
        return .none

      case .dismiss:
        state.alert = nil
        return .none
      }
    }
  }
}

private struct PreviewContainer: View {
  let store: StoreOf<PreviewFeature>
  @ObservedObject private var viewStore: ViewStore<PreviewFeature.State, PreviewFeature.Action>

  init(store: StoreOf<PreviewFeature>) {
    self.store = store
    self._viewStore = ObservedObject(
      wrappedValue: ViewStore(store, observe: { $0 })
    )
  }

  var body: some View {
    ZStack {
      Color.gray.opacity(0.1).ignoresSafeArea()

      Button("Alert 보기") {
        viewStore.send(.showAlert)
      }
      .padding()
      .background(.white)
      .clipShape(Capsule())
      .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
    .dsAlert(
      store: store.scope(
        state: \.alert,
        action: PreviewFeature.Action.alert
      ),
      dismissAction: .cancel
    )
  }
}

#Preview {
  PreviewContainer(
    store: .init(
      initialState: .init(alert: nil),
      reducer: {
        PreviewFeature()
      }
    )
  )
}
