//
//  WebFeature.swift
//  WebFeature
//
//  Created by Wonji Suh  on 12/2/25.
//

import Foundation
import ComposableArchitecture


@Reducer
public struct WebFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
    var url: String = ""

    public init(url: String) {
      self.url = url
    }
  }

  public enum Action {
    case backToRoot

  }

  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
        case .backToRoot:
          return .none
      }
    }
  }
}

extension WebFeature.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
