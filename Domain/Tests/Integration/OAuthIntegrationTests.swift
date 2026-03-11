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

@Suite("OAuth Integration Tests", .serialized, .tags(.integration, .auth))
struct OAuthIntegrationTests {

    // MARK: - UseCase Tests (Known Issues - Refactored to TCA Dependencies)

    @Test("기본 Google 로그인 플로우",
          .disabled("Known Issue: OAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testBasicGoogleSignInFlow() async throws {
        /*
        ┌─────────────────────────────────────────────────────┐
        │ 리팩토링 내역                                        │
        ├─────────────────────────────────────────────────────┤
        │ - OAuthUseCase가 @Dependency로 repository 주입      │
        │ - init()이 파라미터를 받지 않음                      │
        ├─────────────────────────────────────────────────────┤
        │ 수정 필요                                           │
        │ - withDependencies 클로저로 Mock 주입               │
        └─────────────────────────────────────────────────────┘
        */
    }

    @Test("기본 Apple 로그인 플로우",
          .disabled("Known Issue: OAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testBasicAppleSignInFlow() async throws {
        // TCA Dependencies로 리팩토링되어 직접 mock 주입 불가
    }

    // MARK: - Repository Actor Tests (독립 테스트 가능)

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

    @Test("성능 최적화 테스트",
          .disabled("Known Issue: OAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testPerformanceOptimization() async throws {
        // TCA Dependencies로 리팩토링되어 직접 mock 주입 불가
    }

    // MARK: - 시나리오 테스트 (Known Issues)

    @Test("사용자가 Google로 로그인할 때",
          .disabled("Known Issue: OAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testScenario_WhenUserSignsInWithGoogle() async throws {
        // TCA Dependencies로 리팩토링되어 직접 mock 주입 불가
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
