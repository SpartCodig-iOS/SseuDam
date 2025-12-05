//
//  KakaoFinalizeRepository.swift
//  Data
//
//  Created by Assistant on 12/5/25.
//

import Foundation
import Domain
import Moya
import NetworkService

public final class KakaoFinalizeRepository: KakaoFinalizeRepositoryProtocol {
    private let provider: MoyaProvider<OAuthAPITarget>

    public init(provider: MoyaProvider<OAuthAPITarget> = .default) {
        self.provider = provider
    }

    public func finalize(ticket: String) async throws -> AuthResult {
        let body = KakaoFinalizeRequestDTO(ticket: ticket)
        let response: BaseResponse<AuthResponseDTO> = try await provider.request(.kakaoFinalize(body: body))
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.toDomain()
    }

}
