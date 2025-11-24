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
                            get: { startDate ?? Date() },
                            set: { newValue in
                                startDate = newValue
                                if let end = endDate, end < newValue {
                                    endDate = newValue
                                }
                                showStartPicker = false
                            }
                        ),
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
                            get: { endDate ?? Date() },
                            set: { newValue in
                                endDate = newValue
                                if let start = startDate, newValue < start {
                                    endDate = start
                                } else {
                                    endDate = newValue
                                }
                                showEndPicker = false
                            }
                        ),
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
