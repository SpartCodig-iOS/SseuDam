//
//  OAuthRepository.swift
//  Data
//
//  Created by Wonji Suh  on 11/17/25.
//

import Domain
import Supabase
import LogMacro
import Moya
import NetworkService

public final class OAuthRepository: OAuthRepositoryProtocol {

  private let supabaseprovider: SupabaseClientProviding
  private let dataSource: OAuthRemoteDataSourceProtocol
  private var client: SupabaseClient { supabaseprovider.client }
  private var provider: MoyaProvider<OAuthAPITarget>

  public init(
    provider: MoyaProvider<OAuthAPITarget> = MoyaProvider<OAuthAPITarget>.default,
    dataSource: OAuthRemoteDataSourceProtocol = OAuthRemoteDataSource()
  ) {
    self.supabaseprovider = SupabaseClientProvider.shared
    self.dataSource = dataSource
    self.provider = provider
  }

  public func signIn(
    provider: SocialType,
    idToken: String,
    nonce: String?,
    displayName: String?
  ) async throws -> Supabase.Session {
    let credentials = OpenIDConnectCredentials(
      provider: provider == .apple ? .apple : .google,
      idToken: idToken,
      nonce: nonce
    )

    let session = try await client.auth.signInWithIdToken(credentials: credentials)
    Log.info("\(provider.rawValue) signInWithIdToken completed. \(session.accessToken)")

    try await updateDisplayNameIfNeeded(displayName)
    return session
  }

  public func updateUserDisplayName(_ name: String) async throws {
    try await client.auth.update(
      user: UserAttributes(data: ["display_name": .string(name)])
    )
  }

  // MARK: - Private
  private func updateDisplayNameIfNeeded(_ displayName: String?) async throws {
    guard let displayName = displayName?.trimmingCharacters(in: .whitespacesAndNewlines),
          !displayName.isEmpty
    else { return }

    try await updateUserDisplayName(displayName)
    Log.info("Updated Supabase display_name to \(displayName)")
  }

  public func checkSignUpUser(
    input: Domain.OAuthCheckUserInput
  ) async throws -> Domain.OAuthCheckUser {
    let body = OAuthCheckUserRequestDTO(accessToken: input.accessToken, loginType: input.socialType.rawValue)
    let response: BaseResponse<OAuthCheckUserResponseDTO> = try await provider.request(.checkSignUpUser(body: body))
    guard let data = response.data else {
      throw NetworkError.noData
    }
    return data.toDomain()
  }
}
