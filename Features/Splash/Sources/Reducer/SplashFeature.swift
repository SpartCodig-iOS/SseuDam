//
//  SplashFeature.swift
//  SplashFeature
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation
import ComposableArchitecture


@Reducer
public struct SplashFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    public var isAnimated: Bool = false

    public init() {}
  }

  public enum Action {
    case startAnimation
    case animationCompleted
  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .startAnimation:
        return .run { send in
          try await Task.sleep(for: .seconds(0.8))
          await send(.animationCompleted)
        }

      case .animationCompleted:
        state.isAnimated = true
        return .none
      }
    }
  }
}


