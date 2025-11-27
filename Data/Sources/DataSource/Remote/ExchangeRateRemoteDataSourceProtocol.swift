//
//  ExchangeRateRemoteDataSourceProtocol.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Domain
import Moya
import NetworkService

public protocol ExchangeRateRemoteDataSourceProtocol {
    func fetchExchangeRate(quote: String) async throws -> ExchangeRateResponseDTO
}

public final class ExchangeRateRemoteDataSource: ExchangeRateRemoteDataSourceProtocol {
    private let provider: MoyaProvider<ExchangeRateAPI>

    public init(provider: MoyaProvider<ExchangeRateAPI> = .init()) {
        self.provider = provider
    }

    public func fetchExchangeRate(quote: String) async throws -> ExchangeRateResponseDTO {
        let response: BaseResponse<ExchangeRateResponseDTO> =
        try await provider.request(.fetchRate(quote: quote))

        return response.data!
    }
}
