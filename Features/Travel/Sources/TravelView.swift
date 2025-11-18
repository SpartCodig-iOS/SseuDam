//
//  TravelView.swift
//  SseuDam
//
//  Created by SseuDam on2025.
//  Copyright ©2025 com.testdev. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct TravelView: View {
    public init() {}

    public var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Travel Feature")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .navigationTitle("Travel")
    }
}

#Preview {
    NavigationView {
        TravelView()
    }
}
