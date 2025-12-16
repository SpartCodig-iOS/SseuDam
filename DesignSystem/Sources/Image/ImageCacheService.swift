//
//  ImageCacheService.swift
//  DesignSystem
//
//  Created by Wonji Suh on 12/04/25.
//

import Foundation
import UIKit

public actor ImageCacheService {
    public static let shared = ImageCacheService()

    private let cache = NSCache<NSString, UIImage>()
    private var inFlightTasks: [URL: Task<UIImage?, Never>] = [:]
    private let session: URLSession
    private init() {
        cache.totalCostLimit = 50 * 1024 * 1024
        cache.countLimit = 200  // 더 많은 이미지를 메모리에 캐시
        cache.evictsObjectsWithDiscardedContent = true  // 메모리 압박 시 자동 제거

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [] // TransparentImageCaching와 중첩되지 않도록 분리
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: configuration)
    }

    public func image(
        for url: URL
    ) async -> UIImage? {
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        if let task = inFlightTasks[url] {
            return await task.value
        }

        // 프로필 이미지는 높은 우선순위로 처리
        let priority: TaskPriority = isProfileImage(url) ? .high : .userInitiated
        let task = Task(priority: priority) { [weak self] () -> UIImage? in
            guard let self else { return nil }
            return await self.fetchAndCache(url: url, key: key)
        }

        inFlightTasks[url] = task

        let image = await task.value
        inFlightTasks[url] = nil
        return image
    }

    public func image(
        for urlString: String
    ) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        return await image(for: url)
    }

    public func store(
        _ image: UIImage,
        for url: URL
    ) {
        let key = url.absoluteString as NSString
        cache.setObject(image, forKey: key)
    }

    public func removeImage(
        for url: URL
    ) {
        let key = url.absoluteString as NSString
        cache.removeObject(forKey: key)
    }

    public func clear() {
        cache.removeAllObjects()
    }

    private func fetchAndCache(
        url: URL,
        key: NSString
    ) async -> UIImage? {
        do {
            let (data, response) = try await session.data(from: url)
            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else { return nil }

            guard let image = UIImage(data: data) else { return nil }
            cache.setObject(image, forKey: key, cost: data.count)
            return image
        } catch {
            return nil
        }
    }

    /// 프로필 이미지인지 확인하여 우선순위 적용
    private func isProfileImage(_ url: URL) -> Bool {
        let urlString = url.absoluteString.lowercased()
        let profileKeywords = ["profile", "avatar", "user", "member"]

        return profileKeywords.contains { keyword in
            urlString.contains(keyword)
        }
    }
}
