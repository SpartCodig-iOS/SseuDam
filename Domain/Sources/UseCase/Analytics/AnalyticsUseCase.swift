import Foundation
import ComposableArchitecture
import Dependencies

/// Analytics UseCase 구현체
public struct AnalyticsUseCase: AnalyticsUseCaseProtocol, Sendable {
    @Dependency(\.analyticsRepository) private var repository: any AnalyticsRepositoryProtocol

    public init() {}

    public func track(_ event: AnalyticsEvent) {
        Task {
            await repository.sendEvent(event)
        }
    }
}

// MARK: - Dependency Key

extension AnalyticsUseCase: DependencyKey {
  public static let liveValue: any AnalyticsUseCaseProtocol = AnalyticsUseCase()
  public static let testValue: any AnalyticsUseCaseProtocol = AnalyticsUseCase()
}

public extension DependencyValues {
    var analyticsUseCase: any AnalyticsUseCaseProtocol {
        get { self[AnalyticsUseCase.self] }
        set { self[AnalyticsUseCase.self] = newValue }
    }
}
