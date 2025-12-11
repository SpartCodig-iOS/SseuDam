//
//  AuthRemoteDataSourceTests.swift
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

@Suite("AuthRemoteDataSource Moya 요청/파라미터 검증", .serialized, .tags(.datasource, .unit))
struct AuthRemoteDataSourceTests {

    @Test("checkUser 요청이 올바른 바디로 인코딩된다")
    func testCheckUserParameters() async throws {
        let provider = stubOAuthProviderForCheckUser()
        let sut = AuthRemoteDataSource(authProvider: stubAuthNoop(), oauthProvider: provider)

        let input = OAuthUserInput(
            accessToken: "acc",
            socialType: .google,
            authorizationCode: "authCode",
            codeVerifier: "verifier",
            redirectUri: "redirect://uri"
        )

        _ = try await sut.checkUser(input: input)
    }

    @Test("login 요청이 올바른 바디로 인코딩된다")
    func testLoginParameters() async throws {
        let provider = stubOAuthProviderForLogin()
        let sut = AuthRemoteDataSource(authProvider: stubAuthNoop(), oauthProvider: provider)

        let input = OAuthUserInput(
            accessToken: "acc",
            socialType: .apple,
            authorizationCode: "authCode",
            codeVerifier: "verifier",
            redirectUri: "redirect://uri"
        )

        _ = try await sut.login(input: input)
    }

    @Test("signUp 요청이 올바른 바디로 인코딩된다")
    func testSignUpParameters() async throws {
        let provider = stubOAuthProviderForSignUp()
        let sut = AuthRemoteDataSource(authProvider: stubAuthNoop(), oauthProvider: provider)

        let input = OAuthUserInput(
            accessToken: "acc",
            socialType: .google,
            authorizationCode: "authCode",
            codeVerifier: "verifier",
            redirectUri: "redirect://uri"
        )

        _ = try await sut.signUp(input: input)
    }

    @Test("refresh 요청이 올바른 바디로 인코딩된다")
    func testRefreshParameters() async throws {
        let provider = stubAuthProviderForRefresh()
        let sut = AuthRemoteDataSource(authProvider: provider, oauthProvider: stubOAuthNoop())

        _ = try await sut.refresh(token: "refresh-token")
    }

    @Test("registerDeviceToken 요청이 올바른 바디로 인코딩된다")
    func testRegisterDeviceTokenParameters() async throws {
        UserDefaults.standard.removeObject(forKey: "auth.pendingKey")

        let provider = stubAuthProviderForDeviceToken()
        let sut = AuthRemoteDataSource(authProvider: provider, oauthProvider: stubOAuthNoop())

        _ = try await sut.registerDeviceToken(token: "device-token")
    }
}

// MARK: - Stubs
private func stubOAuthProviderForCheckUser() -> MoyaProvider<OAuthAPITarget> {
        let endpointClosure = { (target: OAuthAPITarget) -> Endpoint in
            guard case let .checkSignUpUser(body) = target else {
                fatalError("Unexpected target \(target)")
            }
        let params = target.parameters ?? [:]
        #expect(params["accessToken"] as? String == body.accessToken)
        #expect(params["loginType"] as? String == body.loginType)
        #expect(params["authorizationCode"] as? String == body.authorizationCode)
        #expect(params["codeVerifier"] as? String == body.codeVerifier)
        #expect(params["redirectUri"] as? String == body.redirectUri)

        let responseBody: [String: Any] = [
            "code": 200,
            "data": ["registered": true],
            "message": "success"
        ]
        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        let url = target.baseURL.appendingPathComponent(target.path)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: target.headers)!
        return Endpoint(
            url: url.absoluteString,
            sampleResponseClosure: { .response(httpResponse, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    return MoyaProvider<OAuthAPITarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
}

private func stubOAuthProviderForLogin() -> MoyaProvider<OAuthAPITarget> {
    let endpointClosure = { (target: OAuthAPITarget) -> Endpoint in
        guard case let .loginOAuth(body) = target else {
            fatalError("Unexpected target \(target)")
        }
        let params = target.parameters ?? [:]
        #expect(params["accessToken"] as? String == body.accessToken)
        #expect(params["loginType"] as? String == body.loginType)
        #expect(params["authorizationCode"] as? String == body.authorizationCode)
        #expect(params["codeVerifier"] as? String == body.codeVerifier)
        #expect(params["redirectUri"] as? String == body.redirectUri)

        let responseBody: [String: Any] = [
            "code": 200,
            "data": [
                "user": [
                    "id": "user",
                    "email": "mock@example.com",
                    "name": "Mock User",
                    "role": "user",
                    "createdAt": "2025-11-26T12:00:00Z",
                    "userId": "user"
                ],
                "accessToken": "access",
                "refreshToken": "refresh",
                "accessTokenExpiresAt": "2025-11-27T12:00:00Z",
                "refreshTokenExpiresAt": "2025-12-27T12:00:00Z",
                "sessionId": "session",
                "sessionExpiresAt": "2025-11-27T12:00:00Z",
                "loginType": "google"
            ],
            "message": "success"
        ]
        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        let url = target.baseURL.appendingPathComponent(target.path)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: target.headers)!
        return Endpoint(
            url: url.absoluteString,
            sampleResponseClosure: { .response(httpResponse, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    return MoyaProvider<OAuthAPITarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
}

private func stubOAuthProviderForSignUp() -> MoyaProvider<OAuthAPITarget> {
    let endpointClosure = { (target: OAuthAPITarget) -> Endpoint in
        guard case let .signUpOAuth(body) = target else {
            fatalError("Unexpected target \(target)")
        }
        let params = target.parameters ?? [:]
        #expect(params["accessToken"] as? String == body.accessToken)
        #expect(params["loginType"] as? String == body.loginType)
        #expect(params["authorizationCode"] as? String == body.authorizationCode)
        #expect(params["codeVerifier"] as? String == body.codeVerifier)
        #expect(params["redirectUri"] as? String == body.redirectUri)
        #expect(params["deviceToken"] as? String == body.deviceToken)

        let responseBody: [String: Any] = [
            "code": 200,
            "data": [
                "user": [
                    "id": "user",
                    "email": "mock@example.com",
                    "name": "Mock User",
                    "role": "user",
                    "createdAt": "2025-11-26T12:00:00Z",
                    "userId": "user"
                ],
                "accessToken": "access",
                "refreshToken": "refresh",
                "accessTokenExpiresAt": "2025-11-27T12:00:00Z",
                "refreshTokenExpiresAt": "2025-12-27T12:00:00Z",
                "sessionId": "session",
                "sessionExpiresAt": "2025-11-27T12:00:00Z",
                "loginType": "google"
            ],
            "message": "success"
        ]
        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        let url = target.baseURL.appendingPathComponent(target.path)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: target.headers)!
        return Endpoint(
            url: url.absoluteString,
            sampleResponseClosure: { .response(httpResponse, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
    return MoyaProvider<OAuthAPITarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
}

private func stubAuthProviderForRefresh() -> MoyaProvider<AuthAPITarget> {
    let endpointClosure = { (target: AuthAPITarget) -> Endpoint in
        guard case let .refreshToken(body: body) = target else {
            fatalError("Unexpected target \(target)")
        }
        #expect(body.refreshToken == "refresh-token")

        let responseBody: [String: Any] = [
            "code": 200,
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
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: target.headers)!
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

private func stubAuthProviderForDeviceToken() -> MoyaProvider<AuthAPITarget> {
    let endpointClosure = { (target: AuthAPITarget) -> Endpoint in
        guard case let .registerDeviceToken(body: body) = target else {
            fatalError("Unexpected target \(target)")
        }
        #expect(body.deviceToken == "device-token")
        #expect(body.pendingKey.isEmpty == false)

        let responseBody: [String: Any] = [
            "code": 200,
            "data": [
                "deviceToken": body.deviceToken,
                "pendingKey": body.pendingKey,
                "mode": "mock"
            ],
            "message": "success"
        ]
        let data = try! JSONSerialization.data(withJSONObject: responseBody)
        let url = target.baseURL.appendingPathComponent(target.path)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: target.headers)!
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

private func stubAuthNoop() -> MoyaProvider<AuthAPITarget> {
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

private func stubOAuthNoop() -> MoyaProvider<OAuthAPITarget> {
    let endpointClosure = { (target: OAuthAPITarget) -> Endpoint in
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
    return MoyaProvider<OAuthAPITarget>(endpointClosure: endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
}
