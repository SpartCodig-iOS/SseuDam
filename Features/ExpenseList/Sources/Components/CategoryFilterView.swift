//
//  CategoryFilterView.swift
//  ExpenseListFeature
//
//  Created by 홍석현 on 12/15/25.
//

import SwiftUI
import DesignSystem
import Domain

struct CategoryFilterView: View {
    @Binding var selectedCategory: ExpenseCategory?

    var body: some View {
        HStack {
            Spacer()
            Menu {
                Button {
                    selectedCategory = nil
                } label: {
                    HStack {
                        Text("전체")
                        if selectedCategory == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack {
                            Text(category.displayName)
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedCategory?.displayName ?? "전체")
                        .font(.app(.caption1, weight: .semibold))
                        .foregroundStyle(Color.gray7)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.gray5)
                }
            }
        }
        .padding(16)
    }
}

#Preview {
    CategoryFilterView(selectedCategory: .constant(nil))
}
