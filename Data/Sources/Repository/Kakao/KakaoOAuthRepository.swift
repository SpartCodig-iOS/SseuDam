//
//  KakaoOAuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 12/05/25.
//

import Foundation
import AuthenticationServices
import UIKit
import CryptoKit
import Security
import Domain
import LogMacro

/// Kakao OAuth - 백엔드 콜백 기반(PKCE) 플로우
/// 1) authorize 호출 (카카오톡/웹)
/// 2) 서버 콜백 → 앱 딥링크(sseudam://oauth/kakao?ticket=...)
/// 3) ticket + code_verifier/redirectUri를 전달해 서버에서 토큰 교환
public final class KakaoOAuthRepository: NSObject, KakaoOAuthRepositoryProtocol {
    public struct StatePayload: Codable {
        let codeVerifier: String
        let appRedirectUri: String
    }

    public struct PKCE {
        let codeVerifier: String
        let codeChallenge: String
    }

    private let serverRedirectUri = "https://sseudam.up.railway.app/api/v1/oauth/kakao/callback"
    private let appRedirectUri = "sseudam://oauth/kakao"
    private var authSession: ASWebAuthenticationSession?

    public override init() {}

    @MainActor
    public func signIn() async throws -> KakaoOAuthPayload {
        // 이전 시도에서 남은 코드를 제거하고 새 플로우 시작
        KakaoAuthCodeStore.shared.reset()

        let pkce = try generatePKCE()
        let state = try encodeState(
            StatePayload(codeVerifier: pkce.codeVerifier, appRedirectUri: appRedirectUri)
        )

        // Kakao 웹 인증에는 REST API 키를 사용한다. (네이티브 키가 아님)
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "KAKAO_REST_API_KEY") as? String,
              !clientID.isEmpty
        else {
            throw AuthError.configurationMissing
        }

        let authorizeURL = try buildAuthorizeURL(
            clientID: clientID,
            codeChallenge: pkce.codeChallenge,
            state: state
        )

        // 카카오톡 설치 시: 톡 앱으로만 진행(웹 세션 표시 없음), 딥링크(ticket/code)는 KakaoAuthCodeStore에서 기다림
        if let talkURL = talkAuthorizeURL(from: authorizeURL) {
            UIApplication.shared.open(talkURL, options: [:], completionHandler: nil)
            let ticket = try await KakaoAuthCodeStore.shared.waitForCode()
            return KakaoOAuthPayload(
                idToken: "",
                accessToken: "",
                refreshToken: nil,
                authorizationCode: ticket,
                displayName: nil,
                codeVerifier: pkce.codeVerifier,
                redirectUri: serverRedirectUri
            )
        }

        // 카카오톡 미설치: 웹 authorize (ASWebAuthenticationSession)
        let ticket = try await startAuthSession(with: authorizeURL, callbackScheme: URL(string: appRedirectUri)?.scheme)

        return KakaoOAuthPayload(
            idToken: "",
            accessToken: "",
            refreshToken: nil,
            authorizationCode: ticket,          // ticket 혹은 code를 authorizationCode로 전달
            displayName: nil,
            codeVerifier: pkce.codeVerifier,    // 서버 토큰 교환 시 사용
            redirectUri: serverRedirectUri      // 서버 콜백 URI
        )
    }
}

// MARK: - Private helpers
private extension KakaoOAuthRepository {
    func generatePKCE() throws -> PKCE {
        let verifierData = try randomData(length: 48)
        let verifier = base64URLEncode(verifierData)
        guard let challengeData = verifier.data(using: .utf8) else {
            throw AuthError.unknownError("PKCE 생성 실패")
        }
        let challengeHash = SHA256.hash(data: challengeData)
        let challenge = base64URLEncode(Data(challengeHash))
        return PKCE(codeVerifier: verifier, codeChallenge: challenge)
    }

    func encodeState(_ payload: StatePayload) throws -> String {
        let data = try JSONEncoder().encode(payload)
        return base64URLEncode(data)
    }

    func buildAuthorizeURL(
        clientID: String,
        codeChallenge: String,
        state: String
    ) throws -> URL {
        var components = URLComponents(string: "https://kauth.kakao.com/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: serverRedirectUri),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "login"), // 계정 선택 강제
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: state)
        ]
        guard let url = components?.url else {
            throw AuthError.invalidCredential("Kakao authorize URL 생성 실패")
        }
        return url
    }

    func talkAuthorizeURL(from authorizeURL: URL) -> URL? {
        guard var components = URLComponents(url: authorizeURL, resolvingAgainstBaseURL: false) else { return nil }
        components.scheme = "kakaokompassauth"
        guard let talkURL = components.url else { return nil }
        return UIApplication.shared.canOpenURL(talkURL) ? talkURL : nil
    }

    @MainActor
    func startAuthSession(
        with url: URL,
        callbackScheme: String?
    ) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let provider = PresentationContextProvider()
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: AuthError.userCancelled)
                        return
                    }
                    continuation.resume(throwing: AuthError.unknownError(error.localizedDescription))
                    return
                }

                guard let callbackURL else {
                    continuation.resume(throwing: AuthError.unknownError("Kakao 로그인 콜백이 없습니다"))
                    return
                }

                guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false) else {
                    continuation.resume(throwing: AuthError.invalidCredential("잘못된 Kakao 콜백 URL"))
                    return
                }

                if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
                    continuation.resume(throwing: AuthError.unknownError(error))
                    return
                }

                let ticket = components.queryItems?.first(where: { $0.name == "ticket" })?.value
                    ?? components.queryItems?.first(where: { $0.name == "code" })?.value

                guard let ticket else {
                    continuation.resume(throwing: AuthError.unknownError("Kakao ticket을 찾을 수 없습니다"))
                    return
                }

                continuation.resume(returning: ticket)
            }
            session.presentationContextProvider = provider
            // iCloud Private Relay 등 환경에서도 세션이 유지되도록 무조건 사파리 세션을 에페메럴로 사용
            session.prefersEphemeralWebBrowserSession = true
            self.authSession = session
            session.start()
        }
    }

    func randomData(length: Int) throws -> Data {
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }
        guard result == errSecSuccess else {
            throw AuthError.unknownError("난수 생성 실패")
        }
        return data
    }

    func base64URLEncode(_ data: Data) -> String {
        return data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

// MARK: - Helpers
private final class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // 가장 앞선 윈도우를 anchor로 사용
        return UIApplication.shared.connectedScenes
            .compactMap { scene -> UIWindow? in
                guard let windowScene = scene as? UIWindowScene else { return nil }
                return windowScene.windows.first(where: { $0.isKeyWindow })
            }
            .first ?? ASPresentationAnchor()
    }
}
