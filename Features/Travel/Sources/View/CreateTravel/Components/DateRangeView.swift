//
//  DateRangeView.swift
//  TravelFeature
//
//  Created by 김민희 on 11/24/25.
//

import SwiftUI
import DesignSystem

struct DateRangeView: View {
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @State private var showStartPicker = false
    @State private var showEndPicker = false
    let title: String
    let essential: Bool

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                if essential {
                    Text("*")
                        .font(.app(.title3, weight: .medium))
                        .foregroundColor(.red)
                }

                Text(title)
                    .font(.app(.title3, weight: .medium))
                    .foregroundStyle(Color.appBlack)
            }

            HStack(spacing: 4) {
                // MARK: 시작 날짜
                DateFieldView(
                    title: "시작",
                    date: startDate
                ) {
                    showStartPicker.toggle()
                }
                .sheet(isPresented: $showStartPicker) {
                    DatePicker(
                        "여행 시작",
                        selection: Binding(
                            get: { startDate ?? today },
                            set: { newValue in
                                startDate = newValue

                                // 종료일이 시작일보다 이전이라면 자동 조정
                                if let end = endDate, end < newValue {
                                    endDate = newValue
                                }

                                showStartPicker = false
                            }
                        ),
                        // 오늘 이후 날짜만 선택 가능
                        in: today...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .presentationBackground(Color.primary50)
                }

                Text("~")
                    .foregroundColor(.gray)

                DateFieldView(
                    title: "종료",
                    date: endDate
                ) {
                    showEndPicker.toggle()
                }
                .sheet(isPresented: $showEndPicker) {
                    DatePicker(
                        "여행 종료",
                        selection: Binding(
                            get: { endDate ?? (startDate ?? today) },
                            set: { newValue in
                                // 종료일이 시작일보다 이전이라면 자동 조정
                                if let start = startDate, newValue < start {
                                    endDate = start
                                } else {
                                    endDate = newValue
                                }
                                showEndPicker = false
                            }
                        ),
                        // 종료일은 시작일 이후부터 선택 가능
                        in: (startDate ?? today)...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

#Preview {
    DateRangeView(startDate: .constant(nil), endDate: .constant(nil), title: "여행 기간", essential: true)
}
