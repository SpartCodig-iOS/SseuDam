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
        case profileImageSelected(Data?)
    }
    
    
    
    //MARK: - AsyncAction 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case logout
        case requestPhotoPermission
        case fetchProfile
        
    }
    
    //MARK: - 앱내에서 사용하는 액션
    public enum InnerAction: Equatable {
        case logoutResponse(Result<LogoutStatus, AuthError>)
        case photoPermissionResult(Bool)
        case profileResponse(Result<Profile, ProfileError>)
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
        case .onAppear:
            // Avoid refetching if already loading or data is present.
            guard state.isLoadingProfile || state.profile == nil else { return .none }
            state.isLoadingProfile = true
            return .send(.async(.fetchProfile))
            
        case .photoPickerButtonTapped:
            return .send(.async(.requestPhotoPermission))
            
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
    }
}
