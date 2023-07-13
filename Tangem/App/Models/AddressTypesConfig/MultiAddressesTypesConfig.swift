//
//  MultiAddressesTypesConfig.swift
//  Tangem
//
//  Created by Sergey Balashov on 10.07.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

struct MultiAddressesTypesConfig: AddressTypesConfig {
    func addressTypes(for blockchain: Blockchain) -> [AddressType] {
        switch blockchain {
        case .bitcoin:
            return [.default, .legacy]
        case .litecoin:
            return [.default, .legacy]
        case .bitcoinCash:
            return [.default, .legacy]
        case .cardano(let shelley):
            guard shelley else {
                return [.default]
            }
            return [.default, .legacy]
        case .stellar,
                .solana,
                .ethereum,
                .ethereumPoW,
                .ethereumFair,
                .saltPay,
                .ethereumClassic,
                .rsk,
                .binance,
                .xrp,
                .ducatus,
                .tezos,
                .dogecoin,
                .bsc,
                .polygon,
                .avalanche,
                .fantom,
                .polkadot,
                .kusama,
                .azero,
                .tron,
                .arbitrum,
                .dash,
                .gnosis,
                .optimism,
                .ton,
                .kava,
                .kaspa,
                .ravencoin,
                .cosmos,
                .terraV1, .terraV2,
                .cronos,
                .telos:
            return [.default]
        }
    }
}
