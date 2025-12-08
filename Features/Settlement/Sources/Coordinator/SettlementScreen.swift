//
//  SettlementScreen.swift
//  MainFeature
//
//  Created by 홍석현 on 11/30/25.
//

import Foundation
import ComposableArchitecture
import TCACoordinators
import SaveExpenseFeature

@Reducer
public enum SettlementScreen {
    case settlement(SettlementFeature)
    case saveExpense(SaveExpenseFeature)
}

extension SettlementScreen.State: Equatable {}
