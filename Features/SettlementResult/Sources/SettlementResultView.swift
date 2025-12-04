//
//  SettlementResultView.swift
//  SseuDam
//
//  Created by 홍석현 on 12/4/25.
//

import SwiftUI
import DesignSystem

public struct SettlementResultView: View {
    public init() {}

    public var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Settlementresult Feature")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .navigationTitle("Settlementresult")
    }
}

#Preview {
    NavigationView {
        SettlementResultView()
    }
}
