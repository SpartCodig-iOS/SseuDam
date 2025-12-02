//
//  ProfileFeature.swift
//  ProfileFeature
//
//  Created by Wonji Suh  on 11/28/25.
//

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
import DesignSystem

@Reducer
public struct ProfileFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var profileImageData: Data?
        var isPhotoPickerPresented = false
        var errorMessage: String? = ""
        var isLoadingProfile = true
//        var isProfileImageLoading = false

        var selectedPhotoItem: PhotosPickerItem?

        @Shared(.appStorage("socialType"))  var socialType: SocialType? = nil
        @Shared(.appStorage("sessionId")) var sessionId: String? = ""
        @Shared(.appStorage("userId")) var userId: String? = ""


        var alert: DSAlertState<Alert>?

        var logoutStatus: LogoutStatus?
        var profile: Profile?
        var deleteUserStatus: AuthDeleteStatus?

        public init() {
        }
    }

    public enum Action: ViewAction, BindableAction, Equatable {
        case binding(BindingAction<State>)
        case view(View)
        case alert(Alert)
        case async(AsyncAction)
        case inner(InnerAction)
        case delegate(DelegateAction)

    }

    //MARK: - ViewAction
    @CasePathable
    public enum View : Equatable{
        case onAppear
        case photoPickerButtonTapped
        case profileImageSelected(Data?, String?)
        case showDeleteAlert
//        case profileImageLoadingStateChanged(Bool)
    }

    //MARK: - AlertAction
    @CasePathable
    public enum Alert : Equatable{
        case confirmDelete
        case cancel
        case dismiss
    }



    //MARK: - AsyncAction 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case logout
        case requestPhotoPermission
        case fetchProfile
        case editProfile(Data, String?, String?)
        case deleteUser

    }

    //MARK: - 앱내에서 사용하는 액션
    public enum InnerAction: Equatable {
        case logoutResponse(Result<LogoutStatus, AuthError>)
        case photoPermissionResult(Bool)
        case profileResponse(Result<Profile, ProfileError>)
        case editProfileResponse(Result<Profile, ProfileError>)
        case deleteUserResponse(Result<AuthDeleteStatus, AuthError>)
    }

    //MARK: - NavigationAction
    public enum DelegateAction: Equatable {
        case backToTravel
        case presentLogin
        case presentTerm
        case presentTernService

    }

    nonisolated enum CancelID : Hashable {
        case logout
        case profile
        case selectPhoto
        case editProfile
        case deleteUser
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

                case .alert(let alertAction):
                    return handleAlertAction(state: &state, action: alertAction)

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

            case .showDeleteAlert:
                state.alert = DSAlertState(
                    title: "계정을 삭제하시겠어요?",
                    message: "정회원 탈퇴 시 정보가 삭제되며, 복구할 수 없습니다.\n이용 중인 정산 기록도 삭제됩니다.",
                    primary: DSAlertState.ButtonAction(
                        title: "탈퇴하기",
                        role: .destructive,
                        action: .confirmDelete
                    ),
                    secondary: DSAlertState.ButtonAction(
                        title: "취소",
                        role: .cancel,
                        action: .cancel
                    )
                )
                return .none

//            case .profileImageLoadingStateChanged(let isLoading):
//                state.isProfileImageLoading = isLoading
//                return .none
        }
    }

    private func handleAlertAction(
        state: inout State,
        action: Alert
    ) -> Effect<Action> {
        switch action {
            case .confirmDelete:
                state.alert = nil
                return .send(.async(.deleteUser))

            case .cancel, .dismiss:
                state.alert = nil
                return .none
        }
    }

    private func handleAsyncAction(
        state: inout State,
        action: AsyncAction
    ) -> Effect<Action> {
        switch action {
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
                .cancellable(id: CancelID.logout, cancelInFlight: true)

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
                .cancellable(id: CancelID.selectPhoto, cancelInFlight: true)

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
                .cancellable(id: CancelID.editProfile, cancelInFlight: true)

            case .deleteUser:
                return .run { send in
                    let result = await Result {
                        try await authUseCase.deleteUser()
                    }
                        .mapError { error -> AuthError in
                            if let authError = error as? AuthError {
                                return authError
                            } else {
                                return .unknownError(error.localizedDescription)
                            }
                        }
                    return await send(.inner(.deleteUserResponse(result)))
                }
                .cancellable(id: CancelID.deleteUser, cancelInFlight: true)
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

          case .presentTerm:
            return .none

          case .presentTernService:
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

            case .deleteUserResponse(let result):
                switch result {
                    case .success(let authDeletData):
                        state.deleteUserStatus = authDeletData
                        state.$sessionId.withLock { $0 = nil }
                        state.$socialType.withLock { $0 = nil }
                        state.$userId.withLock { $0 = nil }
                        return .send(.delegate(.presentLogin))

                    case .failure(let error):
                        state.errorMessage = error.errorDescription
                        return .none

                }
        }
    }
}

extension ProfileFeature.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(profileImageData)
        hasher.combine(isPhotoPickerPresented)
        hasher.combine(selectedPhotoItem)
        hasher.combine(logoutStatus)
        hasher.combine(errorMessage)
        hasher.combine(profile)
        hasher.combine(isLoadingProfile)
//        hasher.combine(isProfileImageLoading)
    }
}
