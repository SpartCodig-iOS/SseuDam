import SwiftUI
import ComposableArchitecture
import Foundation

@main
struct SseuDamApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let store = Store(
        initialState: AppFeature.State()
    ) {
        AppFeature()
#if DEBUG
            ._printChanges(
                .actionLabels
            )
#endif
    } withDependencies: {
        LiveDependencies.register(&$0)
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: store
            )
            .onOpenURL { url in
                // Kakao 딥링크(ticket/code) 저장
                handleKakaoTicket(from: url)
                store.send(.view(.handleDeepLink(url.absoluteString)))
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                if let url = userActivity.webpageURL {
                    store.send(.view(.handleDeepLink(url.absoluteString)))
                }
            }
        }
    }
}
