//
//  ProfileFeature.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 11/28/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import PhotosUI

@Reducer
public struct ProfileFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
     var profileImageData: Data?
     var isPhotoPickerPresented = false
     var selectedPhotoItem: PhotosPickerItem?

    public init(profileImageData: Data? = nil) {
      self.profileImageData = profileImageData
    }
  }

  public enum Action: ViewAction, BindableAction {
    case binding(BindingAction<State>)
    case view(View)
    case async(AsyncAction)
    case inner(InnerAction)
    case delegate(DelegateAction)

  }

  //MARK: - ViewAction
  @CasePathable
  public enum View {
    case photoPickerButtonTapped
    case profileImageSelected(Data?)
  }



  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {

  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
  }

  //MARK: - NavigationAction
  public enum DelegateAction: Equatable {
    case backToTravel

  }


  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .binding(_):
          return .none

        case .view(let viewAction):
          return handleViewAction(state: &state, action: viewAction)

        case .async(let asyncAction):
          return handleAsyncAction(state: &state, action: asyncAction)

        case .inner(let innerAction):
          return handleInnerAction(state: &state, action: innerAction)

        case .delegate(let navigationAction):
          return handleDelegateAction(state: &state, action: navigationAction)
      }
    }
  }
}

extension ProfileFeature {
  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .photoPickerButtonTapped:
        state.isPhotoPickerPresented = true
        return .none

      case let .profileImageSelected(data):
        state.profileImageData = data
        state.isPhotoPickerPresented = false
        return .none
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {

    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
      case .backToTravel:
        return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {

    }
  }

}
