//
//  DSInputAlertView.swift
//  DesignSystem
//
//  Created by Wonji Suh  on 11/29/25.
//

import SwiftUI
import ComposableArchitecture

public struct DSInputAlertView<Action: Equatable>: View {
  let state: DSInputAlertState<Action>
  @Binding var text: String
  let onConfirm: () -> Void
  let onSecondaryTap: (() -> Void)?
  let onBackgroundTap: () -> Void

  @State private var isPresented = false

  public init(
    state: DSInputAlertState<Action>,
    text: Binding<String>,
    onConfirm: @escaping () -> Void,
    onSecondaryTap: (() -> Void)?,
    onBackgroundTap: @escaping () -> Void
  ) {
    self.state = state
    self._text = text
    self.onConfirm = onConfirm
    self.onSecondaryTap = onSecondaryTap
    self.onBackgroundTap = onBackgroundTap
  }

  public var body: some View {
    ZStack {
      Color.black.opacity(0.35)
        .ignoresSafeArea()
        .onTapGesture(perform: onBackgroundTap)

      VStack(alignment: .leading, spacing: 16) {
        Text(state.title)
          .font(.app(.title2, weight: .semibold))
          .foregroundStyle(Color.gray8)
          .padding(.top, 4)

        Text(state.message)
          .font(.app(.body))
          .foregroundStyle(Color.gray8)
          .lineSpacing(4)
          .multilineTextAlignment(.leading)

        inputField

        VStack(spacing: 12) {
          primaryButton
          if let _ = state.secondaryButton {
            secondaryButton
          }
        }
        .padding(.top, 6)
      }
      .padding(24)
      .frame(maxWidth: 360)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
      .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 10)
      .offset(y: isPresented ? 0 : 220)
      .scaleEffect(isPresented ? 1 : 0.95)
      .opacity(isPresented ? 1 : 0)
      .transition(.move(edge: .bottom).combined(with: .opacity))
      .animation(.spring(response: 0.28, dampingFraction: 0.85), value: isPresented)
    }
    .onAppear { isPresented = true }
  }

  private var inputField: some View {
    TextField(state.placeholder, text: $text)
      .padding(.horizontal, 16)
      .frame(height: 52)
      .background(Color.gray.opacity(0.15))
      .clipShape(Capsule())
      .font(.app(.title3, weight: .medium))
      .foregroundStyle(Color.gray8)
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
  }

  private var primaryButton: some View {
    Button(action: onConfirm) {
      Text(state.confirmButton.title)
        .font(.app(.title3, weight: .semibold))
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color(red: 0.31, green: 0.12, blue: 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
    .buttonStyle(.plain)
  }

  private var secondaryButton: some View {
    Button(action: { onSecondaryTap?() }) {
      Text(state.secondaryButton?.title ?? "")
        .font(.app(.title3, weight: .semibold))
        .foregroundStyle(Color.gray8)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    .buttonStyle(.plain)
  }
}

public struct DSInputAlertPresenter<Action: Equatable>: ViewModifier {
  private let store: Store<DSInputAlertState<Action>?, Action>
  @ObservedObject private var viewStore: ViewStore<DSInputAlertState<Action>?, Action>
  @Binding private var text: String
  private let dismissAction: Action?

  public init(
    store: Store<DSInputAlertState<Action>?, Action>,
    text: Binding<String>,
    dismissAction: Action?
  ) {
    self.store = store
    self._text = text
    self.dismissAction = dismissAction
    self._viewStore = ObservedObject(
      wrappedValue: ViewStore(store, observe: { $0 })
    )
  }

  public func body(content: Content) -> some View {
    content
      .overlay {
        if let state = viewStore.state {
          DSInputAlertView(
            state: state,
            text: $text,
            onConfirm: { handleTap(button: state.confirmButton) },
            onSecondaryTap: state.secondaryButton != nil ? { handleTap(button: state.secondaryButton!) } : nil,
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
  /// Present an input alert with a text field backed by a TCA `Store`.
  /// - Parameters:
  ///   - store: Optional state describing the alert.
  ///   - text: Binding to the text field value.
  ///   - dismissAction: Action that should nil-out the alert in your reducer.
  func dsInputAlert<Action: Equatable>(
    store: Store<DSInputAlertState<Action>?, Action>,
    text: Binding<String>,
    dismissAction: Action? = nil
  ) -> some View {
    modifier(
      DSInputAlertPresenter(
        store: store,
        text: text,
        dismissAction: dismissAction
      )
    )
  }
}

#Preview("Input Alert") {
  enum PreviewAction: Equatable {
    case show
    case confirm
    case cancel
  }

  struct PreviewFeature: Reducer {
    struct State: Equatable {
      var alert: DSInputAlertState<PreviewAction>?
      var code: String = ""
    }

    enum Action: Equatable {
      case showAlert
      case alert(PreviewAction)
      case setCode(String)
    }

    var body: some ReducerOf<Self> {
      Reduce { state, action in
        switch action {
        case .setCode(let code):
          state.code = code
          return .none

        case .showAlert:
          state.alert = DSInputAlertState(
            title: "초대 코드를 입력해주세요",
            message: "ex) 1A1A1A",
            placeholder: "",
            confirmButton: .init(
              title: "확인",
              style: .neutral,
              action: .confirm
            )
          )
          return .none

        case .alert:
          state.alert = nil
          return .none
        }
      }
    }
  }

  struct PreviewContainer: View {
    let store: StoreOf<PreviewFeature>
    @ObservedObject private var viewStore: ViewStore<PreviewFeature.State, PreviewFeature.Action>

    init(store: StoreOf<PreviewFeature>) {
      self.store = store
      self._viewStore = ObservedObject(wrappedValue: ViewStore(store, observe: { $0 }))
    }

    var body: some View {
      ZStack {
        Color.gray.opacity(0.1).ignoresSafeArea()

        Button("Input Alert 보기") {
          viewStore.send(.showAlert)
        }
        .padding()
        .background(.white)
        .clipShape(Capsule())
      }
      .dsInputAlert(
        store: store.scope(state: \.alert, action: PreviewFeature.Action.alert),
        text: Binding(
          get: { viewStore.code },
          set: { viewStore.send(.setCode($0)) }
        ),
        dismissAction: .cancel
      )
    }
  }

  return PreviewContainer(
    store: .init(
      initialState: .init(),
      reducer: {
        PreviewFeature()
      }
    )
  )
}
