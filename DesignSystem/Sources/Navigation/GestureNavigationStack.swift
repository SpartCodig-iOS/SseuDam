//
//  GestureNavigationStack.swift
//  DesignSystem
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI

struct SwipeBackModifier: UIViewControllerRepresentable {
    static let tag = 0xD5EED1

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            if let navController = viewController.navigationController {
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
