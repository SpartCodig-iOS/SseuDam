//
//  FetchTravelsUseCase.swift
//  Domain
//
//  Created by 김민희 on 11/17/25.
//

import Foundation

protocol FetchTravelsUseCaseProtocol {
  func excute(limit: Int, page: Int) async throws -> [Travel]
}

final class FetchTravelsUseCase: FetchTravelsUseCaseProtocol {
  private let repository: TravelRepositoryProtocol

  init(repository: TravelRepositoryProtocol) {
    self.repository = repository
  }

  func excute(limit: Int, page: Int) async throws -> [Travel] {
    try await repository.fetchTravels(limit: limit, page: page)
  }
}
