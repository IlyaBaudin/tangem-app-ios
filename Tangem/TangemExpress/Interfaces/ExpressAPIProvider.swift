//
//  ExpressProvider.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 08.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol ExpressAPIProvider {
    func fetchQuote(items: ExpressItems, amount: String, referrer: ExpressReferrerAccount?) async throws -> ExpressQuoteDataModel
    func fetchExpressData(
        items: ExpressItems,
        walletAddress: String,
        amount: String,
        referrer: ExpressReferrerAccount?
    ) async throws -> ExpressDataModel

    func fetchSpenderAddress(for blockchain: ExpressBlockchain) async throws -> String
}
