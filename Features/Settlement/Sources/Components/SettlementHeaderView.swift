//
//  SettlementHeaderView.swift
//  SettlementFeature
//
//  Created by 홍석현 on 11/28/25.
//

import SwiftUI
import DesignSystem

public struct SettlementHeaderView: View {
    let currentDate: String
    let totalAmount: Int
    let startDate: String
    let endDate: String
    let myExpenseAmount: Int
    
    public init(
        currentDate: String,
        totalAmount: Int,
        startDate: String,
        endDate: String,
        myExpenseAmount: Int
    ) {
        self.currentDate = currentDate
        self.totalAmount = totalAmount
        self.startDate = startDate
        self.endDate = endDate
        self.myExpenseAmount = myExpenseAmount
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                // 날짜 선택 (드롭다운 느낌)
                HStack(spacing: 4) {
                    Text(currentDate)
                        .font(.app(.body, weight: .medium))
                        .foregroundStyle(Color.gray7)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.gray5)
                }
                
                
                // 총 지출 금액
                Text("₩\(totalAmount.formatted())")
                    .font(.app(.title1, weight: .semibold))
                    .foregroundStyle(.black)
            }
            .padding(.vertical, 12)
            
            // 하단 정보 (여행 기간 / 내 지출)
            HStack {
                VStack(alignment: .center, spacing: 8) {
                    Text("여행 기간")
                        .font(.app(.caption1, weight: .semibold))
                        .foregroundStyle(Color.gray7)
                    Text("\(startDate) -\n\(endDate)")
                        .font(.app(.title3, weight: .semibold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .center, spacing: 8) {
                    Text("내 지출")
                        .font(.app(.caption1, weight: .semibold))
                        .foregroundStyle(Color.gray7)
                    Text("₩\(myExpenseAmount.formatted())")
                        .font(.app(.title3, weight: .semibold))
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
        }
    }
}

#Preview {
    SettlementHeaderView(
        currentDate: "2024.12.20",
        totalAmount: 255450,
        startDate: "2024.12.20",
        endDate: "2024.12.25",
        myExpenseAmount: 255450
    )
}
