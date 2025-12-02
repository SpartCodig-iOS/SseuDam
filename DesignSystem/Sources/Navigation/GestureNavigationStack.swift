//
//  GestureNavigationStack.swift
//  DesignSystem
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI

struct SwipeBackModifier: UIViewControllerRepresentable {
    /// 중복 적용 방지를 위한 식별 키
    static let tag = 0xD5EED1 // arbitrary unique value

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            if let navController = viewController.navigationController {
                // 이미 우리 모디파이어가 붙어 있으면 스킵
                if navController.view.tag == Self.tag {
                    return
                }
                navController.view.tag = Self.tag
                navController.interactivePopGestureRecognizer?.delegate = context.coordinator
                navController.interactivePopGestureRecognizer?.isEnabled = true
            }
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return otherGestureRecognizer is UIPanGestureRecognizer &&
            !(gestureRecognizer is UIScreenEdgePanGestureRecognizer)
        }
    }
}

public extension View {
    func enableSwipeBack() -> some View {
        self.background(SwipeBackModifier())
    }
}
