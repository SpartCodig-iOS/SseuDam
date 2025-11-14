//
//  LoginView.swift
//  TestApp
//
//  Created by TestDev on 09-11-25.
//  Copyright © 2025 TestDev. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct LoginView: View {
    public init() {}

    public var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Login Feature")
                .font(.title)
                .fontWeight(.bold)
        }
        .padding()
        .navigationTitle("Login")
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}