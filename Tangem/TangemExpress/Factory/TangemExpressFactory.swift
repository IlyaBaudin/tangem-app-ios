//
//  TangemExpressFactory.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 15.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSwapping
import BlockchainSdk

public typealias ExpressBlockchain = BlockchainSdk.Blockchain

public struct TangemExpressFactory {
    public init() {}

    public func makeExpressManager(
        walletDataProvider: ExpressWalletDataProvider,
        referrer: ExpressReferrerAccount? = nil,
        source: ExpressCurrency,
        destination: ExpressCurrency?
    ) -> ExpressManager {
        let logger = AppLog.shared
        let swappingItems = ExpressItems(source: source, destination: destination)
        let provider = CommonExpressProvider()

        return CommonExpressManager(
            swappingProvider: provider,
            walletDataProvider: walletDataProvider,
            logger: logger,
            referrer: referrer,
            swappingItems: swappingItems
        )
    }
}

struct CommonExpressProvider: ExpressAPIProvider {
    func fetchQuote(items: ExpressItems, amount: String, referrer: ExpressReferrerAccount?) async throws -> ExpressQuoteDataModel {
        fatalError()
    }

    func fetchExpressData(items: ExpressItems, walletAddress: String, amount: String, referrer: ExpressReferrerAccount?) async throws -> ExpressDataModel {
        fatalError()
    }

    func fetchSpenderAddress(for blockchain: ExpressBlockchain) async throws -> String {
        fatalError()
    }
}
