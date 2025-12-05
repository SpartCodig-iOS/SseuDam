//
//  SettlementRemoteDataSource.swift
//  Data
//
//  Created by 홍석현 on 12/4/25.
//

import Foundation
import Domain
import Moya
import NetworkService

public protocol SettlementRemoteDataSourceProtocol {
    func fetchSettlement(travelId: String) async throws -> TravelSettlementDTO
}

public struct SettlementRemoteDataSource: SettlementRemoteDataSourceProtocol {

    private let provider: MoyaProvider<SettlementAPI>

    public init(provider: MoyaProvider<SettlementAPI> = MoyaProvider<SettlementAPI>()) {
        self.provider = provider
    }

    public func fetchSettlement(travelId: String) async throws -> TravelSettlementDTO {
        let response: BaseResponse<TravelSettlementDTO> =
        try await provider.request(.fetchSettlement(travelId: travelId))

        guard let data = response.data else {
            throw NetworkError.noData
        }

        return data
    }
}
