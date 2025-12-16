//
//  SplashFeature.swift
//  SplashFeature
//
//  Created by Wonji Suh  on 11/27/25.
//

import Foundation
import ComposableArchitecture
import Domain
import DesignSystem
import SwiftUI


@Reducer
public struct SplashFeature {
    public init() {}

    @ObservableState
    public struct State: Equatable {
        var isAnimated: Bool = false
        var errorMessage: String? = ""
        @Shared(.appStorage("sessionId")) var sessionId: String? = ""
        @Shared(.appStorage("socialType"))  var socialType: SocialType? = nil
        @Shared(.appStorage("appVersion")) var appVersion: String? = ""
        @Shared(.appStorage("appLastVersion")) var appLastVersion: String? = ""
        var sessionResult : SessionStatus?
        var version: Version?
        var alert: DSAlertState<Alert>?

        public init() {}
    }

    public enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        case view(View)
        case alert(Alert)
        case async(AsyncAction)
        case inner(InnerAction)
        case delegate(DelegateAction)

    }

    //MARK: - ViewAction
    @CasePathable
    public enum View {
        case onAppear
        case startAnimation
        case animationCompleted
        case showVersionAlert
    }

    @CasePathable
    public enum Alert : Equatable{
        case confirm
        case cancel
        case dismiss
    }

    //MARK: - AsyncAction 비동기 처리 액션
    public enum AsyncAction: Equatable {
        case checkSession
        case checkVersion
        case openURL(String)
    }

    //MARK: - 앱내에서 사용하는 액션
    public enum InnerAction: Equatable {
        case checkSessionResponse(Result<SessionStatus, AuthError>)
        case checkVersionResponse(Result<Version, VersionError>)
    }

    //MARK: - NavigationAction
    public enum DelegateAction: Equatable {
        case presentMain
        case presentLogin

    }

    nonisolated enum CancelID: Hashable {
        case session
    }

    @Dependency(SessionUseCase.self) var sessionUseCase
    @Dependency(\.continuousClock) var clock
    @Dependency(VersionUseCase.self) var versionUseCase

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
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

extension SplashFeature {
    private func handleViewAction(
        state: inout State,
        action: View
    ) -> Effect<Action> {
        switch action {
            case .onAppear:
                return .send(.async(.checkVersion))

            case .startAnimation:
                return .run { send in
                    try await Task.sleep(for: .seconds(0.5))
                    await send(.view(.animationCompleted))
                }

            case .animationCompleted:
                state.isAnimated = true
                return .run { send in
                    try await Task.sleep(for: .seconds(0.8))
                    await send(.view(.onAppear))
                }

            case .showVersionAlert:
                if state.version?.shouldUpdate == true {
                    state.alert = DSAlertState(
                        title: "새 버전이 업데이트되었어요.",
                        message: "새로운 기능과 개선사항이 적용되었어요.\n앱스토어에서 최신버전으로 업데이트 해주세요.",
                        primary: DSAlertState.ButtonAction(
                            title: "앱스토어 이동하기",
                            role: .destructive,
                            action: .confirm
                        ),
                        secondary: DSAlertState.ButtonAction(
                            title: "나중에 할게요",
                            role: .cancel,
                            action: .cancel
                        )
                    )
                }
                return .none
        }
    }

    private func handleAlertAction(
        state: inout State,
        action: Alert
    ) -> Effect<Action> {
        switch action {
            case .confirm:
                state.alert = nil
                guard
                    let urlString = state.version?.appStoreUrl, // 실제 프로퍼티명에 맞게
                    !urlString.isEmpty
                else {
                    return sessionRoutingEffect(sessionId: state.sessionId ?? "")
                }

                return .send(.async(.openURL(urlString)))

            case .cancel, .dismiss:
                state.alert = nil
                return sessionRoutingEffect(sessionId: state.sessionId ?? "")
        }
    }

    private func handleAsyncAction(
        state: inout State,
        action: AsyncAction
    ) -> Effect<Action> {
        switch action {
            case .checkSession:
                return .run { [sessionId = state.sessionId] send in
                    let result = await Result {
                        try await sessionUseCase.checkSession(sessionId: sessionId ?? "")
                    }
                        .mapError { error -> AuthError in
                            if let authError = error as? AuthError {
                                return authError
                            } else {
                                return .unknownError(error.localizedDescription)
                            }
                        }
                    await send(.inner(.checkSessionResponse(result)))
                }
                .cancellable(id: CancelID.session, cancelInFlight: true)

            case .checkVersion:
                return .run { [appVersion = state.appVersion] send in
                    let result = await Result {
                        try await versionUseCase.getVersion(bundleId: "io.sseudam.co", version: appVersion ?? "")
                    }
                        .mapError { error -> VersionError in
                            if let versionError = error as? VersionError {
                                return versionError
                            } else {
                                return .unknown(error.localizedDescription)
                            }
                        }
                    await send(.inner(.checkVersionResponse(result)))

                }

            case .openURL(let urlString):
                return .run { _ in
                    guard let url = URL(string: urlString) else { return }
                    await openURL(url)
                }
        }
    }

    private func handleDelegateAction(
        state: inout State,
        action: DelegateAction
    ) -> Effect<Action> {
        switch action {
            case .presentMain:
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
            case .checkSessionResponse(let result):
                switch result {
                    case .success(let sessionData):
                        state.sessionResult = sessionData
                        state.$sessionId.withLock { $0 = sessionData.sessionId }
                        state.$socialType.withLock { $0 = sessionData.provider }
                        return .send(.delegate(.presentLogin))
                    
                    case .failure(let error):
                        state.$socialType.withLock { $0 = nil }
                        state.errorMessage = "세션 조회 실패 : \(error.localizedDescription)"
                        return .send(.delegate(.presentLogin))
                }

            case .checkVersionResponse(let result):
                switch result {
                    case .success(let versionData):
                        state.version = versionData
                        state.$appLastVersion.withLock { $0 = versionData.version }
                        // 최신 버전(latestVersion)이 저장된 앱 버전보다 높으면 알럿 표시
                        if let savedVersion = state.appVersion,
                           versionData.version.compare(savedVersion, options: .numeric) == .orderedDescending {
                            return .send(.view(.showVersionAlert))
                        }
                        return sessionRoutingEffect(sessionId: state.sessionId ?? "")
                    case .failure(let error):
                        state.errorMessage = error.localizedDescription
                        state.$appLastVersion.withLock { $0 = "" }
                        return sessionRoutingEffect(sessionId: state.sessionId ?? "")
                }
        }
    }
}

private extension SplashFeature {
    func sessionRoutingEffect(sessionId: String?) -> Effect<Action> {
        .run { send in
            guard let sessionId = sessionId, !sessionId.isEmpty else {
                await send(.delegate(.presentLogin))
                return
            }

            guard let accessToken = KeychainManager.shared.loadAccessToken(),
                  !accessToken.isEmpty else {
                await send(.async(.checkSession))
                return
            }

            guard let expirationDate = JWTUtils.expirationDate(from: accessToken) else {
                await send(.async(.checkSession))
                return
            }

            let secondsLeft = expirationDate.timeIntervalSinceNow
            if secondsLeft <= 0 {
                await send(.delegate(.presentLogin))
                return
            }

            if secondsLeft <= 300 {
                await send(.async(.checkSession))
                return
            }

            await send(.delegate(.presentMain))
        }
    }

    @MainActor
    func openURL(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
