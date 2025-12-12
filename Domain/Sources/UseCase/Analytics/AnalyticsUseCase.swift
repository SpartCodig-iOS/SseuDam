import Foundation
import ComposableArchitecture

/// Analytics UseCase 구현체
public struct AnalyticsUseCase: AnalyticsUseCaseProtocol, Sendable {
    private let repository: any AnalyticsRepositoryProtocol

    public init(repository: any AnalyticsRepositoryProtocol) {
        self.repository = repository
    }

    public func track(_ event: AnalyticsEvent) {
        Task {
            await repository.sendEvent(event)
        }
    }
}

// MARK: - Dependency Key

extension AnalyticsUseCase: DependencyKey {
  public static let liveValue: any AnalyticsUseCaseProtocol = AnalyticsUseCase(repository: MockAnalyticsRepository())
  public static let testValue: any AnalyticsUseCaseProtocol = AnalyticsUseCase(repository: MockAnalyticsRepository())
}

public extension DependencyValues {
    var analyticsUseCase: any AnalyticsUseCaseProtocol {
        get { self[AnalyticsUseCase.self] }
        set { self[AnalyticsUseCase.self] = newValue }
    }
}
