//
//  BasicSettingView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/30/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

// MARK: - 기본 설정 섹션
struct BasicSettingView: View {
    @Bindable var store: StoreOf<BasicSettingFeature>
    @State private var isEditing = false
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    @State private var showCountrySheet = false

    public init(store: StoreOf<BasicSettingFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "기본 설정", isOWner: store.isOwner, isEditing: $isEditing)

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("여행 이름")
                        .font(.app(.body, weight: .medium))
                        .foregroundColor(.gray7)

                    if isEditing {
                        TextField("여행 이름을 입력하세요", text: $store.title.sending(\.titleChanged))
                            .font(.app(.title3, weight: .medium))
                            .foregroundStyle(Color.appBlack)
                    } else {
                        Text(store.title)
                            .font(.app(.title3, weight: .medium))
                            .foregroundStyle(Color.appBlack)
                    }
                }
                .padding(.horizontal, 10)

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("시작일")
                            .font(.app(.body, weight: .medium))
                            .foregroundColor(.gray7)

                        if isEditing {
                            Button {
                                showStartPicker.toggle()
                            } label: {
                                HStack {
                                    Image(assetName: "calendar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 18)
                                        .foregroundStyle(Color.gray8)
                                    Text(format(store.startDate))
                                        .font(.app(.title3, weight: .medium))
                                        .foregroundStyle(Color.appBlack)
                                }
                            }
                        } else {
                            Text(format(store.startDate))
                                .font(.app(.title3, weight: .medium))
                                .foregroundStyle(Color.appBlack)
                        }
                    }
                    .padding(.horizontal, 10)

                    Spacer()

                    Divider()
                        .frame(width: 1, height: 46)
                        .foregroundStyle(Color.gray1)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("종료일")
                            .font(.app(.body, weight: .medium))
                            .foregroundColor(.gray7)

                        if isEditing {
                            Button {
                                showEndPicker.toggle()
                            } label: {
                                HStack {
                                    Image(assetName: "calendar")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 18)
                                        .foregroundStyle(Color.gray8)
                                    Text(format(store.endDate))
                                        .font(.app(.title3, weight: .medium))
                                        .foregroundStyle(Color.appBlack)
                                }
                            }
                        } else {
                            Text(format(store.endDate))
                                .font(.app(.title3, weight: .medium))
                                .foregroundStyle(Color.appBlack)
                        }
                    }
                    .padding(.horizontal, 10)

                    Spacer()
                }
                .sheet(isPresented: $showStartPicker) {
                    DatePicker(
                        "여행 시작",
                        selection: Binding(
                            get: { store.startDate },
                            set: { newValue in
                                store.send(.startDateChanged(newValue))

                                // 종료일 자동 조정
                                if store.endDate < newValue {
                                    store.send(.endDateChanged(newValue))
                                }

                                showStartPicker = false
                            }
                        ),
                        in: Date.now...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.primary50)
                }
                .sheet(isPresented: $showEndPicker) {
                    DatePicker(
                        "여행 종료",
                        selection: Binding(
                            get: { store.endDate },
                            set: { newValue in
                                // 종료일이 시작일보다 이전이면 자동 조정
                                if newValue < store.startDate {
                                    store.send(.endDateChanged(store.startDate))
                                } else {
                                    store.send(.endDateChanged(newValue))
                                }

                                showEndPicker = false
                            }
                        ),
                        in: store.startDate...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.primary50)
                }

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("국가")
                        .font(.app(.body, weight: .medium))
                        .foregroundColor(.gray7)

                    if isEditing {
                        Button {
                            showCountrySheet = true
                        } label: {
                            HStack {
                                Image(assetName: "pencil")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 18)
                                    .foregroundStyle(Color.gray8)
                                Text(store.selectedCountryName ?? "선택")
                                    .font(.app(.title3, weight: .medium))
                                    .foregroundStyle(Color.appBlack)

                                Spacer()
                            }
                        }
                    } else {
                        Text(store.selectedCountryName ?? "-")
                            .font(.app(.title3, weight: .medium))
                            .foregroundStyle(Color.appBlack)
                    }
                }
                .padding(.horizontal, 10)
                .sheet(isPresented: $showCountrySheet) {
                    BasicCountrySelectSheetView(store: store)
                        .presentationDetents([.medium, .large])
                }

                Divider()
                    .foregroundStyle(Color.gray1)
                    .padding(.vertical, 16)


                if store.selectedCountryCode != "KR" {

                    VStack(alignment: .leading, spacing: 8) {

                        Text("화폐")
                            .font(.app(.body, weight: .medium))
                            .foregroundColor(.gray7)

                        if isEditing {
                            // currencies가 여러 개 → 선택 가능
                            if store.currencies.count > 1 {
                                Menu {
                                    ForEach(store.currencies, id: \.self) { cur in
                                        Button(cur) {
                                            store.send(.currencySelected(cur))
                                        }
                                    }
                                } label: {
                                    Text(store.selectedCurrency ?? "화폐 선택")
                                        .foregroundStyle(Color.appBlack)
                                }

                            } else {
                                Text(store.selectedCurrency ?? "-")
                                    .font(.app(.title3, weight: .medium))
                                    .foregroundStyle(Color.appBlack)
                            }

                        } else {
                            Text(store.selectedCurrency ?? "-")
                                .font(.app(.title3, weight: .medium))
                                .foregroundStyle(Color.appBlack)
                        }
                    }
                    .padding(.horizontal, 10)

                    Divider()
                        .foregroundStyle(Color.gray1)
                        .padding(.vertical, 16)
                }


                Button {
                    UIPasteboard.general.string = store.travel.inviteCode
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("초대 코드")
                            .font(.app(.body, weight: .medium))
                            .foregroundColor(.gray7)

                        HStack(spacing: 8) {
                            Image(assetName: "files")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                                .foregroundStyle(Color.gray8)

                            Text(store.travel.inviteCode ?? "초대코드 없음")
                                .font(.app(.title3, weight: .medium))
                                .foregroundStyle(Color.appBlack)
                        }
                    }
                    .padding(.horizontal, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.appWhite)))
            .onChange(of: isEditing) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    store.send(.saveButtonTapped)
                }
            }
        }
    }
    private func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }

    private func pickerButtonLabel(_ title: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(assetName: "calendar")
                .resizable()
                .scaledToFit()
                .frame(height: 18)
        }
        .foregroundColor(.appBlack)
        .padding(.horizontal, 10)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray2, lineWidth: 1)
        )
    }
}

