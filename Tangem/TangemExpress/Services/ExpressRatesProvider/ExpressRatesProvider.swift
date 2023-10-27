//
//  FiatRatesProviding.swift
//  Tangem
//
//  Created by Sergey Balashov on 19.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol ExpressRatesProvider {
    func hasRates(for currency: ExpressCurrency) -> Bool
    func hasRates(for blockchain: ExpressBlockchain) -> Bool

    func getFiat(for currency: ExpressCurrency, amount: Decimal) -> Decimal?
    func getFiat(for blockchain: ExpressBlockchain, amount: Decimal) -> Decimal?

    func getFiat(for currency: ExpressCurrency, amount: Decimal) async throws -> Decimal
    func getFiat(for blockchain: ExpressBlockchain, amount: Decimal) async throws -> Decimal
    func getFiat(for currencies: [ExpressCurrency: Decimal]) async throws -> [ExpressCurrency: Decimal]
}
