//
//  ExpressRatesProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 27.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct CommonExpressRatesProvider {
    @Injected(\.quotesRepository) private var quotesRepository: TokenQuotesRepository

    /// Collect quotes for calculate fiat balance
    private var quotes: Quotes {
        return quotesRepository.quotes
    }
}

// MARK: - FiatRatesProviding

extension CommonExpressRatesProvider: ExpressRatesProvider {
    func hasRates(for currency: ExpressCurrency) -> Bool {
        return quotesRepository.quote(for: currency) != nil
    }

    func hasRates(for blockchain: ExpressBlockchain) -> Bool {
        return quotes[blockchain.currencyId] != nil
    }

    func getFiat(for currency: ExpressCurrency, amount: Decimal) -> Decimal? {
        if let id = currency.currencyId, let rate = quotes[id]?.price {
            return mapToFiat(amount: amount, rate: rate)
        }

        return nil
    }

    func getFiat(for blockchain: ExpressBlockchain, amount: Decimal) -> Decimal? {
        if let rate = quotes[blockchain.currencyId]?.price {
            return mapToFiat(amount: amount, rate: rate)
        }

        return nil
    }

    func getFiat(for currency: ExpressCurrency, amount: Decimal) async throws -> Decimal {
        guard let currencyId = currency.currencyId else {
            throw CommonError.noData
        }

        let rate = try await quotesRepository.quote(for: currencyId).price
        return mapToFiat(amount: amount, rate: rate)
    }

    func getFiat(for blockchain: ExpressBlockchain, amount: Decimal) async throws -> Decimal {
        let rate = try await quotesRepository.quote(for: blockchain.currencyId).price
        return mapToFiat(amount: amount, rate: rate)
    }

    func getFiat(for currencies: [ExpressCurrency: Decimal]) async throws -> [ExpressCurrency: Decimal] {
        let ids = currencies.keys.compactMap { $0.currencyId }
        await quotesRepository.loadQuotes(currencyIds: ids)

        return currencies.reduce(into: [:]) { result, args in
            let (currency, amount) = args
            if let fiat = getFiat(for: currency, amount: amount) {
                result[currency] = fiat
            }
        }
    }
}

// MARK: - Private

private extension CommonExpressRatesProvider {
    func mapToFiat(amount: Decimal, rate: Decimal) -> Decimal {
        let fiatValue = amount * rate
        if fiatValue == 0 {
            return 0
        }

        return max(fiatValue, 0.01).rounded(scale: 2, roundingMode: .plain)
    }
}
