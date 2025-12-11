//
//  AuthRepositoryTests.swift
//  Data
//
//  Created by Wonji Suh on 12/11/25.
//

import Foundation
import Testing
import Domain
import Moya
import NetworkService
@testable import Data

@Suite("AuthRepository 통합 테스트", .serialized, .tags(.repository, .unit))
struct AuthRepositoryTests {

    // MARK: - Refresh
    @Test("refresh 호출 시 토큰 결과를 반환한다")
    func testRefresh() async throws {
        let provider = stubAuthProviderForRefresh(statusCode: 200)
        let sut = AuthRepository(provider: provider,
                                 loginRepository: StubLoginRepository(),
                                 signUpRepository: StubSignUpRepository(),
                                 kakaoFinalizeRepository: StubKakaoFinalizeRepository())

        let result = try await sut.refresh(token: "refresh-token")

        #expect(result.token.accessToken == "new-access-token")
        #expect(result.token.refreshToken == "new-refresh-token")
        #expect(result.token.sessionID == "session-123")
    }

    // MARK: - Device Token
    @Test("registerDeviceToken 호출 시 pendingKey를 반환한다")
    func testRegisterDeviceToken() async throws {
        let provider = stubAuthProviderForDeviceToken(statusCode: 200)
        let sut = AuthRepository(provider: provider,
                                 loginRepository: StubLoginRepository(),
                                 signUpRepository: StubSignUpRepository(),
                                 kakaoFinalizeRepository: StubKakaoFinalizeRepository())

        let result = try await sut.registerDeviceToken(token: "device-token")

        #expect(result.deviceToken == "device-token")
        #expect(result.pendingKey == "pending-123")
    }

    // MARK: - Delegation
    @Test("checkUser는 SignUpRepository로 위임된다")
    func testCheckUserDelegatesToSignUpRepository() async throws {
        let signUpRepo = StubSignUpRepository()
        let sut = AuthRepository(provider: stubNoopProvider(),
                                 loginRepository: StubLoginRepository(),
                                 signUpRepository: signUpRepo,
                                 kakaoFinalizeRepository: StubKakaoFinalizeRepository())

        _ = try await sut.checkUser(input: OAuthUserInput(accessToken: "acc", socialType: .google, authorizationCode: "code"))
        #expect(signUpRepo.didCallCheckUser == true)
    }

    @Test("login은 LoginRepository로 위임된다")
    func testLoginDelegatesToLoginRepository() async throws {
        let loginRepo = StubLoginRepository()
        let sut = AuthRepository(provider: stubNoopProvider(),
                                 loginRepository: loginRepo,
                                 signUpRepository: StubSignUpRepository(),
                                 kakaoFinalizeRepository: StubKakaoFinalizeRepository())

        _ = try await sut.login(input: OAuthUserInput(accessToken: "acc", socialType: .google, authorizationCode: "code"))
        #expect(loginRepo.didCallLogin == true)
    }

    @Test("signUp은 SignUpRepository로 위임된다")
    func testSignUpDelegatesToSignUpRepository() async throws {
        let signUpRepo = StubSignUpRepository()
        let sut = AuthRepository(provider: stubNoopProvider(),
                                 loginRepository: StubLoginRepository(),
                                 signUpRepository: signUpRepo,
                                 kakaoFinalizeRepository: StubKakaoFinalizeRepository())

        _ = try await sut.signUp(input: OAuthUserInput(accessToken: "acc", socialType: .google, authorizationCode: "code"))
        #expect(signUpRepo.didCallSignUp == true)
    }

    @Test("finalizeKakao는 KakaoFinalizeRepository로 위임된다")
    func testFinalizeKakaoDelegates() async throws {
        let finalizeRepo = StubKakaoFinalizeRepository()
        let sut = AuthRepository(provider: stubNoopProvider(),
                                 loginRepository: StubLoginRepository(),
                                 signUpRepository: StubSignUpRepository(),
                                 kakaoFinalizeRepository: finalizeRepo)

        _ = try await sut.finalizeKakao(ticket: "ticket")
        #expect(finalizeRepo.didCallFinalize == true)
    }
}

// MARK: - Stubs
private func stubAuthProviderForRefresh(statusCode: Int) -> MoyaProvider<AuthAPITarget> {
    let endpointClosure = { (target: AuthAPITarget) -> Endpoint in
        let responseBody: [String: Any] = [
            "code": statusCode,
            "data": [
                "accessToken": "new-access-token",
                "refreshToken": "new-refresh-token",
                "accessTokenExpiresAt": "2025-11-27T12:00:00Z",
                "refreshTokenExpiresAt": "2025-12-27T12:00:00Z",
                "sessionId": "session-123",
                "sessionExpiresAt": "2025-11-27T12:00:00Z",
                "loginType": "google"
            ],
            "message": "success",
            "meta": NSNull()
        ]
        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        let url = target.baseURL.appendingPathComponent(target.path)
        let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: target.headers)!
        return Endpoint(
            url: url.absoluteString,
            sampleResponseClosure: { .response(httpResponse, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    return MoyaProvider<AuthAPITarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
}

private func stubAuthProviderForDeviceToken(statusCode: Int) -> MoyaProvider<AuthAPITarget> {
    let endpointClosure = { (target: AuthAPITarget) -> Endpoint in
        let responseBody: [String: Any] = [
            "code": statusCode,
            "data": [
                "deviceToken": "device-token",
                "pendingKey": "pending-123",
                "mode": "mock"
            ],
            "message": "success",
            "meta": NSNull()
        ]
        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        let url = target.baseURL.appendingPathComponent(target.path)
        let httpResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: target.headers)!
        return Endpoint(
            url: url.absoluteString,
            sampleResponseClosure: { .response(httpResponse, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    return MoyaProvider<AuthAPITarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
}

/// 사용되지 않는 네트워크 호출을 막기 위한 no-op 스텁
private func stubNoopProvider() -> MoyaProvider<AuthAPITarget> {
    let endpointClosure = { (target: AuthAPITarget) -> Endpoint in
        let responseBody: [String: Any] = [
            "code": 200,
            "data": NSNull(),
            "message": "noop",
            "meta": NSNull()
        ]
        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        return Endpoint(
            url: target.baseURL.appendingPathComponent(target.path).absoluteString,
            sampleResponseClosure: { .networkResponse(200, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    return MoyaProvider<AuthAPITarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
}

// MARK: - Stub Repos
private final class StubLoginRepository: LoginRepositoryProtocol {
    var didCallLogin = false
    func login(input: OAuthUserInput) async throws -> AuthResult {
        didCallLogin = true
        return AuthResult(
            userId: "user",
            name: "name",
            provider: input.socialType,
            token: AuthTokens(authToken: "", accessToken: input.accessToken, refreshToken: "ref", sessionID: "session")
        )
    }
}

private final class StubSignUpRepository: SignUpRepositoryProtocol {
    var didCallCheckUser = false
    var didCallSignUp = false

    func checkSignUp(input: OAuthUserInput) async throws -> OAuthCheckUser {
        didCallCheckUser = true
        return OAuthCheckUser(registered: false, needsTerms: true)
    }

    func signUp(input: OAuthUserInput) async throws -> AuthResult {
        didCallSignUp = true
        return AuthResult(
            userId: "new-user",
            name: "new",
            provider: input.socialType,
            token: AuthTokens(authToken: "", accessToken: input.accessToken, refreshToken: "ref", sessionID: "session")
        )
    }
}

private final class StubKakaoFinalizeRepository: KakaoFinalizeRepositoryProtocol {
    var didCallFinalize = false
    func finalize(ticket: String) async throws -> AuthResult {
        didCallFinalize = true
        return AuthResult(
            userId: "kakao-user",
            name: "kakao",
            provider: .kakao,
            token: AuthTokens(authToken: "", accessToken: "kakao-access", refreshToken: "kakao-refresh", sessionID: "kakao-session")
        )
    }
}
