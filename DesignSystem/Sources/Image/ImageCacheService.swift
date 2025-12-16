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

    private init() {
        cache.totalCostLimit = 50 * 1024 * 1024
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

        let task = Task(priority: .userInitiated) { [weak self] () -> UIImage? in
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
            let (data, response) = try await URLSession.shared.data(from: url)
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
}
