//
//  TransparentImageCaching.swift
//  DesignSystem
//
//  Created by Wonji Suh on 12/16/25.
//

import Foundation
import UIKit

// MARK: - Actor for Thread-Safe Cache Management

/// Thread-safe한 캐싱 로직을 담당하는 Actor
private actor CacheManager {
    private let imageCache = ImageCacheService.shared
    private var processingRequests: Set<URL> = []

    func getCachedImage(for url: URL) async -> UIImage? {
        return await imageCache.image(for: url)
    }

    func storeImage(_ image: UIImage, for url: URL) async {
        await imageCache.store(image, for: url)
        processingRequests.remove(url)
    }

    func shouldProcessRequest(_ url: URL) -> Bool {
        return TransparentImageCaching.isImageRequest(url)
    }

    func startProcessing(_ url: URL) -> Bool {
        guard !processingRequests.contains(url) else {
            return false // 이미 처리 중
        }
        processingRequests.insert(url)
        return true
    }

    func stopProcessing(_ url: URL) {
        processingRequests.remove(url)
    }

    func isProcessing(_ url: URL) -> Bool {
        return processingRequests.contains(url)
    }

    func clearCache() async {
        await imageCache.clear()
        processingRequests.removeAll()
    }

    func processingRequestsCount() -> Int {
        return processingRequests.count
    }
}

/// 완전히 투명한 이미지 캐싱을 제공하는 URLProtocol
/// 기존 AsyncImage, URLSession 등 모든 이미지 요청이 자동으로 캐싱됨
public final class TransparentImageCaching: URLProtocol {
    private static let handledKey = "TransparentImageCaching_Handled"
    private static let registrationManager = RegistrationManager()

    // Actor 인스턴스로 캐싱 로직 위임
    private static let cacheManager = CacheManager()

    // MARK: - URLProtocol Override Methods

    override public class func canInit(with request: URLRequest) -> Bool {
        // 이미 처리된 요청은 제외
        guard URLProtocol.property(forKey: handledKey, in: request) == nil else {
            return false
        }

        // 이미지 요청인지 확인
        guard let url = request.url else { return false }

        return isImageRequest(url)
    }

    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override public func startLoading() {
        guard let url = request.url else {
            finishWithError(URLError(.badURL))
            return
        }

        Task { [weak self] in
            guard let self else { return }
            await self.handleImageRequest(url: url)
        }
    }

    override public func stopLoading() {
        // 정리 작업 (필요시)
    }

    // MARK: - Private Methods

    private func handleImageRequest(url: URL) async {
        // 1. Actor를 통해 캐시에서 확인
        if let cachedImage = await Self.cacheManager.getCachedImage(for: url) {
            await sendCachedImageResponse(image: cachedImage, url: url)
            return
        }

        // 2. 중복 요청 방지 체크
        let canStart = await Self.cacheManager.startProcessing(url)
        guard canStart else {
            // 이미 다른 곳에서 처리 중이면 대기
            await waitForProcessingCompletion(url: url)
            return
        }

        // 3. 네트워크에서 가져오기
        await fetchImageFromNetwork(url: url)
    }

    private func waitForProcessingCompletion(url: URL) async {
        // 프로필 이미지는 더 짧은 대기시간으로 최적화
      let waitTime: UInt64 = TransparentImageCaching.isProfileImage(url) ? 50 : 100
        try? await Task.sleep(for: .milliseconds(waitTime))

        if let cachedImage = await Self.cacheManager.getCachedImage(for: url) {
            await sendCachedImageResponse(image: cachedImage, url: url)
        } else {
            finishWithError(URLError(.resourceUnavailable))
        }
    }

    private func fetchImageFromNetwork(url: URL) async {
        do {
            // 새로운 URLSession으로 실제 요청 (무한루프 방지)
            let config = URLSessionConfiguration.default
            config.protocolClasses = [] // URLProtocol 제외
            let session = URLSession(configuration: config)

            let (data, response) = try await session.data(from: url)

            // 이미지 데이터 검증 및 Actor를 통한 캐시 저장
            if let image = UIImage(data: data) {
                await Self.cacheManager.storeImage(image, for: url)
            }

            await MainActor.run {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            }

        } catch {
            // 실패 시 처리 중 상태 해제
            await Self.cacheManager.stopProcessing(url)

            finishWithError(error)
        }
    }

    @MainActor
    private func sendCachedImageResponse(image: UIImage, url: URL) {
        guard let data = image.pngData() else {
            finishWithError(URLError(.cannotDecodeContentData))
            return
        }

        // 가짜 HTTP 응답 생성
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [
                "Content-Type": "image/png",
                "Content-Length": "\(data.count)",
                "Cache-Control": "max-age=3600"
            ]
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    private func finishWithError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    // MARK: - Helper Methods

    /// 이미지 요청인지 확인하는 public static 메소드 (Actor에서 호출 가능)
    public static func isImageRequest(_ url: URL) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "webp", "svg", "bmp", "tiff"]
        let pathExtension = url.pathExtension.lowercased()

        // 확장자로 확인
        if imageExtensions.contains(pathExtension) {
            return true
        }

        // URL 경로에 이미지 관련 키워드 포함 확인
        let urlString = url.absoluteString.lowercased()
        let imageKeywords = ["image", "photo", "avatar", "profile", "thumbnail", "icon"]

        return imageKeywords.contains { keyword in
            urlString.contains(keyword)
        }
    }

    /// 프로필 이미지인지 확인하여 최적화 적용
    private static func isProfileImage(_ url: URL) -> Bool {
        let urlString = url.absoluteString.lowercased()
        let profileKeywords = ["profile", "avatar", "user", "member"]

        return profileKeywords.contains { keyword in
            urlString.contains(keyword)
        }
    }

}

// MARK: - Public Interface

extension TransparentImageCaching {
    /// 투명한 이미지 캐싱을 수동으로 활성화합니다.
    /// 일반적으로는 ImageCacheService 사용 시 자동으로 활성화됩니다.
    public static func activate() async {
        await registrationManager.activate()
    }

    /// 투명한 이미지 캐싱을 비활성화합니다.
    public static func deactivate() async {
        await registrationManager.deactivate()
    }

    /// 캐시를 완전히 지웁니다.
    public static func clearCache() async {
        await cacheManager.clearCache()
    }

    /// 현재 처리 중인 요청 수를 반환합니다. (디버깅용)
    public static func processingRequestCount() async -> Int {
        await cacheManager.processingRequestsCount()
    }
}

// MARK: - Sendable Conformance

extension TransparentImageCaching: @unchecked Sendable {}

// MARK: - Registration Actor

private actor RegistrationManager {
    private var isRegistered = false

    func activate() {
        guard !isRegistered else { return }
        URLProtocol.registerClass(TransparentImageCaching.self)
        isRegistered = true
    }

    func deactivate() {
        guard isRegistered else { return }
        URLProtocol.unregisterClass(TransparentImageCaching.self)
        isRegistered = false
    }
}
