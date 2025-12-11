//
//  SessionRepositoryTests.swift
//  Data
//
//  Created by Wonji Suh on 12/02/25.
//

import Testing
import Foundation
import Moya
import Domain
import NetworkService
@testable import Data

@Suite("Session Repository Tests", .serialized, .tags(.repository, .unit))
struct SessionRepositoryTests {

    // MARK: - Target 구성 검증

    @Test("checkSession 타깃이 올바른 경로, 메서드, 파라미터를 사용한다")
    func testSessionAPITargetConfiguration() throws {
        // Given
        let body = SessionRequestDTO(sessionId: "session-123")
        let target = SessionAPITarget.checkSession(body: body)

        // Then
        #expect(target.urlPath == SessionAPI.checkSessionLogin.description)
        #expect(target.method == Moya.Method.get)
      let params = (target.parameters) ?? [:]
      #expect(params["sessionId"] as? String == "session-123")
    }

    // MARK: - Repository 동작 검증 (stubbed)

    @Test("세션 조회 성공 시 Domain.SessionStatus를 반환한다")
    func testSessionRepositorySuccess() async throws {
        // Given
        let sampleData = try makeResponseData(
            sessionId: "session-abc",
            loginType: "google",
            status: "active",
            isActive: true,
            supabaseSessionValid: true
        )
        let provider = makeStubProvider(data: sampleData)
        let repository = SessionRepository(provider: provider)

        // When
        let result = try await repository.checkSession(sessionId: "session-abc")

        // Then
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.sessionId == "session-abc")
        #expect(result.status == "active")
    }

    @Test("data 가 없으면 NetworkError.noData를 던진다")
    func testSessionRepositoryNoDataFailure() async throws {
        // Given
        let emptyData = try makeEmptyResponseData()
        let provider = makeStubProvider(data: emptyData)
        let repository = SessionRepository(provider: provider)

        // When & Then
        await #expect(throws: NetworkError.self) {
            _ = try await repository.checkSession(sessionId: "missing")
        }
    }
}

// MARK: - Helpers

private func makeStubProvider(
    data: Data,
    statusCode: Int = 200
) -> MoyaProvider<SessionAPITarget> {
    let endpointClosure = { (target: SessionAPITarget) -> Endpoint in
        let url = target.baseURL.appendingPathComponent(target.path)
        return Endpoint(
            url: url.absoluteString,
            sampleResponseClosure: {
                .response(
                    HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!,
                    data
                )
            },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }

    return MoyaProvider<SessionAPITarget>(
        endpointClosure: endpointClosure,
        stubClosure: MoyaProvider.immediatelyStub
    )
}

private func makeResponseData(
    sessionId: String,
    loginType: String,
    status: String,
    isActive: Bool,
    supabaseSessionValid: Bool
) throws -> Data {
    let payload: [String: Any] = [
        "code": 200,
        "message": "ok",
        "data": [
            "sessionId": sessionId,
            "userId": "user-\(sessionId)",
            "loginType": loginType,
            "createdAt": "2025-01-01T00:00:00Z",
            "lastSeenAt": "2025-01-02T00:00:00Z",
            "expiresAt": "2025-01-03T00:00:00Z",
            "status": status,
            "isActive": isActive,
            "supabaseSessionValid": supabaseSessionValid
        ],
        "meta": NSNull()
    ]

    return try JSONSerialization.data(withJSONObject: payload)
}

private func makeEmptyResponseData() throws -> Data {
    let payload: [String: Any] = [
        "code": 200,
        "message": "no data",
        "data": NSNull(),
        "meta": NSNull()
    ]

    return try JSONSerialization.data(withJSONObject: payload)
}
