//
//  TravelRepository.swift
//  Data
//
//  Created by 김민희 on 11/18/25.
//

import Foundation
import Domain

public final class TravelRepository: TravelRepositoryProtocol {

    private let remote: TravelRemoteDataSourceProtocol

    public init(remote: TravelRemoteDataSourceProtocol) {
        self.remote = remote
    }

    public func fetchTravels(limit: Int, page: Int) async throws -> [Travel] {
        let dtoList = try await remote.fetchTravels(limit: limit, page: page)
        return dtoList.map { $0.toDomain() }
    }

    public func createTravel(input: CreateTravelInput) async throws -> Travel {
        let requestDTO = input.toDTO()
        let responseDTO = try await remote.createTravel(body: requestDTO)
        return responseDTO.toDomain()
    }

    public func updateTravel(id: String, input: UpdateTravelInput) async throws -> Travel {
        let requestDTO = input.toDTO()
        let responseDTO = try await remote.updateTravel(id: id, body: requestDTO)
        return responseDTO.toDomain()
    }

    public func deleteTravel(id: String) async throws {
        _ = try await remote.deleteTravel(id: id)
    }
}
