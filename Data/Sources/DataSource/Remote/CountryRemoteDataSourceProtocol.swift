//
//  CountryRemoteDataSourceProtocol.swift
//  Data
//
//  Created by 김민희 on 11/27/25.
//

import Foundation
import Moya
import NetworkService

public protocol CountryRemoteDataSourceProtocol {
    func fetchCountries() async throws -> [CountryResponseDTO]
}

public final class CountryRemoteDataSource: CountryRemoteDataSourceProtocol {
    private let provider: MoyaProvider<CountryAPI>

    public init(provider: MoyaProvider<CountryAPI> = .init()) {
        self.provider = provider
    }

    public func fetchCountries() async throws -> [CountryResponseDTO] {
        let response: BaseResponse<[CountryResponseDTO]> = try await provider.request(.fetchCountries)
        return response.data ?? []
    }
}
