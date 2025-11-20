//
//  DIContainer.swift
//  SseuDamApp
//
//  Created by 김민희 on 11/20/25.
//

import Foundation
import Swinject

@MainActor
final class DIContainer {
    static let shared = DIContainer()
    let container = Container()

    private init() {
        register()
    }
    
    private func register() {

    }
}
