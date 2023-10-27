//
//  ExpressGasPricePolicy.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 13.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

public enum ExpressGasPricePolicy: Hashable, CaseIterable {
    case normal
    case priority

    public func increased(value: Int) -> Int {
        switch self {
        case .normal:
            return value
        case .priority:
            return value * 150 / 100
        }
    }
}
