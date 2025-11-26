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
            input: Domain.OAuthCheckUserInput(
                accessToken: "test-token",
                socialType: Domain.SocialType.google
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
            input: Domain.OAuthCheckUserInput(
                accessToken: "apple-token",
                socialType: Domain.SocialType.apple
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
                input: Domain.OAuthCheckUserInput(
                    accessToken: "invalid-token",
                    socialType: Domain.SocialType.google
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
