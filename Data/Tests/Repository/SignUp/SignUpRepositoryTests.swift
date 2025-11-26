//
//  SignUpRepositoryTests.swift
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

@Suite("SignUp Repository Tests", .serialized, .tags(.repository, .unit))
struct SignUpRepositoryTests {

    // MARK: - TDD: 등록 상태 조회

    @Test("구글 사용자 등록 상태가 true를 반환한다")
    func testSignUpRepository_ReturnsRegisteredTrue() async throws {
        // Given
        let provider = stubProvider(registered: true)
        let repository = SignUpRepository(provider: provider)

        // When
        let result = try await repository.checkSignUpUser(
            input: Domain.OAuthUserInput(
                accessToken: "test-token",
                socialType: Domain.SocialType.google,
                authorizationCode: "test-auth-code"
            )
        )

        // Then
        #expect(result.registered == true)
    }

    @Test("애플 사용자 등록 상태가 false를 반환한다")
    func testSignUpRepository_ReturnsRegisteredFalseForApple() async throws {
        // Given
        let provider = stubProvider(registered: false)
        let repository = SignUpRepository(provider: provider)

        // When
        let result = try await repository.checkSignUpUser(
            input: Domain.OAuthUserInput(
                accessToken: "apple-token",
                socialType: Domain.SocialType.apple,
                authorizationCode: "apple-auth-code"
            )
        )

        // Then
        #expect(result.registered == false)
    }

    @Test("서버 에러 시 NetworkError를 전달한다")
    func testSignUpRepository_PropagatesServerError() async throws {
        // Given
        let provider = stubProvider(registered: false, statusCode: 500)
        let repository = SignUpRepository(provider: provider)

        // When & Then
        await #expect(throws: NetworkError.self) {
            _ = try await repository.checkSignUpUser(
                input: Domain.OAuthUserInput(
                    accessToken: "invalid-token",
                    socialType: Domain.SocialType.google,
                    authorizationCode: "invalid-auth-code"
                )
            )
        }
    }

    // MARK: - TDD: 회원가입

    @Test("Google 회원가입이 성공적으로 AuthEntity를 반환한다")
    func testSignUpRepository_SuccessfulGoogleSignUp() async throws {
        // Given
        let provider = stubProviderForSignUp(socialType: "google", statusCode: 200)
        let repository = SignUpRepository(provider: provider)

        // When
        let result = try await repository.signUpUser(
            input: Domain.OAuthUserInput(
                accessToken: "google-signup-token",
                socialType: Domain.SocialType.google,
                authorizationCode: "google-auth-code"
            )
        )

        // Then
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.name == "New Google User")
        #expect(result.token.accessToken == "signup-access-token")
    }

    @Test("Apple 회원가입이 성공적으로 AuthEntity를 반환한다")
    func testSignUpRepository_SuccessfulAppleSignUp() async throws {
        // Given
        let provider = stubProviderForSignUp(socialType: "apple", statusCode: 200)
        let repository = SignUpRepository(provider: provider)

        // When
        let result = try await repository.signUpUser(
            input: Domain.OAuthUserInput(
                accessToken: "apple-signup-token",
                socialType: Domain.SocialType.apple,
                authorizationCode: "apple-auth-code"
            )
        )

        // Then
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.name == "New Apple User")
        #expect(result.token.accessToken == "signup-access-token")
    }

    @Test("회원가입 실패 시 NetworkError를 전달한다")
    func testSignUpRepository_SignUpFailure() async throws {
        // Given
        let provider = stubProviderForSignUp(socialType: "google", statusCode: 400)
        let repository = SignUpRepository(provider: provider)

        // When & Then
        await #expect(throws: NetworkError.self) {
            _ = try await repository.signUpUser(
                input: Domain.OAuthUserInput(
                    accessToken: "invalid-token",
                    socialType: Domain.SocialType.google,
                    authorizationCode: "invalid-auth-code"
                )
            )
        }
    }
}

// MARK: - Stubs

private func stubProvider(
    registered: Bool,
    statusCode: Int = 200
) -> MoyaProvider<OAuthAPITarget> {
    let endpointClosure = { (target: OAuthAPITarget) -> Endpoint in
        let responseBody: [String: Any]

        if statusCode < 400 {
            responseBody = [
                "code": statusCode,
                "data": ["registered": registered],
                "message": "success",
                "meta": NSNull()
            ]
        } else {
            responseBody = [
                "code": statusCode,
                "message": "error",
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

private func stubProviderForSignUp(
    socialType: String,
    statusCode: Int
) -> MoyaProvider<OAuthAPITarget> {
    let endpointClosure = { (target: OAuthAPITarget) -> Endpoint in
        let responseBody: [String: Any]

        if statusCode < 400 {
            responseBody = [
                "code": statusCode,
                "data": [
                    "user": [
                        "id": "signup-user-id",
                        "email": "signup@example.com",
                        "name": "New \(socialType.capitalized) User",
                        "role": "user",
                        "createdAt": "2025-11-26T12:00:00Z",
                        "userId": "signup-user-id"
                    ],
                    "accessToken": "signup-access-token",
                    "refreshToken": "signup-refresh-token",
                    "accessTokenExpiresAt": "2025-11-27T12:00:00Z",
                    "refreshTokenExpiresAt": "2025-12-26T12:00:00Z",
                    "sessionId": "signup-session-id",
                    "sessionExpiresAt": "2025-11-27T12:00:00Z",
                    "lastLoginAt": "2025-11-26T12:00:00Z",
                    "loginType": socialType
                ],
                "message": "signup success",
                "meta": NSNull()
            ]
        } else {
            responseBody = [
                "code": statusCode,
                "message": "signup failed",
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
