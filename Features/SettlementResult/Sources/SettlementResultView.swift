//
//  SettlementResultView.swift
//  SseuDam
//
//  Created by 홍석현 on 12/4/25.
//

import SwiftUI
import DesignSystem

public struct SettlementResultView: View {
    // Mock data - 나중에 Feature에서 받아올 데이터
    private let totalExpenseAmount: Int = 1245000
    private let myExpenseAmount: Int = 520000
    private let totalPersonCount: Int = 5

    private let paymentDue: [PaymentItem] = [
        PaymentItem(id: "1", name: "이영희", amount: 45000),
        PaymentItem(id: "2", name: "이영민", amount: 45000)
    ]

    private let paymentReceivable: [PaymentItem] = [
        PaymentItem(id: "3", name: "박철수", amount: 50000),
        PaymentItem(id: "4", name: "박철", amount: 50000)
    ]

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 헤더 (총 지출, 통계)
                SettlementResultHeaderView(
                    totalExpenseAmount: totalExpenseAmount,
                    myExpenseAmount: myExpenseAmount,
                    totalPersonCount: totalPersonCount
                )

                // 지급 예정 금액
                VStack(spacing: 8) {
                    if !paymentDue.isEmpty {
                        PaymentSectionView(
                            title: "지급 예정 금액",
                            totalAmount: Double(paymentDue.reduce(0) { $0 + $1.amount }),
                            amountColor: .red,
                            payments: paymentDue
                        )
                    }
                    
                    // 수령 예정 금액
                    if !paymentReceivable.isEmpty {
                        PaymentSectionView(
                            title: "수령 예정 금액",
                            totalAmount: Double(paymentReceivable.reduce(0) { $0 + $1.amount }),
                            amountColor: .primary500,
                            payments: paymentReceivable
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color.primary50)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    NavigationView {
        SettlementResultView()
    }
}
