//
//  GestureNavigationStack.swift
//  DesignSystem
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI

/// 스와이프 pop 제스처
public struct GestureNavigationStack<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationStack {
            GestureNavigationStackHelper()
                .overlay(content())
        }
    }
}

/// UIKit UINavigationController의 interactivePopGestureRecognizer를 활성화하는 Helper
struct GestureNavigationStackHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()

        DispatchQueue.main.async {
            if let nav = controller.navigationController {
                nav.interactivePopGestureRecognizer?.isEnabled = true
                nav.interactivePopGestureRecognizer?.delegate = context.coordinator
            }
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}
