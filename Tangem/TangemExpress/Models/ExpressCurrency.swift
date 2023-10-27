//
//  ExpressCurrency.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 06.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public struct ExpressCurrency {
    public let tokenItem: TokenItem

    public var id: String? { tokenItem.id }
    public var currencyId: String? { tokenItem.currencyId }
    public var blockchain: ExpressBlockchain { tokenItem.blockchain }
    public var name: String { tokenItem.name }
    public var symbol: String { tokenItem.currencySymbol }
    public var decimalCount: Int { tokenItem.decimalCount }
    public var contractAddress: String? { tokenItem.contractAddress }
    public var isToken: Bool { tokenItem.isToken }

    public init(tokenItem: TokenItem) {
        self.tokenItem = tokenItem
    }
}

extension ExpressCurrency: Hashable {
    public static func == (lhs: ExpressCurrency, rhs: ExpressCurrency) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

public extension ExpressCurrency {
    func convertToWEI(value: Decimal) -> Decimal {
        let decimalValue = pow(10, decimalCount)
        return value * decimalValue
    }

    func convertFromWEI(value: Decimal) -> Decimal {
        let decimalValue = pow(10, decimalCount)
        return value / decimalValue
    }
}
