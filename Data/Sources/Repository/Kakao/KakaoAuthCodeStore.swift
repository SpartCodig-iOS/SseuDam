//
//  KakaoAuthCodeStore.swift
//  Data
//
//  Created by Assistant on 12/5/25.
//

import Foundation
import Domain
/// 간단한 메모리 저장소: Kakao OAuth 콜백에서 받은 authorization code를 보관/소비한다.
public final class KakaoAuthCodeStore {
    public static let shared = KakaoAuthCodeStore()
    private var code: String?
    private let lock = NSLock()
    private var continuations: [CheckedContinuation<String, Error>] = []

    private init() {}

    public func save(_ code: String) {
        lock.lock()
        self.code = code
        let pending = continuations
        continuations.removeAll()
        lock.unlock()
        // 깨운다
        pending.forEach { $0.resume(returning: code) }
    }

    /// 기존 코드와 대기 상태를 모두 초기화
    public func reset() {
        lock.lock()
        code = nil
        let pending = continuations
        continuations.removeAll()
        lock.unlock()
        pending.forEach { $0.resume(throwing: NSError(domain: "KakaoAuthCodeStore", code: -999, userInfo: [NSLocalizedDescriptionKey: "Reset called"])) }
    }

    public func consume() -> String? {
        lock.lock()
        defer { lock.unlock() }
        let value = code
        code = nil
        return value
    }

    public func waitForCode(timeout: TimeInterval = 60) async throws -> String {
        // 이미 저장된 코드가 있으면 즉시 반환
        if let existing = consume() {
            return existing
        }

        return try await withThrowingTaskGroup(of: String.self) { group -> String in
            // 타임아웃 태스크
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
              throw AuthError.unknownError("Kakao 로그인 응답을 받지 못했습니다")
            }
            // 코드 대기 태스크
            group.addTask {
                try await withCheckedThrowingContinuation { continuation in
                  self.lock.lock()
                  self.continuations.append(continuation)
                  self.lock.unlock()
                }
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}
