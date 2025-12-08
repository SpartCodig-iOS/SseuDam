//
//  ExpenseCategoryTag.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 11/28/25.
//

import SwiftUI
import Domain
import DesignSystem

public struct ExpenseCategoryTag: View {
    private let category: ExpenseCategory

    public init(category: ExpenseCategory) {
        self.category = category
    }

    public var body: some View {
        Text(category.displayName)
            .font(.app(.caption1, weight: .medium))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch category {
        case .transportation:
            return .transportation100
        case .foodAndDrink:
            return .food100
        case .accommodation:
            return .primary100
        case .shopping:
            return .shopping100
        case .activity, .other:
            return .gray1
        }
    }

    private var foregroundColor: Color {
        switch category {
        case .transportation:
            return .transportation500
        case .foodAndDrink:
            return .food500
        case .accommodation:
            return .primary500
        case .shopping:
            return .white
        case .activity, .other:
            return .gray5
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ExpenseCategoryTag(category: .transportation)
        ExpenseCategoryTag(category: .foodAndDrink)
        ExpenseCategoryTag(category: .accommodation)
        ExpenseCategoryTag(category: .activity)
        ExpenseCategoryTag(category: .shopping)
        ExpenseCategoryTag(category: .other)
    }
    .padding()
}
