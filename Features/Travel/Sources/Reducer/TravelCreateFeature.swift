//
//  TravelCreateFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 11/25/25.
//

import Foundation
import Domain
import ComposableArchitecture

@Reducer
public struct TravelCreateFeature {
    @ObservableState
    public struct State: Equatable {
        var title = ""
        var currency: [String] = []
        var rate = ""
        var selectedCurrency: String? = nil
        var selectedCountry: String? = nil
        var startDate: Date? = nil
        var endDate: Date? = nil

        var isSubmitting: Bool = false
        var submitError: String?

        var isSaveEnabled: Bool {
            guard !title.isEmpty else { return false }
            guard startDate != nil, endDate != nil else { return false }
            guard let country = selectedCountry, !country.isEmpty else { return false }

            if country == "한국" {
                return true
            }

            return !currency.isEmpty && !rate.isEmpty
        }
    }

    public enum Action {
        case titleChanged(String)
        case currencyChanged([String])
        case rateChanged(String)
        case countryChanged(String?)
        case startDateChanged(Date?)
        case endDateChanged(Date?)

        case currencyFieldTapped
        case currencySelected(String)

        case saveButtonTapped
        case saveResponse(Result<Travel, Error>)

        case dismiss
    }

    @Dependency(\.createTravelUseCase) var createTravelUseCase: CreateTravelUseCaseProtocol

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .titleChanged(let newValue):
                state.title = newValue
                return .none

            case .currencyChanged(let list):
                state.currency = list
                return .none

            case .rateChanged(let value):
                state.rate = value
                return .none

            case .countryChanged(let value):
                state.selectedCountry = value

                let mockCurrency: [String: [String]] = [
                    "한국": ["KRW"],
                    "미국": ["USD"],
                    "일본": ["JPY"],
                    "아르헨티나": ["ARS", "USD"],
                    "영국": ["GBP", "USD"],
                    "호주": ["AUD"]
                ]

                // 선택된 나라에 해당되는 화폐를 넣어줌
                state.currency = mockCurrency[value ?? ""] ?? []
                state.selectedCurrency = state.currency.first
                state.rate = ""
                return .none

            case .startDateChanged(let value):
                state.startDate = value
                return .none

            case .endDateChanged(let value):
                state.endDate = value
                return .none

            case .currencyFieldTapped:
                return .none

            case .currencySelected(let value):
                state.selectedCurrency = value
                return .none

            case .saveButtonTapped:
                guard state.isSaveEnabled else { return .none }
                guard
                    let start = state.startDate,
                    let end = state.endDate,
                    let country = state.selectedCountry
                else { return .none }

                state.isSubmitting = true
                state.submitError = nil

                let rateValue = Double(state.rate) ?? 0.0
                let input = CreateTravelInput(
                    title: state.title,
                    startDate: start,
                    endDate: end,
                    countryCode: country,
                    baseCurrency: state.currency.first ?? "KRW",
                    baseExchangeRate: country == "한국" ? 1 : rateValue
                )

                return .run { send in
                    do {
                        print("저장")
                        let travel = try await createTravelUseCase.excute(input: input)
                        await send(.saveResponse(.success(travel)))
                    } catch {
                        await send(.saveResponse(.failure(error)))
                    }
                }

            case .saveResponse(.success):
                state.isSubmitting = false
                return .send(.dismiss)

            case .saveResponse(.failure(let error)):
                state.isSubmitting = false
                state.submitError = error.localizedDescription
                return .none

            case .dismiss:
                return .none
            }
        }
    }
}
