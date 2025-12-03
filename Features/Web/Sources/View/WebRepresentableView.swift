//
//  WebRepresentableView.swift
//  WebFeature
//
//  Created by Wonji Suh  on 12/2/25.
//

import SwiftUI
import WebKit

public struct WebRepresentableView: UIViewRepresentable {

  // MARK: - URL to load
  private var urlToLoad: String

  public init(urlToLoad: String) {
    self.urlToLoad = urlToLoad
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public func makeUIView(context: Context) -> UIView {
    // 컨테이너
    let containerView = UIView()
    containerView.backgroundColor = .white

    // WKWebView
    let configuration = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.scrollView.showsVerticalScrollIndicator = false
    webView.scrollView.minimumZoomScale = 1.0
    webView.scrollView.maximumZoomScale = 1.0
    webView.navigationDelegate = context.coordinator
    webView.uiDelegate = context.coordinator
    webView.allowsLinkPreview = true
    webView.backgroundColor = .white
    webView.translatesAutoresizingMaskIntoConstraints = false

    let spinner = UIActivityIndicatorView(style: .large)
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.hidesWhenStopped = true
    spinner.isHidden = false

    containerView.addSubview(webView)
    containerView.addSubview(spinner)

    NSLayoutConstraint.activate([
      // WebView는 전체
      webView.topAnchor.constraint(equalTo: containerView.topAnchor),
      webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

      // 스피너는 중앙
      spinner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      spinner.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
    ])

    // 코디네이터가 참조 보관
    context.coordinator.webView = webView
    context.coordinator.spinner = spinner

    // 로드 직전에 스피너 시작
    spinner.startAnimating()
    spinner.alpha = 1

    // 로드
    _Concurrency.Task {
      await loadURLInWebView(urlToLoad: urlToLoad, webView: webView)
    }

    return containerView
  }

  func loadURLInWebView(urlToLoad: String, webView: WKWebView) async {
    guard let url = URL(string: urlToLoad) else {
      print("INVALID URL")
      return
    }
    let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)

    await MainActor.run {
      webView.configuration.upgradeKnownHostsToHTTPS = true
      webView.configuration.preferences.minimumFontSize = 16
      webView.load(request)
    }
  }

  public func updateUIView(_ uiView: UIView, context: Context) {
    // 필요 시 업데이트
  }

  // MARK: - Coordinator
  public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var parent: WebRepresentableView
    weak var webView: WKWebView?
    weak var spinner: UIActivityIndicatorView?

    init(_ parent: WebRepresentableView) {
      self.parent = parent
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      // 로딩 시작 → 스피너 표시
      DispatchQueue.main.async { [weak self ] in
        self?.spinner?.alpha = 1
        self?.spinner?.startAnimating()
      }
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      // 로딩 완료 → 스피너 숨김(페이드아웃)
      hideSpinner()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      hideSpinner()
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      hideSpinner()
    }

    private func hideSpinner() {
      DispatchQueue.main.async { [weak self ] in
        guard let spinner = self?.spinner else { return }
        UIView.animate(withDuration: 0.2, animations: {
          spinner.alpha = 0
        }, completion: { _ in
          spinner.stopAnimating()
          spinner.alpha = 1 // 다음 로딩 대비 초기화
        })
      }
    }
  }
}
