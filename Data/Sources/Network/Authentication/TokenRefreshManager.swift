//
//  TokenRefreshManager.swift
//  Data
//
//  Created by Wonji Suh on 02/09/26.
//

import Foundation
import Alamofire
import Domain
import Moya

/// Actor-based token refresh manager for concurrency safety
/// Prevents multiple simultaneous token refresh attempts
actor TokenRefreshManager {
    private var isRefreshing = false
    private let remote: any AuthRemoteDataSourceProtocol

    init(remote: any AuthRemoteDataSourceProtocol = AuthRemoteDataSource(
        authProvider: MoyaProvider<AuthAPITarget>.default,
        oauthProvider: MoyaProvider<OAuthAPITarget>.default
    )) {
        self.remote = remote
    }

    /// Safely refreshes credential with concurrency protection
    /// If already refreshing, yields and retries
    func refreshCredentialIfNeeded(current credential: AccessTokenCredential) async throws -> AccessTokenCredential {
        // If already refreshing, yield and retry
        if isRefreshing {
            await _Concurrency.Task.yield()
            return try await refreshCredentialIfNeeded(current: credential)
        }

        // Set refreshing flag
        isRefreshing = true
        defer { isRefreshing = false }

        return try await performRefresh(credential)
    }

    /// Checks if error indicates refresh token expiration
    func isRefreshTokenExpiredError(_ error: Error) -> Bool {
        // 1. Check string description for "statusCodeError(401)"
        if String(describing: error).contains("statusCodeError(401)") {
            return true
        }

        // 2. Check Moya MoyaError.statusCode
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response) where response.statusCode == 401:
                return true
            case .underlying(_, let response) where response?.statusCode == 401:
                return true
            default:
                break
            }
        }

        // 3. Check AuthError.isTokenExpiredError
        if let authError = error as? AuthError {
            return authError.isTokenExpiredError
        }

        // 4. Check error message keywords
        let errorDesc = error.localizedDescription.lowercased()
        if errorDesc.contains("401") ||
           errorDesc.contains("unauthorized") ||
           errorDesc.contains("유효하지 않은 토큰") {
            return true
        }

        return false
    }
}

// MARK: - Private Methods
private extension TokenRefreshManager {
    func performRefresh(_ credential: AccessTokenCredential) async throws -> AccessTokenCredential {
        guard !credential.refreshToken.isEmpty else {
            throw TokenRefreshError.missingRefreshToken
        }

        do {
            let result = try await remote.refresh(token: credential.refreshToken)
            let tokens = result.token

            // Save to keychain
            KeychainManager.live.saveTokens(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken
            )

            // Update session manager credential
            await MainActor.run {
                AuthSessionManager.shared.updateCredential(
                    accessToken: tokens.accessToken,
                    refreshToken: tokens.refreshToken ?? ""
                )
            }

            guard let refreshedCredential = AccessTokenCredential.make(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken ?? ""
            ) else {
                throw TokenRefreshError.invalidAccessToken
            }

            return refreshedCredential

        } catch {
            // If refresh token is expired, perform automatic logout
            if isRefreshTokenExpiredError(error) {
                await performAutomaticLogout()
            }
            throw error
        }
    }

    func performAutomaticLogout() async {
        // 1. Clear keychain
        KeychainManager.live.clearAll()

        // 2. Clear session manager credential
        await MainActor.run {
            AuthSessionManager.shared.clear()
        }

        // 3. Send notification for automatic logout
        await MainActor.run {
            NotificationCenter.default.post(
                name: .refreshTokenExpired,
                object: nil,
                userInfo: ["reason": "401_refresh_failed"]
            )
        }
    }
}
