//
//  OAuthIntegrationTests.swift
//  Domain
//
//  Created by Wonji Suh on 11/26/25.
//

import Testing
import Foundation
@testable import Domain
import LogMacro

@Suite("OAuth Integration Tests", .serialized, .tags(.integration))
struct OAuthIntegrationTests {

    // MARK: - Tests

    @Test("기본 Google 로그인 플로우")
    func testBasicGoogleSignInFlow() async throws {
        // Given
        let oAuthUseCase = OAuthUseCase(
            repository: MockOAuthRepository(),
            googleRepository: MockGoogleOAuthRepository(),
            appleRepository: MockAppleOAuthRepository(),
            kakaoRepository: MockKakaoOAuthRepository()
        )

        // When
        let result = try await oAuthUseCase.signUp(with: Domain.SocialType.google)

        // Then - 기본 요구사항만 검증
        #expect(result.provider == Domain.SocialType.google)
        #expect(result.email?.isEmpty == false)
        #expect(result.displayName == "Mock Google User")
    }

    @Test("기본 Apple 로그인 플로우")
    func testBasicAppleSignInFlow() async throws {
        // Given
        let oAuthUseCase = OAuthUseCase(
            repository: MockOAuthRepository(),
            googleRepository: MockGoogleOAuthRepository(),
            appleRepository: MockAppleOAuthRepository(),
            kakaoRepository: MockKakaoOAuthRepository()
        )

        // When
        let result = try await oAuthUseCase.signUp(with: Domain.SocialType.apple)

        // Then - 기본 요구사항만 검증
        #expect(result.provider == Domain.SocialType.apple)
        #expect(result.email?.isEmpty == false)
        #expect(result.displayName == "Mock Apple User")
    }

    @Test("Google Repository Actor 테스트")
    func testGoogleRepositoryActor() async throws {
        // Given
        let mockRepo = MockGoogleOAuthRepository()

        // When
        let result = try await mockRepo.signIn()

        // Then
        #expect(result.displayName == "Mock Google User")
        #expect(result.idToken.contains("mock.google.idtoken"))
        #expect(result.accessToken?.contains("ya29.mock-google-access-token") ?? false)
    }

    @Test("Apple Repository Actor 테스트")
    func testAppleRepositoryActor() async throws {
        // Given
        let mockRepo = MockAppleOAuthRepository()

        // When
        let result = try await mockRepo.signIn()

        // Then
        #expect(result.displayName == "Mock Apple User")
        #expect(result.idToken.contains("eyJhbGciOiJSUzI1NiIsImtpZCI6Im1vY2sta2lkIn0"))
        #expect(result.nonce.contains("mock-apple-nonce"))
    }

    @Test("성능 최적화 테스트")
    func testPerformanceOptimization() async throws {
        // Given
        let oAuthUseCase = OAuthUseCase(
            repository: MockOAuthRepository(),
            googleRepository: MockGoogleOAuthRepository(),
            appleRepository: MockAppleOAuthRepository(),
            kakaoRepository: MockKakaoOAuthRepository()
        )
        let startTime = Date()

        // When
        let _ = try await oAuthUseCase.signUp(with: Domain.SocialType.google)

        // Then - 성능 요구사항 검증 (2초 이내로 완화)
        let duration = Date().timeIntervalSince(startTime)
        #expect(duration < 2.0, "OAuth flow should complete within 2 seconds")
    }

    // MARK: - 시나리오 테스트

    @Test("사용자가 Google로 로그인할 때")
    func testScenario_WhenUserSignsInWithGoogle() async throws {
        try await runScenario(
            given: "사용자가 Google 계정을 가지고 있고",
            when: "Google 로그인을 시도하면",
            then: "성공적으로 로그인되어야 한다"
        ) {
            // Given
            let oAuthUseCase = OAuthUseCase(
                repository: MockOAuthRepository(),
                googleRepository: MockGoogleOAuthRepository(),
                appleRepository: MockAppleOAuthRepository(),
                kakaoRepository: MockKakaoOAuthRepository()
            )

            // When
            let result = try await oAuthUseCase.signUp(with: Domain.SocialType.google)

            // Then
            #expect(result.provider == Domain.SocialType.google)
            #expect(result.displayName == "Mock Google User")
        }
    }

    @Test("Apple 로그인 성공 시나리오")
    func testScenario_WhenAppleSignInSucceeds() async throws {
        try await runScenario(
            given: "사용자가 Apple ID를 가지고 있고",
            when: "Apple 로그인을 시도하면",
            then: "성공적으로 로그인되어야 한다"
        ) {
            // Given
            let mockRepo = MockAppleOAuthRepository.customUser("Apple 사용자")

            // When
            let result = try await mockRepo.signIn()

            // Then
            #expect(result.displayName == "Apple 사용자")
            #expect(!result.idToken.isEmpty)
        }
    }

    @Test("SignUp Repository 시나리오")
    func testScenario_SignUpRepository() async throws {
        try await runScenario(
            given: "사용자의 등록 상태를 확인하고자 하고",
            when: "등록 확인 요청을 하면",
            then: "올바른 등록 상태가 반환되어야 한다"
        ) {
            // Given
            let mockRepo = MockSignUpRepository()

            // When
            let result = try await mockRepo.checkSignUp(
                input: OAuthUserInput(
                    accessToken: "test-token",
                    socialType: Domain.SocialType.google,
                    authorizationCode: "test-auth-code"
                )
            )

            // Then
            #expect(result.registered == true)
        }
    }

    // MARK: - Helpers

    private func runScenario(
        given: String,
        when: String,
        then: String,
        test: () async throws -> Void
    ) async rethrows {
      Log.test("Given: \(given)")
      Log.test("When: \(when)")
      Log.test("Then: \(then)")

        do {
            try await test()
          Log.test("✅ Scenario passed")
        } catch {
          Log.test("❌ Scenario failed: \(error)")
            throw error
        }
    }
}
