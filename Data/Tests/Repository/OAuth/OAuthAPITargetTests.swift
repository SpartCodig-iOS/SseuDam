//
//  OAuthAPITargetTests.swift
//  Data
//
//  Created by Wonji Suh on 12/11/25.
//

import Testing
import Moya
@testable import Data

@Suite("OAuthAPITarget Tests", .serialized, .tags(.repository, .unit))
struct OAuthAPITargetTests {

    @Test("checkSignUpUser 타깃이 올바른 경로와 POST 메서드를 사용한다")
    func testCheckSignUpTargetPathAndMethod() {
        let body = LoginUserRequestDTO(
            accessToken: "token",
            loginType: "google",
            authorizationCode: nil,
            codeVerifier: nil,
            redirectUri: nil,
            deviceToken: nil
        )
        let target = OAuthAPITarget.checkSignUpUser(body: body)

        #expect(target.urlPath == OAuthAPI.checkSignUpUser.description)
        #expect(target.method == .post)
    }

    @Test("checkSignUpUser 타깃이 파라미터를 올바르게 인코딩한다")
    func testCheckSignUpTargetParameters() {
        let body = LoginUserRequestDTO(
            accessToken: "token-123",
            loginType: "apple",
            authorizationCode: "auth-code",
            codeVerifier: "code-verifier",
            redirectUri: "redirect://uri",
            deviceToken: "device-token"
        )
        let target = OAuthAPITarget.checkSignUpUser(body: body)

        let params = target.parameters ?? [:]

        #expect(params["accessToken"] as? String == "token-123")
        #expect(params["loginType"] as? String == "apple")
        #expect(params["authorizationCode"] as? String == "auth-code")
        #expect(params["codeVerifier"] as? String == "code-verifier")
        #expect(params["redirectUri"] as? String == "redirect://uri")
        #expect(params["deviceToken"] as? String == "device-token")
    }

    @Test("baseURL와 path 조합이 올바른 전체 URL을 만든다")
    func testFullURLBuildsCorrectly() {
        let body = LoginUserRequestDTO(
            accessToken: "token",
            loginType: "google",
            authorizationCode: nil,
            codeVerifier: nil,
            redirectUri: nil,
            deviceToken: nil
        )
        let target = OAuthAPITarget.checkSignUpUser(body: body)
        let fullURL = target.baseURL.appendingPathComponent(target.path).absoluteString

        #expect(fullURL.contains(target.domain.baseURLString))
        #expect(fullURL.hasSuffix("/oauth\(OAuthAPI.checkSignUpUser.description)"))
    }
}
