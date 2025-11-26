//
//  LoginRepositoryTests.swift
//  Data
//
//  Created by Wonji Suh on 11/26/25.
//

import Testing
import Foundation
import Domain
import Moya
import NetworkService
@testable import Data

@Suite("Login Repository Tests", .serialized, .tags(.repository, .unit))
struct LoginRepositoryTests {

    // MARK: - TDD: 로그인 성공 케이스

    @Test("Google 로그인이 성공적으로 AuthEntity를 반환한다")
    func testLoginRepository_ReturnsAuthEntityForGoogle() async throws {
        // Given
        let provider = stubProvider(
            socialType: "google",
            statusCode: 200
        )
        let repository = LoginRepository(provider: provider)

        // When
        let result = try await repository.loginUser(
            input: Domain.OAuthUserInput(
                accessToken: "google-access-token",
                socialType: Domain.SocialType.google,
                authorizationCode: "google-auth-code"
            )
        )

        // Then
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.name == "Test Google User")
        #expect(result.token.accessToken == "mock-access-token")
        #expect(result.token.authToken == "")
    }

    @Test("Apple 로그인이 성공적으로 AuthEntity를 반환한다")
    func testLoginRepository_ReturnsAuthEntityForApple() async throws {
        // Given
        let provider = stubProvider(
            socialType: "apple",
            statusCode: 200
        )
        let repository = LoginRepository(provider: provider)

        // When
        let result = try await repository.loginUser(
            input: Domain.OAuthUserInput(
                accessToken: "apple-access-token",
                socialType: Domain.SocialType.apple,
                authorizationCode: "apple-auth-code"
            )
        )

        // Then
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.name == "Test Apple User")
        #expect(result.token.accessToken == "mock-access-token")
        #expect(result.token.authToken == "")
    }

    @Test("잘못된 액세스 토큰으로 401 에러를 반환한다")
    func testLoginRepository_Returns401ForInvalidToken() async throws {
        // Given
        let provider = stubProvider(
            socialType: "google",
            statusCode: 401
        )
        let repository = LoginRepository(provider: provider)

        // When & Then
        await #expect(throws: NetworkError.self) {
            _ = try await repository.loginUser(
                input: Domain.OAuthUserInput(
                    accessToken: "invalid-token",
                    socialType: Domain.SocialType.google,
                    authorizationCode: "test-auth-code"
                )
            )
        }
    }

    @Test("서버 에러 시 500 에러를 전달한다")
    func testLoginRepository_Returns500ForServerError() async throws {
        // Given
        let provider = stubProvider(
            socialType: "apple",
            statusCode: 500
        )
        let repository = LoginRepository(provider: provider)

        // When & Then
        await #expect(throws: NetworkError.self) {
            _ = try await repository.loginUser(
                input: Domain.OAuthUserInput(
                    accessToken: "test-token",
                    socialType: Domain.SocialType.apple,
                    authorizationCode: "test-auth-code"
                )
            )
        }
    }

    @Test("API 타겟이 올바른 로그인 경로를 사용한다")
    func testLoginRepository_UsesCorrectAPIPath() throws {
        // Given
        let body = OAuthLoginUserRequestDTO(accessToken: "test-token", loginType: "google")
        let target = OAuthAPITarget.loginOAuth(body: body)

        // Then
        #expect(target.urlPath.contains("login"))
        #expect(target.method == .post)
    }

    @Test("요청 바디가 올바르게 구성된다")
    func testLoginRepository_BuildsRequestBodyCorrectly() throws {
        // Given
        let body = OAuthLoginUserRequestDTO(accessToken: "token-123", loginType: "apple")
        let target = OAuthAPITarget.loginOAuth(body: body)

        // When
        let params = target.parameters as? [String: Any]

        // Then
        #expect(params?["accessToken"] as? String == "token-123")
        #expect(params?["loginType"] as? String == "apple")
    }

    // MARK: - 데이터 매핑 테스트

    @Test("응답 데이터가 AuthEntity로 올바르게 매핑된다")
    func testLoginRepository_MapsResponseToAuthEntity() async throws {
        // Given
        let provider = stubProvider(
            socialType: "google",
            statusCode: 200,
            customUserName: "Custom Test User"
        )
        let repository = LoginRepository(provider: provider)

        // When
        let result = try await repository.loginUser(
            input: Domain.OAuthUserInput(
                accessToken: "test-token",
                socialType: Domain.SocialType.google,
                authorizationCode: "test-auth-code"
            )
        )

        // Then
        #expect(result.name == "Custom Test User")
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.token.authToken == "")
        #expect(!result.token.sessionID.isEmpty)
    }
}

// MARK: - Stubs

private func stubProvider(
    socialType: String,
    statusCode: Int,
    customUserName: String? = nil
) -> MoyaProvider<OAuthAPITarget> {
    let endpointClosure = { (target: OAuthAPITarget) -> Endpoint in
        let responseBody: [String: Any]

        if statusCode < 400 {
            let userName = customUserName ?? "Test \(socialType.capitalized) User"
            responseBody = [
                "code": statusCode,
                "data": [
                    "user": [
                        "id": "mock-user-id",
                        "email": "mock@example.com",
                        "name": userName,
                        "role": "user",
                        "createdAt": "2025-11-26T12:00:00Z",
                        "userId": "mock-user-id"
                    ],
                    "accessToken": "mock-access-token",
                    "refreshToken": "mock-refresh-token",
                    "accessTokenExpiresAt": "2025-11-27T12:00:00Z",
                    "refreshTokenExpiresAt": "2025-12-26T12:00:00Z",
                    "sessionId": "mock-session-id",
                    "sessionExpiresAt": "2025-11-27T12:00:00Z",
                    "lastLoginAt": "2025-11-26T12:00:00Z",
                    "loginType": socialType
                ],
                "message": "success",
                "meta": NSNull()
            ]
        } else {
            responseBody = [
                "code": statusCode,
                "message": "Login failed",
                "meta": NSNull()
            ]
        }

        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        let url = target.baseURL.appendingPathComponent(target.path)
        let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: target.headers
        )!

        return Endpoint(
            url: url.absoluteString,
            sampleResponseClosure: { .response(httpResponse, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }

    return MoyaProvider<OAuthAPITarget>(
        endpointClosure: endpointClosure,
        stubClosure: MoyaProvider.immediatelyStub
    )
}