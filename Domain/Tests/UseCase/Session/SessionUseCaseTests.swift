//
//  SessionUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 12/02/25.
//

import Testing
import Foundation
@testable import Domain
import Dependencies

@Suite("Session UseCase Tests", .serialized, .tags(.unit, .useCase))
struct SessionUseCaseTests {

    @Test("세션 체크 성공 - 기본 mock")
    func testCheckSessionSuccess() async throws {
        // Given
        let repo = MockSessionRepository.success
        let useCase = SessionUseCase(repository: repo)

        // When
        let result: Domain.SessionResult = try await useCase.checkSession(sessionId: "session-123")

        // Then
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.sessionId == "session-123")
        #expect(result.status == "active")
    }

    @Test("세션 체크 실패 시 에러 전달")
    func testCheckSessionFailure() async throws {
        // Given
        let repo = MockSessionRepository.failure
        let useCase = SessionUseCase(repository: repo)

        // When & Then
        await #expect(throws: MockSessionError.self) {
            _ = try await useCase.checkSession(sessionId: "invalid-session")
        }
    }

    @Test("커스텀 세션 반환")
    func testCheckSessionWithCustomSession() async throws {
        // Given
        let custom: Domain.SessionResult = .init(
            provider: Domain.SocialType.google,
            sessionId: "custom-session",
            status: "expired"
        )
        let repo = MockSessionRepository.withSession(custom)
        let useCase = SessionUseCase(repository: repo)

        // When
        let result = try await useCase.checkSession(sessionId: "")

        // Then
        #expect(result.provider == .google)
        #expect(result.sessionId == "custom-session")
        #expect(result.status == "expired")
    }

    @Test("세션 체크 지연 처리")
    func testCheckSessionWithDelay() async throws {
        // Given
        let repo = MockSessionRepository.withDelay(0.5)
        let useCase = SessionUseCase(repository: repo)
        let start = Date()

        // When
        let result = try await useCase.checkSession(sessionId: "delayed-session")

        // Then
        let elapsed = Date().timeIntervalSince(start)
        #expect(elapsed >= 0.5)
        #expect(result.sessionId == "delayed-session")
        #expect(result.provider == Domain.SocialType.apple)
    }

    @Test("Dependencies 를 통한 SessionUseCase 주입")
    func testSessionUseCaseWithDependencies() async throws {
        // Given
        let repo = MockSessionRepository.withSession(
            Domain.SessionResult(provider: Domain.SocialType.google, sessionId: "dep-session", status: "active")
        )

        // When
        let result = try await withDependencies {
            $0.sessionUseCase = SessionUseCase(repository: repo)
        } operation: {
            try await SessionUseCaseDependencyConsumer().run(sessionId: "dep-session")
        }

        // Then
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.sessionId == "dep-session")
        #expect(result.status == "active")
    }
}

private struct SessionUseCaseDependencyConsumer {
    @Dependency(\.sessionUseCase) var sessionUseCase

    func run(sessionId: String) async throws -> SessionResult {
        try await sessionUseCase.checkSession(sessionId: sessionId)
    }
}
