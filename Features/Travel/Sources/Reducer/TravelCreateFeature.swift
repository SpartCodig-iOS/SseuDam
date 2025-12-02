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
    public struct State: Equatable, Hashable {
        var title = ""

        // 국가 검색
        var searchText: String = ""

        // 국가 데이터
        var countries: [Country] = []
        var selectedCountryName: String?
        var selectedCountryCode: String?

        // 화폐 / 환율
        var currency: [String] = []
        var selectedCurrency: String?
        var rate: String = ""

        // 여행 날짜
        var startDate: Date?
        var endDate: Date?

        // 로딩 상태
        var isLoadingCountries = false
        var isLoadingRate = false

        var isSubmitting = false
        var submitError: String?

        // 저장 여부
        var isSaveEnabled: Bool {
            guard !title.isEmpty,
                  let code = selectedCountryCode,
                  startDate != nil,
                  endDate != nil else { return false }

            if code == "KR" { return true }

            return !currency.isEmpty && selectedCurrency != nil && !rate.isEmpty
        }

        // 필터링된 국가 목록
        var filteredCountries: [Country] {
            if searchText.isEmpty { return countries }
            return countries.filter {
                $0.koreanName.contains(searchText) ||
                $0.englishName.lowercased().contains(searchText.lowercased())
            }
        }
        
        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)

        case onAppear

        case countriesResponse(Result<[Country], Error>)
        case countryNameChanged(String?)

        case searchTextChanged(String)

        case startDateChanged(Date?)
        case endDateChanged(Date?)

        case currencySelected(String)
        case rateChanged(String)

        case fetchRateResponse(Result<ExchangeRate, Error>)

        case titleChanged(String)

        case saveButtonTapped
        case saveTravelResponse(Result<Travel, Error>)

        case dismiss
    }
    
    public init() {}

    @Dependency(\.createTravelUseCase) var createTravelUseCase
    @Dependency(\.fetchCountriesUseCase) var fetchCountriesUseCase
    @Dependency(\.fetchExchangeRateUseCase) var fetchExchangeRateUseCase

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {

                // MARK: 국가 목록 호출
            case .onAppear:
                state.isLoadingCountries = true
                return .run { [fetchCountriesUseCase = self.fetchCountriesUseCase] send in
                    do {
                        let result = try await fetchCountriesUseCase.execute()
                        await send(.countriesResponse(.success(result)))
                    } catch {
                        await send(.countriesResponse(.failure(error)))
                    }
                }


                // MARK: 국가 목록 응답
            case .countriesResponse(.success(let list)):
                state.isLoadingCountries = false
                state.countries = list
                return .none

            case .countriesResponse(.failure(let error)):
                state.isLoadingCountries = false
                state.submitError = "국가 목록 불러오기 실패: \(error.localizedDescription)"
                return .none

                // MARK: 국가 선택
            case .countryNameChanged(let name):
                state.selectedCountryName = name

                guard let name,
                      let selected = state.countries.first(where: { $0.koreanName == name }) else {
                    state.selectedCountryCode = nil
                    state.currency = []
                    state.selectedCurrency = nil
                    state.rate = ""
                    return .none
                }

                state.selectedCountryCode = selected.code
                state.currency = selected.currencies
                state.selectedCurrency = selected.currencies.first
                state.rate = ""

                if selected.code == "KR" { return .none }

                if let firstCurrency = selected.currencies.first {
                    return .send(.currencySelected(firstCurrency))
                }

                return .none

                // MARK: 국가 검색
            case .searchTextChanged(let text):
                state.searchText = text
                return .none

                // MARK: 날짜 선택
            case .startDateChanged(let date):
                state.startDate = date
                return .none

            case .endDateChanged(let date):
                state.endDate = date
                return .none

                // MARK: 통화 선택 → 환율 호출
            case .currencySelected(let cur):
                state.selectedCurrency = cur

                guard let quote = state.selectedCurrency,
                      let code = state.selectedCountryCode,
                      code != "KR" else { return .none }

                state.isLoadingRate = true

                return .run {
                    [fetchExchangeRateUseCase = self.fetchExchangeRateUseCase, quote] send in
                    do {
                        let dto = try await fetchExchangeRateUseCase.execute(quote: quote)
                        await send(.fetchRateResponse(.success(dto)))
                    } catch {
                        await send(.fetchRateResponse(.failure(error)))
                    }
                }


                // MARK: 환율 응답
            case .fetchRateResponse(.success(let dto)):
                state.isLoadingRate = false
                state.rate = String(dto.rate)
                return .none

            case .fetchRateResponse(.failure(let error)):
                state.isLoadingRate = false
                state.submitError = "환율 조회 실패: \(error.localizedDescription)"
                return .none

            case .rateChanged(let value):
                state.rate = value
                return .none

            case .titleChanged(let newValue):
                state.title = newValue
                return .none

                // MARK: 저장
            case .saveButtonTapped:
                guard state.isSaveEnabled,
                      let start = state.startDate,
                      let end = state.endDate,
                      let code = state.selectedCountryCode else { return .none }

                let rateValue = Double(state.rate) ?? 0.0
                let input = CreateTravelInput(
                    title: state.title,
                    startDate: start,
                    endDate: end,
                    countryCode: code,
                    koreanCountryName: state.selectedCountryName ?? "-",
                    baseCurrency: state.selectedCurrency ?? "KRW",
                    baseExchangeRate: code == "KR" ? 1 : rateValue
                )

                state.isSubmitting = true

                return .run {
                    [createTravelUseCase = self.createTravelUseCase, input] send in
                    do {
                        let travel = try await createTravelUseCase.excute(input: input)
                        await send(.saveTravelResponse(.success(travel)))
                    } catch {
                        await send(.saveTravelResponse(.failure(error)))
                    }
                }


            case .saveTravelResponse(.success):
                state.isSubmitting = false
                return .send(.dismiss)

            case .saveTravelResponse(.failure(let error)):
                state.isSubmitting = false
                state.submitError = "저장 실패: \(error.localizedDescription)"
                return .none

            case .dismiss:
                return .none

            case .binding:
                return .none
            }
        }
    }
}
