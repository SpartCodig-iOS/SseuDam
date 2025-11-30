//
//  TravelRepositoryProtocol.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

public protocol TravelRepositoryProtocol {
    func fetchTravels(input: FetchTravelsInput) async throws -> [Travel]
    func createTravel(input: CreateTravelInput) async throws -> Travel
    func updateTravel(id: String, input: UpdateTravelInput) async throws -> Travel
    func deleteTravel(id: String) async throws
    func fetchTravelDetail(id: String) async throws -> Travel
    func deleteMember(travelId: String, memberId: String) async throws
    func joinTravel(inviteCode: String) async throws -> Travel
    func delegateOwner(travelId: String, newOwnerId: String) async throws -> Travel
    func leaveTravel(travelId: String) async throws
}
