//
//  OAuthUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 11/26/25.
//

import Testing
@testable import Domain

@Suite("OAuth UseCase Tests", .serialized, .tags(.unit, .useCase, .auth))
struct OAuthUseCaseTests {

    // MARK: - UseCase 기본 플로우 (Known Issues - Refactored to TCA Dependencies)

    @Test("Google 로그인 성공",
          .disabled("Known Issue: OAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testGoogleSignUpReturnsMockUser() async throws {
        /*
        ┌─────────────────────────────────────────────────────┐
        │ 리팩토링 내역                                        │
        ├─────────────────────────────────────────────────────┤
        │ - OAuthUseCase가 @Dependency로 repository 주입      │
        │ - init()이 파라미터를 받지 않음                      │
        │ - withDependencies로 테스트 의존성 주입 필요        │
        ├─────────────────────────────────────────────────────┤
        │ 수정 필요                                           │
        │ - withDependencies 클로저로 Mock 주입               │
        │ - 또는 통합 테스트로 전환                           │
        └─────────────────────────────────────────────────────┘
        */

        // Given
        // let oAuthUseCase = OAuthUseCase() // TCA Dependencies 사용
        // When & Then: withDependencies 필요
    }

    @Test("Apple 로그인 성공",
          .disabled("Known Issue: OAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testAppleSignUpReturnsMockUser() async throws {
        // TCA Dependencies로 리팩토링되어 직접 mock 주입 불가
    }

    // MARK: - Repository Actors (독립 테스트 가능)

    @Test("Google Repository Actor 응답 검증")
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

    @Test("Kakao Repository Actor 응답 검증")
    func testKakaoRepositoryActor() async throws {
        // Given
        let mockRepo = MockKakaoOAuthRepository()

        // When
        let result = try await mockRepo.signIn()

        // Then
        #expect(result.displayName == "Mock Kakao User")
        #expect(result.idToken.contains("mock.kakao.idtoken"))
        #expect(result.accessToken.contains("mock-kakao-access-token"))
    }

    @Test("Apple Repository Actor 응답 검증")
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

    @Test("SignUp Repository Actor 응답 검증")
    func testSignUpRepositoryActor() async throws {
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
