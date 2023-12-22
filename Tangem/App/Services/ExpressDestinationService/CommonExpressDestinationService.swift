//
//  CommonExpressDestinationService.swift
//  Tangem
//
//  Created by Sergey Balashov on 14.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import TangemSwapping

struct CommonExpressDestinationService {
    @Injected(\.swapAvailabilityProvider) private var swapAvailabilityProvider: SwapAvailabilityProvider

    private let pendingTransactionRepository: ExpressPendingTransactionRepository
    private let walletModelsManager: WalletModelsManager
    private let expressRepository: ExpressRepository

    init(
        pendingTransactionRepository: ExpressPendingTransactionRepository,
        walletModelsManager: WalletModelsManager,
        expressRepository: ExpressRepository
    ) {
        self.pendingTransactionRepository = pendingTransactionRepository
        self.walletModelsManager = walletModelsManager
        self.expressRepository = expressRepository
    }
}

// MARK: - ExpressDestinationService

extension CommonExpressDestinationService: ExpressDestinationService {
    func getDestination(source: WalletModel) async throws -> WalletModel {
        let availablePairs = await expressRepository.getPairs(from: source)
        let searchableWalletModels = walletModelsManager.walletModels.filter { wallet in
            let isNotSource = wallet.id != source.id
            let isAvailable = swapAvailabilityProvider.canSwap(tokenItem: wallet.tokenItem)
            let isNotCustom = !wallet.isCustom
            let hasPair = availablePairs.contains(where: { $0.destination == wallet.expressCurrency })

            return isNotSource && isAvailable && isNotCustom && hasPair
        }

        AppLog.shared.debug("[Express] \(self) has searchableWalletModels: \(searchableWalletModels.map { ($0.expressCurrency, $0.fiatBalance) })")
        if let lastTransactionWalletModel = getLastTransactionWalletModel(in: searchableWalletModels) {
            AppLog.shared.debug("[Express] \(self) selected lastTransactionWalletModel: \(lastTransactionWalletModel.expressCurrency)")
            return lastTransactionWalletModel
        }

        let walletModelsWithPositiveBalance = searchableWalletModels.filter { ($0.fiatValue ?? 0) > 0 }

        // If all wallets without balance
        if walletModelsWithPositiveBalance.isEmpty, let first = searchableWalletModels.first {
            AppLog.shared.debug("[Express] \(self) has a zero wallets with positive balance then selected: \(first.expressCurrency)")
            return first
        }

        // If user has wallets with balance then sort they
        let sortedWallets = walletModelsWithPositiveBalance.sorted(by: { ($0.fiatValue ?? 0) > ($1.fiatValue ?? 0) })

        // Start searching destination with available providers
        if let maxBalanceWallet = sortedWallets.first {
            AppLog.shared.debug("[Express] \(self) selected maxBalanceWallet: \(maxBalanceWallet.expressCurrency)")
            return maxBalanceWallet
        }

        AppLog.shared.debug("[Express] \(self) couldn't find acceptable wallet")
        throw ExpressDestinationServiceError.destinationNotFound
    }

    private func getLastTransactionWalletModel(in searchableWalletModels: [WalletModel]) -> WalletModel? {
        let transactions = pendingTransactionRepository.pendingTransactions

        guard
            let lastTransactionCurrency = transactions.last?.destinationTokenTxInfo.tokenItem.expressCurrency,
            let lastWallet = searchableWalletModels.first(where: { $0.expressCurrency == lastTransactionCurrency })
        else {
            return nil
        }

        return lastWallet
    }
}

extension CommonExpressDestinationService: CustomStringConvertible {
    var description: String {
        "ExpressDestinationService"
    }
}