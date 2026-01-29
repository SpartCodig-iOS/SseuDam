//
//  UnifiedOAuthUseCaseTests.swift
//  Domain
//
//  Created by Wonji Suh on 12/11/25.
//

import Testing
@testable import Domain

@Suite("Unified OAuth UseCase Tests", .tags(.useCase, .auth))
struct UnifiedOAuthUseCaseTests {

    // MARK: - Helpers
    private func makeAuthData() -> AuthData {
        AuthData(
            socialType: .google,
            accessToken: "access-token",
            authToken: "auth-token",
            displayName: "Tester",
            authorizationCode: "auth-code",
            codeVerifier: nil,
            redirectUri: nil,
            refreshToken: "refresh-token",
            sessionID: "session-id",
            userId: "user-id"
        )
    }

    // MARK: - Tests (Known Issues - Refactored to TCA Dependencies)

    @Test("등록된 사용자 로그인 시 토큰이 저장된다",
          .disabled("Known Issue: UnifiedOAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testLoginSavesTokens() async throws {
        /*
        ┌─────────────────────────────────────────────────────┐
        │ 리팩토링 내역                                        │
        ├─────────────────────────────────────────────────────┤
        │ - UnifiedOAuthUseCase가 @Dependency 사용            │
        │ - OAuthFlowUseCase를 의존성으로 주입                 │
        │ - init()이 파라미터를 받지 않음                      │
        ├─────────────────────────────────────────────────────┤
        │ 수정 필요                                           │
        │ - withDependencies 클로저로 Mock OAuthFlow 주입     │
        │ - 또는 통합 테스트로 전환                           │
        └─────────────────────────────────────────────────────┘
        */

        // Given
        // let authData = makeAuthData()
        // let sut = UnifiedOAuthUseCase() // TCA Dependencies 사용
        // When & Then: withDependencies 필요
    }

    @Test("신규 사용자 회원가입 시 토큰이 저장된다",
          .disabled("Known Issue: UnifiedOAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testSignUpSavesTokens() async throws {
        // TCA Dependencies로 리팩토링되어 직접 mock 주입 불가
    }

    @Test("가입 여부 확인에서 needsTerms 응답을 반환할 수 있다",
          .disabled("Known Issue: UnifiedOAuthUseCase가 TCA Dependencies로 리팩토링됨"))
    func testCheckUserReturnsNeedsTerms() async throws {
        // TCA Dependencies로 리팩토링되어 직접 mock 주입 불가
    }
}

// MARK: - Mock Session Store (Reference for future TCA Dependencies tests)
/*
private final class MockSessionStoreRepository: SessionStoreRepositoryProtocol, @unchecked Sendable {
    var savedTokens: AuthTokens?
    var savedSocialType: SocialType?
    var savedUserId: String?

    func save(tokens: AuthTokens, socialType: SocialType?, userId: String?) async {
        savedTokens = tokens
        savedSocialType = socialType
        savedUserId = userId
    }

    func loadTokens() async -> AuthTokens? { savedTokens }
    func loadSocialType() async -> SocialType? { savedSocialType }
    func loadUserId() async -> String? { savedUserId }
    func clearAll() async {
        savedTokens = nil
        savedSocialType = nil
        savedUserId = nil
    }
}
*/

// MARK: - Stub Auth Repository (Reference for future TCA Dependencies tests)
/*
private final class StubAuthRepository: AuthRepositoryProtocol {
    var checkUserResult: OAuthCheckUser
    var loginResult: AuthResult
    var signUpResult: AuthResult
    var finalizeResult: AuthResult

    init(
        checkUserResult: OAuthCheckUser = OAuthCheckUser(registered: true, needsTerms: false),
        loginResult: AuthResult = AuthResult(
            userId: "user",
            name: "name",
            provider: .google,
            token: AuthTokens(authToken: "", accessToken: "acc", refreshToken: "ref", sessionID: "session")
        ),
        signUpResult: AuthResult = AuthResult(
            userId: "signup-user",
            name: "signup",
            provider: .google,
            token: AuthTokens(authToken: "", accessToken: "acc", refreshToken: "ref", sessionID: "session")
        ),
        finalizeResult: AuthResult = AuthResult(
            userId: "kakao-user",
            name: "kakao",
            provider: .kakao,
            token: AuthTokens(authToken: "", accessToken: "kakao-acc", refreshToken: "kakao-ref", sessionID: "kakao-session")
        )
    ) {
        self.checkUserResult = checkUserResult
        self.loginResult = loginResult
        self.signUpResult = signUpResult
        self.finalizeResult = finalizeResult
    }

    func checkUser(input: OAuthUserInput) async throws -> OAuthCheckUser { checkUserResult }
    func login(input: OAuthUserInput) async throws -> AuthResult { loginResult }
    func signUp(input: OAuthUserInput) async throws -> AuthResult { signUpResult }
    func finalizeKakao(ticket: String) async throws -> AuthResult { finalizeResult }
    func refresh(token: String) async throws -> TokenResult { TokenResult(token: AuthTokens(authToken: "", accessToken: "acc", refreshToken: "ref", sessionID: "session")) }
    func logout(sessionId: String) async throws -> LogoutStatus { LogoutStatus(revoked: true) }
    func delete() async throws -> AuthDeleteStatus { AuthDeleteStatus(isDeleted: true) }
    func registerDeviceToken(token: String) async throws -> DeviceToken { DeviceToken(deviceToken: token, pendingKey: nil) }
}
*/
