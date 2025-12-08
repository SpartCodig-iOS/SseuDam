//
//  BasicSettingFeature.swift
//  TravelFeature
//
//  Created by 김민희 on 12/1/25.
//

import Foundation
import Domain
import ComposableArchitecture
import DesignSystem

@Reducer
public struct BasicSettingFeature {
    public init() {}
    @ObservableState
    public struct State: Equatable {
        var travel: Travel

        // 입력 항목
        var title: String
        var startDate: Date
        var endDate: Date

        // 국가
        var countries: [Country] = []
        var searchText: String = ""
        var selectedCountryName: String?
        var selectedCountryCode: String?

        // 화폐 / 환율
        var currencies: [String] = []
        var selectedCurrency: String?
        var exchangeRate: String = ""

        // UI 상태
        var isLoadingCountries: Bool = false
        var isLoadingRate: Bool = false
        var isSubmitting: Bool = false
        var errorMessage: String?

        public init(travel: Travel) {
            self.travel = travel
            self.title = travel.title
            self.startDate = travel.startDate
            self.endDate = travel.endDate

            self.selectedCountryCode = travel.countryCode
            self.selectedCountryName = travel.koreanCountryName
            self.selectedCurrency = travel.baseCurrency
            self.exchangeRate = "\(travel.baseExchangeRate)"
            self.currencies = travel.currencies ?? [travel.baseCurrency]
        }

        // 필수 조건 체크
        var canSave: Bool {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTitle.isEmpty,
                  let countryCode = selectedCountryCode,
                  startDate <= endDate else { return false }

            if countryCode == "KR" { return true }

            if !exchangeRate.isEmpty { return true }

            return !(currencies.isEmpty || selectedCurrency == nil || exchangeRate.isEmpty)
        }

        // 국가 필터링
        var filteredCountries: [Country] {
            if searchText.isEmpty { return countries }
            return countries.filter {
                $0.koreanName.contains(searchText) ||
                $0.englishName.lowercased().contains(searchText.lowercased())
            }
        }

        var isOwner: Bool {
            guard let myId = travel.members.first?.id else { return false }
            let ownerId = travel.members.first(where: { $0.role == "owner" })?.id
            return ownerId == myId
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)

        // 기본 정보 변경
        case titleChanged(String)
        case startDateChanged(Date)
        case endDateChanged(Date)

        // 국가
        case onAppearCountries
        case countriesResponse(Result<[Country], Error>)
        case searchTextChanged(String)
        case countrySelected(String)

        // 화폐 / 환율
        case currencySelected(String)
        case fetchRateResponse(Result<ExchangeRate, Error>)

        // 저장
        case saveButtonTapped
        case updateResponse(Result<Travel, Error>)

        case updated(Travel)      // 부모로 전달

        case errorDismissed
    }

    @Dependency(\.fetchCountriesUseCase) var fetchCountriesUseCase
    @Dependency(\.fetchExchangeRateUseCase) var fetchExchangeRateUseCase
    @Dependency(\.updateTravelUseCase) var updateTravelUseCase

    public var body: some Reducer<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {

            // MARK: 기본 정보
            case .titleChanged(let value):
                state.title = value
                return .none

            case .startDateChanged(let date):
                state.startDate = date
                return .none

            case .endDateChanged(let date):
                state.endDate = date
                return .none

            // MARK: 국가 목록 로딩
            case .onAppearCountries:
                state.isLoadingCountries = true
                return .run {
                    [fetchCountriesUseCase] send in
                    do {
                        let countries = try await fetchCountriesUseCase.execute()
                        await send(.countriesResponse(.success(countries)))
                    } catch {
                        await send(.countriesResponse(.failure(error)))
                    }
                }

            case .countriesResponse(.success(let list)):
                state.isLoadingCountries = false
                state.countries = list

                // 현재 countryCode 를 기반으로 currency 세팅
                if let code = state.selectedCountryCode,
                   let selected = list.first(where: { $0.code == code }) {
                    state.currencies = selected.currencies
                }

                return .none

            case .countriesResponse(.failure(let error)):
                state.isLoadingCountries = false
                state.errorMessage = "국가 목록 불러오기 실패: \(error.localizedDescription)"
                return .none

            // MARK: 국가 검색
            case .searchTextChanged(let text):
                state.searchText = text
                return .none

            // MARK: 국가 선택
            case .countrySelected(let name):
                guard let selected = state.countries.first(where: { $0.koreanName == name }) else { return .none }

                state.selectedCountryName = selected.koreanName
                state.selectedCountryCode = selected.code

                // currency 초기화
                state.currencies = selected.currencies
                state.selectedCurrency = selected.currencies.first
                state.exchangeRate = ""

                // 한국일 경우 환율 필요 없음
                if selected.code == "KR" {
                    return .none
                }

                if let currency = selected.currencies.first {
                    return .send(.currencySelected(currency))
                }

                return .none

            // MARK: 통화 변경 → 환율 조회
            case .currencySelected(let cur):
                state.selectedCurrency = cur

                guard let countryCode = state.selectedCountryCode,
                      countryCode != "KR" else { return .none }

                state.isLoadingRate = true
                return .run {
                    [fetchExchangeRateUseCase, cur] send in
                    do {
                        let dto = try await fetchExchangeRateUseCase.execute(base: cur)
                        await send(.fetchRateResponse(.success(dto)))
                    } catch {
                        await send(.fetchRateResponse(.failure(error)))
                    }
                }

            case .fetchRateResponse(.success(let dto)):
                state.isLoadingRate = false
                state.exchangeRate = String(dto.rate)
                return .none

            case .fetchRateResponse(.failure(let error)):
                state.isLoadingRate = false
                state.errorMessage = "환율 조회 실패: \(error.localizedDescription)"
                return .none

            // MARK: 저장
            case .saveButtonTapped:
                guard state.canSave else { return .none }

                state.isSubmitting = true

                let rate = Double(state.exchangeRate) ?? state.travel.baseExchangeRate
                let trimmedTitle = state.title.trimmingCharacters(in: .whitespacesAndNewlines)

                let input = UpdateTravelInput(
                    title: trimmedTitle,
                    startDate: state.startDate,
                    endDate: state.endDate,
                    countryCode: state.selectedCountryCode ?? "KR",
                    koreanCountryName: state.selectedCountryName ?? "한국",
                    baseCurrency: state.selectedCurrency ?? "KRW",
                    baseExchangeRate: state.selectedCountryCode == "KR" ? 1 : rate
                )

                return .run {
                    [updateTravelUseCase,
                     travelId = state.travel.id,
                     input] send in
                    do {
                        let updated = try await updateTravelUseCase.execute(id: travelId, input: input)
                        await send(.updateResponse(.success(updated)))
                    } catch {
                        await send(.updateResponse(.failure(error)))
                    }
                }

            case .updateResponse(.success(let updated)):
                state.isSubmitting = false
                let previous = state.travel
                let mergedMembers = updated.members.isEmpty ? previous.members : updated.members

                state.travel = Travel(
                    id: updated.id,
                    title: updated.title,
                    startDate: updated.startDate,
                    endDate: updated.endDate,
                    countryCode: updated.countryCode,
                    koreanCountryName: updated.koreanCountryName,
                    baseCurrency: updated.baseCurrency,
                    baseExchangeRate: updated.baseExchangeRate,
                    destinationCurrency: updated.destinationCurrency,
                    inviteCode: updated.inviteCode ?? previous.inviteCode,
                    deepLink: updated.deepLink ?? previous.deepLink,
                    status: updated.status,
                    role: updated.role ?? previous.role,
                    createdAt: updated.createdAt,
                    ownerName: updated.ownerName,
                    members: mergedMembers,
                    currencies: previous.currencies
                )

                state.title = updated.title
                state.startDate = updated.startDate
                state.endDate = updated.endDate
                state.selectedCountryName = updated.koreanCountryName
                state.selectedCountryCode = updated.countryCode
                state.selectedCurrency = updated.baseCurrency
                state.exchangeRate = String(updated.baseExchangeRate)

                return .merge(
                    .send(.updated(state.travel)),
                    .run { _ in
                        await MainActor.run {
                            ToastManager.shared.showSuccess("수정이 완료되었어요.")
                        }
                    }
                )

            case .updateResponse(.failure(let error)):
                state.isSubmitting = false
                state.errorMessage = "수정 실패: \(error.localizedDescription)"
                return .none

            case .updated:
                return .none

            case .errorDismissed:
                state.errorMessage = nil
                return .none

            case .binding:
                return .none
            }
        }
    }
}
