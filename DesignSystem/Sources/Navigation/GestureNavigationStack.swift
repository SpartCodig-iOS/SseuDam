//
//  GestureNavigationStack.swift
//  DesignSystem
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI

/// 스와이프 pop 제스처 - 전역 자동 적용
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

/// 글로벌 네비게이션 제스처 활성화
public struct GlobalNavigationGestureModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .background(
                NavigationGestureHelper()
                    .opacity(0)
                    .allowsHitTesting(false)
            )
    }
}

/// 네비게이션 제스처를 자동으로 활성화하는 Helper
private struct NavigationGestureHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> NavigationGestureController {
        NavigationGestureController()
    }

    func updateUIViewController(_ uiViewController: NavigationGestureController, context: Context) {
        uiViewController.setupGestureIfNeeded()
    }
}

/// 간단한 제스처 컨트롤러
private class NavigationGestureController: UIViewController {
    private var gestureSetupCompleted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGestureIfNeeded()
    }

    func setupGestureIfNeeded() {
        guard !gestureSetupCompleted else { return }

        // 네비게이션 컨트롤러 찾기
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let navController = next as? UINavigationController {
                setupNavigationGesture(for: navController)
                break
            }
            responder = next
        }

        gestureSetupCompleted = true
    }

    private func setupNavigationGesture(for navController: UINavigationController) {
        DispatchQueue.main.async {
            navController.interactivePopGestureRecognizer?.isEnabled = true
            if navController.interactivePopGestureRecognizer?.delegate == nil {
                navController.interactivePopGestureRecognizer?.delegate = navController
            }
        }
    }
}

/// View extension for easy usage
extension View {
    /// 네비게이션 제스처를 자동으로 활성화합니다
    public func enableNavigationGesture() -> some View {
        self.modifier(GlobalNavigationGestureModifier())
    }
}

extension UINavigationController: UIKit.UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()

    // iOS 버전별 대응
    if #available(iOS 15.0, *) {
      setupModernInteractivePopGesture()
    } else {
      setupLegacyInteractivePopGesture()
    }
  }

  @available(iOS 15.0, *)
  private func setupModernInteractivePopGesture() {
    interactivePopGestureRecognizer?.delegate = self
    interactivePopGestureRecognizer?.isEnabled = true

    // iOS 15+ 추가 설정
    if let gestureRecognizer = interactivePopGestureRecognizer {
      gestureRecognizer.delaysTouchesBegan = false
      gestureRecognizer.delaysTouchesEnded = false
    }
  }

  private func setupLegacyInteractivePopGesture() {
    interactivePopGestureRecognizer?.delegate = self
    interactivePopGestureRecognizer?.isEnabled = true
  }

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    // TCA stack 기반 체크
    let hasMultipleViewControllers = viewControllers.count > 1

    // Edge pan gesture인지 확인
    if let panGesture = gestureRecognizer as? UIScreenEdgePanGestureRecognizer {
      let translation = panGesture.translation(in: view)
      return hasMultipleViewControllers && translation.x > 0
    }

    // 일반 pan gesture인 경우
    if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGesture.translation(in: view)
      let velocity = panGesture.velocity(in: view)

      // 오른쪽으로의 드래그만 허용
      let isRightwardDrag = translation.x > 0 && abs(translation.y) < abs(translation.x)
      let isFastRightwardSwipe = velocity.x > 300 && abs(velocity.y) < abs(velocity.x)

      return hasMultipleViewControllers && (isRightwardDrag || isFastRightwardSwipe)
    }

    return hasMultipleViewControllers
  }

  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    // 스크롤뷰와의 동시 인식 방지
    if otherGestureRecognizer.view is UIScrollView {
      return false
    }
    return true
  }

  public func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    // 네비게이션 제스처가 우선순위를 가지도록
    return gestureRecognizer == interactivePopGestureRecognizer
  }
}

/// UIKit UINavigationController의 interactivePopGestureRecognizer를 활성화하는 Helper
struct GestureNavigationStackHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GestureNavigationViewController {
        let controller = GestureNavigationViewController()
        return controller
    }

    func updateUIViewController(_ uiViewController: GestureNavigationViewController, context: Context) {
        uiViewController.setupGestureIfNeeded()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let navigationController = gestureRecognizer.view?.next(UINavigationController.self) else {
                return false
            }
            return navigationController.viewControllers.count > 1
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return false
        }
    }
}

/// 제스처를 관리하는 전용 ViewController
internal class GestureNavigationViewController: UIViewController {
    private var gestureSetupCompleted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGestureIfNeeded()
    }

    func setupGestureIfNeeded() {
        guard !gestureSetupCompleted, let navigationController = navigationController else {
            return
        }

        // 기존 delegate 유지하면서 gesture 활성화
        DispatchQueue.main.async { [weak self, weak navigationController] in
            guard let self = self, let nav = navigationController else { return }

            nav.interactivePopGestureRecognizer?.isEnabled = true

            // delegate가 nil이면 설정
            if nav.interactivePopGestureRecognizer?.delegate == nil {
                nav.interactivePopGestureRecognizer?.delegate = nav
            }

            self.gestureSetupCompleted = true
        }
    }
}

/// UIResponder extension for navigation controller lookup
private extension UIResponder {
    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}


struct SwipeBackModifier: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            if let navController = viewController.navigationController {
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
