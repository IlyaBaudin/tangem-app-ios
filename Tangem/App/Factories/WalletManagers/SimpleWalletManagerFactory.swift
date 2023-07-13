//
//  SimpleWalletManagerFactory.swift
//  Tangem
//
//  Created by Alexander Osokin on 27.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

struct SimpleWalletManagerFactory: AnyWalletManagerFactory {
    private let addressTypesConfig: AddressTypesConfig

    init(addressTypesConfig: AddressTypesConfig) {
        self.addressTypesConfig = addressTypesConfig
    }

    func makeWalletManager(for token: StorageEntry, keys: [CardDTO.Wallet]) throws -> WalletManager {
        let blockchain = token.blockchainNetwork.blockchain

        guard let walletPublicKey = keys.first(where: { $0.curve == blockchain.curve })?.publicKey else {
            throw CommonError.noData
        }

        let factory = WalletManagerFactoryProvider().factory
        let addressTypes = addressTypesConfig.addressTypes(for: blockchain)
        let publicKey = Wallet.PublicKey(seedKey: walletPublicKey, derivation: .none)

        // One publicKey for all address types
        let publicKeys: [AddressType: Wallet.PublicKey] = addressTypes.reduce(into: [:]) { $0[$1] = publicKey }
        let walletManager = try factory.makeWalletManager(blockchain: blockchain, publicKeys: publicKeys)

        walletManager.addTokens(token.tokens)
        return walletManager
    }
}
