//
//  TokenManager.swift
//  Domain
//
//  Created by Wonji Suh on 11/28/25.
//

import Foundation
import LogMacro
import Domain
import Alamofire

// MARK: - 토큰 상태 enum
public enum TokenStatus {
    case valid
    case expiringSoon
    case missing
}

public final actor TokenManager {
    public static let shared = TokenManager()

    private var refreshTimer: Timer?
    private let refreshThresholdMinutes: TimeInterval = 5 * 60 // 5분

    private init() {}

    // MARK: - 스마트 토큰 체크 스케줄링
    public func scheduleTokenRefreshCheck() {
        stopTokenRefreshCheck() // 기존 타이머 정리

        guard let accessToken = KeychainManager.shared.loadAccessToken(),
              let expirationDate = getTokenExpirationDate(accessToken) else {
            Log.error("Cannot schedule token refresh: token or expiration date missing")
            return
        }

        // 만료 5분 전 시점 계산
        let refreshTime = expirationDate.addingTimeInterval(-refreshThresholdMinutes)
        let timeUntilRefresh = refreshTime.timeIntervalSinceNow

        // 이미 만료 시간이 지났거나 5분 이내라면 즉시 갱신
        if timeUntilRefresh <= 0 {
            Log.info("Token expires soon or already expired, refreshing immediately")
            Task {
                await performTokenRefresh()
            }
            return
        }

        // 정확한 시간에 갱신하도록 타이머 설정
        refreshTimer = Timer.scheduledTimer(withTimeInterval: timeUntilRefresh, repeats: false) { [weak self] _ in
            Task {
                await self?.performTokenRefresh()
            }
        }

        let refreshDate = Date().addingTimeInterval(timeUntilRefresh)
        Log.info("Token refresh scheduled for: \(refreshDate) (in \(timeUntilRefresh/60) minutes)")
    }

    // MARK: - 토큰 갱신 체크 중지
    public func stopTokenRefreshCheck() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        Log.info("Token refresh check stopped")
    }

    // MARK: - 토큰 갱신 수행
    private func performTokenRefresh() async {
        Log.info("Scheduled token refresh triggered")

        let success = await refreshTokenIfNeeded()

        if success {
            // 갱신 성공시 다음 갱신 스케줄 설정
            scheduleTokenRefreshCheck()
        } else {
            Log.error("Token refresh failed, stopping scheduled checks")
        }
    }

    // MARK: - 앱 시작 시 초기화
    public func initializeTokenManagement() async {
        Log.info("Initializing token management system...")

        // 1. 현재 토큰 상태 확인
        let status = getCurrentTokenStatus()
        Log.info("Current token status: \(status)")

        // 2. 토큰 상태에 따른 처리
        switch status {
        case .valid:
            Log.info("Token is valid, scheduling smart refresh check")
            scheduleTokenRefreshCheck()

        case .expiringSoon:
            Log.info("Token expiring soon, attempting refresh...")
            let success = await refreshTokenIfNeeded()
            if success {
                scheduleTokenRefreshCheck()
            } else {
                Log.error("Failed to refresh token on startup")
            }

        case .missing:
            Log.error("No token found on startup")
            // 로그인 화면으로 이동 등의 처리는 앱 레벨에서 처리
        }
    }

    // MARK: - 시스템 종료 시 정리
    public func cleanup() {
        stopTokenRefreshCheck()
        Log.info("Token management system cleaned up")
    }

    // MARK: - API 호출 전 토큰 체크
    public func ensureValidTokenBeforeAPICall() async -> Bool {
        let status = getCurrentTokenStatus()

        switch status {
        case .valid:
            return true

        case .expiringSoon:
            Log.info("Token expiring soon, refreshing before API call...")
            let success = await refreshTokenIfNeeded()
            if success {
                // 토큰 갱신 성공 시 다음 스케줄 설정
                scheduleTokenRefreshCheck()
            }
            return success

        case .missing:
            Log.error("No token available for API call")
            return false
        }
    }

    // MARK: - JWT 토큰 디코딩
    public func decodeJWT(_ token: String) -> [String: Any]? {
        let components = token.components(separatedBy: ".")
        guard components.count == 3 else {
            Log.error("Invalid JWT format")
            return nil
        }

        let payload = components[1]
        var base64 = payload
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Base64 패딩 추가
        let paddingLength = 4 - (base64.count % 4)
        if paddingLength < 4 {
            base64 += String(repeating: "=", count: paddingLength)
        }

        guard let data = Data(base64Encoded: base64) else {
            Log.error("Failed to decode base64")
            return nil
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json
        } catch {
            Log.error("Failed to parse JSON: \(error)")
            return nil
        }
    }

    // MARK: - 토큰 만료 시간 확인
    public func getTokenExpirationDate(_ token: String) -> Date? {
        guard let payload = decodeJWT(token),
              let exp = payload["exp"] as? TimeInterval else {
            Log.error("Cannot extract expiration time from token")
            return nil
        }

        return Date(timeIntervalSince1970: exp)
    }

    // MARK: - 토큰이 곧 만료되는지 확인
    public func isTokenExpiringSoon(_ token: String) -> Bool {
        guard let expirationDate = getTokenExpirationDate(token) else {
            return true // 만료 시간을 알 수 없으면 갱신 필요
        }

        let timeUntilExpiration = expirationDate.timeIntervalSinceNow
        return timeUntilExpiration <= refreshThresholdMinutes
    }

    // MARK: - 현재 저장된 토큰 상태 확인
    public func getCurrentTokenStatus() -> TokenStatus {
        guard let accessToken = KeychainManager.shared.loadAccessToken(),
              !accessToken.isEmpty else {
            return .missing
        }

        if isTokenExpiringSoon(accessToken) {
            return .expiringSoon
        }

        return .valid
    }

    // MARK: - 토큰 유효성 검사
    public func validateCurrentToken() async -> Bool {
        let status = getCurrentTokenStatus()

        switch status {
        case .valid:
            Log.info("Token is valid")
            return true

        case .expiringSoon:
            Log.info("Token is expiring soon, attempting refresh...")
            let success = await refreshTokenIfNeeded()
            if success {
                // 토큰 갱신 성공 시 다음 스케줄 설정
                scheduleTokenRefreshCheck()
            }
            return success

        case .missing:
            Log.error("Token is missing")
            return false
        }
    }

    // MARK: - AuthInterceptor용 토큰 갱신 (RetryResult 반환)
    public func refreshTokenForRetry() async -> RetryResult {
        return await performTokenRefreshWithRetry(maxRetries: 3)
    }

    // MARK: - 지연 재시도 로직이 포함된 토큰 갱신
    private func performTokenRefreshWithRetry(maxRetries: Int) async -> RetryResult {
        let authRepository = RequestInterceptorManger.shared

        for attempt in 1...maxRetries {
            Log.info("Token refresh attempt \(attempt)/\(maxRetries)")

            let result = await authRepository.refreshToken()

            switch result {
            case .retry:
                Log.info("Token refresh succeeded on attempt \(attempt)")
                scheduleTokenRefreshCheck()
                return .retry

            case .retryWithDelay(let delay):
                if attempt < maxRetries {
                    Log.info("Token refresh requires delay: \(delay)s, retrying in \(delay) seconds (attempt \(attempt)/\(maxRetries))")

                    // 지연 시간만큼 대기
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                    // 다음 루프 iteration에서 재시도
                    continue
                } else {
                    Log.error("Token refresh max retries exceeded with delay, giving up")
                    return .doNotRetry
                }

            case .doNotRetry:
                Log.error("Token refresh failed: do not retry")
                return .doNotRetry

            case .doNotRetryWithError(let error):
                Log.error("Token refresh failed with error: \(error)")
                return .doNotRetryWithError(error)

            @unknown default:
                Log.error("Unknown token refresh result")
                return .doNotRetry
            }
        }

        // 이론적으로는 여기에 도달하지 않아야 함
        return .doNotRetry
    }

    // MARK: - 필요시 토큰 갱신
    private func refreshTokenIfNeeded() async -> Bool {
        let result = await performTokenRefreshWithRetry(maxRetries: 3)

        switch result {
        case .retry:
            return true
        case .doNotRetry, .doNotRetryWithError(_), .retryWithDelay(_):
            return false
        @unknown default:
            return false
        }
    }
}


