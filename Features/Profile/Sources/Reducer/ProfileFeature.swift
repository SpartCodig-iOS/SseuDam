//
//  ProfileFeature.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 11/28/25.
//

import Foundation
import ComposableArchitecture
import SwiftUI
import Photos
import PhotosUI
import Domain

@Reducer
public struct ProfileFeature {
  public init() {}

  @ObservableState
  public struct State: Equatable {
     var profileImageData: Data?
     var isPhotoPickerPresented = false
     var selectedPhotoItem: PhotosPickerItem?
     var logoutStatus: LogoutStatus?
     var errorMessage: String? = ""
      var profile: Profile?
      var isLoadingProfile = true
    @Shared(.appStorage("socialType"))  var socialType: SocialType? = nil

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
    case onAppear
    case photoPickerButtonTapped
    case profileImageSelected(Data?, String?)
  }



  //MARK: - AsyncAction 비동기 처리 액션
  public enum AsyncAction: Equatable {
    case logout
    case requestPhotoPermission
    case fetchProfile
    case editProfile(Data, String?, String?)

  }

  //MARK: - 앱내에서 사용하는 액션
  public enum InnerAction: Equatable {
    case logoutResponse(Result<LogoutStatus, AuthError>)
    case photoPermissionResult(Bool)
    case profileResponse(Result<Profile, ProfileError>)
    case editProfileResponse(Result<Profile, ProfileError>)
  }

  //MARK: - NavigationAction
  public enum DelegateAction: Equatable {
    case backToTravel
    case presentLogin

  }

  nonisolated enum CancelID : Hashable {
    case logout
    case profile
  }

  @Dependency(AuthUseCase.self) var authUseCase
  @Dependency(ProfileUseCase.self) var profileUseCase

  public var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        case .binding(\.selectedPhotoItem):
          return handlePhotoPickerBinding(state: &state)

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

  private func handlePhotoPickerBinding(
    state: inout State
  ) -> Effect<Action> {
    guard let item = state.selectedPhotoItem else { return .none }
    // 피커 dismiss 애니메이션과 충돌을 최소화하기 위해 즉시 nil로 초기화
    state.selectedPhotoItem = nil

    return .run(priority: .userInitiated) { send in
      if let data = try? await item.loadTransferable(type: Data.self) {
        let suggestedName = item.itemIdentifier ?? "avatar.jpg"
        await send(.view(.profileImageSelected(data, suggestedName)), animation: .none)
        return
      }

      if let fileURL = try? await item.loadTransferable(type: URL.self),
         let data = try? Data(contentsOf: fileURL) {
        let suggestedName = fileURL.lastPathComponent.isEmpty ? "avatar.jpg" : fileURL.lastPathComponent
        await send(.view(.profileImageSelected(data, suggestedName)), animation: .none)
        return
      }

      await send(.view(.profileImageSelected(nil, nil)), animation: .none)
    }
  }

  private func handleViewAction(
    state: inout State,
    action: View
  ) -> Effect<Action> {
    switch action {
      case .onAppear:
        state.selectedPhotoItem = nil
        state.isPhotoPickerPresented = false
        // Avoid refetching if already loading or data is present.
        guard state.isLoadingProfile || state.profile == nil else { return .none }
        state.isLoadingProfile = true
        return .send(.async(.fetchProfile))

      case .photoPickerButtonTapped:
        return .send(.async(.requestPhotoPermission))

      case let .profileImageSelected(data, fileName):
        state.profileImageData = data
        state.isPhotoPickerPresented = false
        guard let data else { return .none }
        let currentName = state.profile?.name
        return .send(.async(.editProfile(data, currentName, fileName)))
    }
  }

  private func handleAsyncAction(
    state: inout State,
    action: AsyncAction
  ) -> Effect<Action> {
    switch action {

      case .logout:
        return .run { send in
          let result = await Result {
            try await authUseCase.logout()
          }
            .mapError { error -> AuthError in
                if let authError = error as? AuthError {
                    return authError
                } else {
                    return .unknownError(error.localizedDescription)
                }
            }
          return await send(.inner(.logoutResponse(result)))
        }

      case .fetchProfile:
        state.isLoadingProfile = true
        return .run { send in
          let result = await Result {
            try await profileUseCase.getProfile()
          }
            .mapError { error -> ProfileError in
                if let authError = error as? ProfileError {
                    return authError
                } else {
                  return .unknown(error.localizedDescription)
                }
            }
          return await send(.inner(.profileResponse(result)))
        }
        .cancellable(id: CancelID.profile, cancelInFlight: true)

      case .requestPhotoPermission:
        return .run { send in
          let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
          switch status {
            case .authorized, .limited:
              await send(.inner(.photoPermissionResult(true)))

            case .notDetermined:
              let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
              let allowed = (newStatus == .authorized || newStatus == .limited)
              await send(.inner(.photoPermissionResult(allowed)))

            default:
              await send(.inner(.photoPermissionResult(false)))
          }
        }

      case let .editProfile(data, name, fileName):
        return .run { send in
          let result = await Result {
            try await profileUseCase.editProfile(
              ProfileEditPayload(
                name: name,
                avatarData: data,
                fileName: fileName
              )
            )
          }
          .mapError { error -> ProfileError in
            if let profileError = error as? ProfileError {
              return profileError
            } else {
              return .unknown(error.localizedDescription)
            }
          }
          await send(.inner(.editProfileResponse(result)))
        }
    }
  }

  private func handleDelegateAction(
    state: inout State,
    action: DelegateAction
  ) -> Effect<Action> {
    switch action {
      case .backToTravel:
        return .none

      case .presentLogin:
        return .none
    }
  }

  private func handleInnerAction(
    state: inout State,
    action: InnerAction
  ) -> Effect<Action> {
    switch action {

      case .logoutResponse(let result):
        switch result {
          case .success(let loginData):
            state.logoutStatus = loginData
            KeychainManager.shared.clearAll()
            return .send(.delegate(.presentLogin))

          case .failure(let error):
            state.errorMessage = error.errorDescription
            return .none
        }

      case .photoPermissionResult(let allowed):
        if allowed {
          state.isPhotoPickerPresented = true
          state.errorMessage = nil
        } else {
          state.errorMessage = "앨범 접근 권한이 필요합니다. 설정에서 허용해주세요."
        }
        return .none

      case .profileResponse(let result):
        switch result {
          case .success(let profileData):
            state.isLoadingProfile = false
            state.profile = profileData
            state.$socialType.withLock { $0 = profileData.provider}

          case .failure(let error):
            state.errorMessage = error.errorDescription
        }
        return .none

      case .editProfileResponse(let result):
        switch result {
          case .success(let profileData):
            state.profile = profileData
            state.profileImageData = nil
          case .failure(let error):
            state.errorMessage = error.errorDescription
        }
        return .none
    }
  }
}
