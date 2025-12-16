//
//  ImageCacheService.swift
//  DesignSystem
//
//  Created by Wonji Suh on 12/04/25.
//

import Foundation
import UIKit
import CryptoKit

public actor ImageCacheService {
    public static let shared = ImageCacheService()

    private let cache = NSCache<NSString, UIImage>()
    private var inFlightTasks: [URL: Task<UIImage?, Never>] = [:]
    private let session: URLSession
    private let urlCache: URLCache
    private let diskCacheURL: URL
    private init() {
        cache.totalCostLimit = 50 * 1024 * 1024
        cache.countLimit = 200  // 더 많은 이미지를 메모리에 캐시
        cache.evictsObjectsWithDiscardedContent = true  // 메모리 압박 시 자동 제거

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [] // TransparentImageCaching와 중첩되지 않도록 분리
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 20

        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        let cacheDir = cachesDir.appendingPathComponent("ImageCacheService", isDirectory: true)
        if !FileManager.default.fileExists(atPath: cacheDir.path) {
            try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
        diskCacheURL = cacheDir

        urlCache = URLCache(
            memoryCapacity: 30 * 1024 * 1024,
            diskCapacity: 120 * 1024 * 1024,
            directory: cacheDir
        )
        configuration.urlCache = urlCache

        session = URLSession(configuration: configuration)

    }

    public func image(
        for url: URL
    ) async -> UIImage? {
        let key = url.absoluteString as NSString

        if let cached = cache.object(forKey: key) {
            return cached
        }

        if let diskImage = loadDiskImage(for: url) {
            cache.setObject(diskImage, forKey: key)
            return diskImage
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
        try? FileManager.default.removeItem(at: diskCacheURL)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        urlCache.removeAllCachedResponses()
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

            guard let image = decodedImage(from: data) else { return nil }
            cache.setObject(image, forKey: key, cost: data.count)
            storeToDisk(data: data, for: url)
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

    private func storeToDisk(data: Data, for url: URL) {
        let fileURL = diskFileURL(for: url)
        try? data.write(to: fileURL, options: .atomic)
    }

    private func loadDiskImage(for url: URL) -> UIImage? {
        let fileURL = diskFileURL(for: url)
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = decodedImage(from: data) else {
            return nil
        }
        return image
    }

    private func diskFileURL(for url: URL) -> URL {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return diskCacheURL.appendingPathComponent(hash).appendingPathExtension("cache")
    }

    private func decodedImage(from data: Data) -> UIImage? {
        guard let image = UIImage(data: data), let cgImage = image.cgImage else { return nil }

        let size = CGSize(width: cgImage.width, height: cgImage.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return image }

        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let decodedImage = context.makeImage() else { return image }

        return UIImage(cgImage: decodedImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
