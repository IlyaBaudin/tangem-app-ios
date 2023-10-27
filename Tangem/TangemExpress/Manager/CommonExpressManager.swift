//
//  CommonExpressManager.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 24.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import struct TangemSwapping.EthereumGasDataModel

class CommonExpressManager {
    // MARK: - Dependencies

    private let swappingProvider: ExpressAPIProvider
    private let walletDataProvider: ExpressWalletDataProvider
    private let logger: ExpressLogger
    private let referrer: ExpressReferrerAccount?

    // MARK: - Internal

    private let swappingItems: ThreadSafeContainer<ExpressItems>
    private var amount: Decimal?
    private var approvePolicy: ExpressApprovePolicy = .unlimited
    private var gasPricePolicy: ExpressGasPricePolicy = .normal
    private let spenderAddresses: ThreadSafeContainer<[ExpressBlockchain: String]> = [:]
    private let swappingAllowanceLimit: ThreadSafeContainer<[ExpressCurrency: Decimal]> = [:]
    // Cached addresses for check approving transactions
    private let pendingTransactions: ThreadSafeContainer<[ExpressCurrency: PendingTransactionState]> = [:]
    private var bag: Set<AnyCancellable> = []

    private var formattedAmount: String? {
        guard let amount = amount else {
            logger.debug("[Swap] Amount isn't set")
            return nil
        }

        return String(describing: swappingItems.source.convertToWEI(value: amount))
    }

    private var walletAddress: String? {
        walletDataProvider.getWalletAddress(currency: swappingItems.source)
    }

    init(
        swappingProvider: ExpressAPIProvider,
        walletDataProvider: ExpressWalletDataProvider,
        logger: ExpressLogger,
        referrer: ExpressReferrerAccount?,
        swappingItems: ExpressItems
    ) {
        self.swappingProvider = swappingProvider
        self.walletDataProvider = walletDataProvider
        self.logger = logger
        self.referrer = referrer
        self.swappingItems = .init(swappingItems)

        Task { [weak self] in
            await self?.refreshBalances()
        }
    }
}

// MARK: - ExpressManager

extension CommonExpressManager: ExpressManager {
    func getAmount() -> Decimal? {
        return amount
    }

    func getExpressItems() -> ExpressItems {
        return swappingItems.read()
    }

    func getReferrerAccount() -> ExpressReferrerAccount? {
        return referrer
    }

    func getExpressApprovePolicy() -> ExpressApprovePolicy {
        return approvePolicy
    }

    func getExpressGasPricePolicy() -> ExpressGasPricePolicy {
        return gasPricePolicy
    }

    func isEnoughAllowance() -> Bool {
        // These local variables are introduced as part of the IOS-4043 bug investigation;
        // feel free to get rid of them if the bug is fixed
        let sourceItems = swappingItems.source
        let allowanceLimit = swappingAllowanceLimit

        guard
            sourceItems.isToken,
            let amount = amount,
            amount > 0
        else {
            return true
        }

        guard let allowance = allowanceLimit[sourceItems] else {
            return false
        }

        return amount <= allowance
    }

    func update(swappingItems: ExpressItems) {
        self.swappingItems.mutate { $0 = swappingItems }
    }

    func update(amount: Decimal?) {
        self.amount = amount
    }

    func update(approvePolicy: ExpressApprovePolicy) {
        self.approvePolicy = approvePolicy
    }

    func update(gasPricePolicy: ExpressGasPricePolicy) {
        self.gasPricePolicy = gasPricePolicy
    }

    func refreshBalances() async -> ExpressItems {
        try? await updateExpressItemsBalances()
        return swappingItems.read()
    }

    func refresh(type: ExpressManagerRefreshType) async -> ExpressAvailabilityState {
        return await refreshValues(refreshType: type)
    }

    func didSendApproveTransaction(swappingTxData: ExpressTransactionData) {
        pendingTransactions.mutate { value in
            value[swappingTxData.sourceExpressCurrency] = .pending(destination: swappingTxData.destinationAddress)
        }
        swappingAllowanceLimit.mutate { value in
            value[swappingTxData.sourceExpressCurrency] = nil
        }
    }
}

// MARK: - Requests

private extension CommonExpressManager {
    func refreshValues(refreshType: ExpressManagerRefreshType = .full) async -> ExpressAvailabilityState {
        do {
            try await updateExpressItemsBalances()

            guard isEnoughAmountForExpress() else {
                return try await loadPreview()
            }

            switch swappingItems.source.tokenItem {
            case .blockchain:
                return try await loadDataForCoinExpress()
            case .token:
                return try await loadDataForTokenExpress()
            }
        } catch {
            if Task.isCancelled {
                return .idle
            }

            return .requiredRefresh(occurredError: error)
        }
    }

    func loadDataForTokenExpress() async throws -> ExpressAvailabilityState {
        let spender = try await getSpenderAddress()
        try await updateExpressAmountAllowance(spender: spender)

        try Task.checkCancellation()

        // If allowance is enough just load the data for swap this token
        if isEnoughAllowance() {
            // If we saved pending transaction just remove it
            if hasPendingTransaction() {
                pendingTransactions.mutate { [source = swappingItems.source] value in
                    value[source] = nil
                }
            }

            return try await loadDataForCoinExpress()
        }

        // If approving transaction was sent but allowance still zero
        if hasPendingTransaction(), !isEnoughAllowance() {
            return try await loadPreview()
        }

        // If haven't allowance and haven't pending transaction just load data for approve
        return try await loadApproveData()
    }

    func loadPreview() async throws -> ExpressAvailabilityState {
        return try await .preview(mapExpressPreviewData(from: getExpressQuoteDataModel()))
    }

    func loadDataForCoinExpress() async throws -> ExpressAvailabilityState {
        let swappingData = try await getExpressTxDataModel()

        try Task.checkCancellation()

        let gasOptions = try await getGasOptions(swappingData: swappingData)

        try Task.checkCancellation()

        guard let gas = gasOptions.first(where: { $0.policy == gasPricePolicy }) else {
            throw ExpressManagerError.gasModelNotFound
        }

        let data = try mapToExpressTransactionData(swappingData: swappingData, gas: gas)
        let availabilityModel = try await mapToExpressAvailabilityModel(transactionData: data, gasOptions: gasOptions)

        try Task.checkCancellation()

        return .available(availabilityModel)
    }

    func loadApproveData() async throws -> ExpressAvailabilityState {
        // We need to load quoteData for "from" and "to" amounts
        async let quoteData = getExpressQuoteDataModel()
        async let spender = getSpenderAddress()

        let approvedData = try await getExpressApprovedDataModel(spender: spender)
        let gasOptions = try await getGasOptions(quoteData: quoteData, approvedData: approvedData)

        try Task.checkCancellation()

        guard let gas = gasOptions.first(where: { $0.policy == gasPricePolicy }) else {
            throw ExpressManagerError.gasModelNotFound
        }

        let data = try await mapToExpressTransactionData(quoteData: quoteData, approvedData: approvedData, gas: gas)
        let availabilityModel = try await mapToExpressAvailabilityModel(transactionData: data, gasOptions: gasOptions)

        try Task.checkCancellation()

        return .available(availabilityModel)
    }

    func updateExpressAmountAllowance(spender: String) async throws {
        let allowance = try await walletDataProvider.getAllowance(for: swappingItems.source, from: spender)
        swappingAllowanceLimit.mutate { [source = swappingItems.source] value in
            value[source] = allowance
        }

        logger.debug("Token \(swappingItems.source.name) allowance \(allowance)")
    }

    func getExpressQuoteDataModel() async throws -> ExpressQuoteDataModel {
        guard let formattedAmount = formattedAmount else {
            throw ExpressManagerError.amountNotFound
        }

        return try await swappingProvider.fetchQuote(
            items: swappingItems.read(),
            amount: formattedAmount,
            referrer: referrer
        )
    }

    /// Get the spender's address. The router that will provide the exchange
    func getSpenderAddress() async throws -> String {
        let blockchain = swappingItems.source.blockchain

        if let spender = spenderAddresses[blockchain] {
            return spender
        }

        let spender = try await swappingProvider.fetchSpenderAddress(for: blockchain)
        spenderAddresses.mutate { [blockchain] value in
            value[blockchain] = spender
        }

        return spender
    }

    func getExpressApprovedDataModel(spender: String) throws -> ExpressApprovedDataModel {
        guard let contractAddress = swappingItems.source.contractAddress else {
            throw ExpressManagerError.contractAddressNotFound
        }

        let data = walletDataProvider.getApproveData(for: swappingItems.source, from: spender, policy: approvePolicy)
        return ExpressApprovedDataModel(data: data, tokenAddress: contractAddress, value: 0)
    }

    func getExpressTxDataModel() async throws -> ExpressDataModel {
        guard let walletAddress else {
            throw ExpressManagerError.walletAddressNotFound
        }

        guard let formattedAmount = formattedAmount else {
            throw ExpressManagerError.amountNotFound
        }

        return try await swappingProvider.fetchExpressData(
            items: swappingItems.read(),
            walletAddress: walletAddress,
            amount: formattedAmount,
            referrer: referrer
        )
    }

    func updateExpressItemsBalances() async throws {
        let source = swappingItems.source
        let balance = try await walletDataProvider.getBalance(for: source)

        if let destination = swappingItems.destination {
            let balance = try await walletDataProvider.getBalance(for: destination)
            if swappingItems.destinationBalance != balance {
                swappingItems.mutate { $0.destinationBalance = balance }
            }
        }

        if swappingItems.sourceBalance != balance {
            swappingItems.mutate { $0.sourceBalance = balance }
        }
    }

    func isEnoughAmountForExpress() -> Bool {
        guard let sendValue = amount else {
            return true
        }

        return swappingItems.sourceBalance >= sendValue
    }

    func hasPendingTransaction() -> Bool {
        pendingTransactions[swappingItems.source] != nil
    }
}

// MARK: - Mapping

private extension CommonExpressManager {
    func mapExpressPreviewData(from quoteData: ExpressQuoteDataModel) throws -> ExpressPreviewData {
        guard let destination = swappingItems.destination else {
            throw ExpressManagerError.destinationNotFound
        }

        let expectedAmount = destination.convertFromWEI(value: quoteData.toTokenAmount)

        return ExpressPreviewData(
            expectedAmount: expectedAmount,
            isPermissionRequired: !isEnoughAllowance(),
            hasPendingTransaction: hasPendingTransaction(),
            isEnoughAmountForExpress: isEnoughAmountForExpress()
        )
    }

    func mapToExpressTransactionData(swappingData: ExpressDataModel, gas: EthereumGasDataModel) throws -> ExpressTransactionData {
        guard let destination = swappingItems.destination else {
            throw ExpressManagerError.destinationNotFound
        }

        let value = swappingItems.source.convertFromWEI(value: swappingData.value)

        return ExpressTransactionData(
            sourceExpressCurrency: swappingItems.source,
            sourceBlockchain: swappingItems.source.blockchain,
            destinationExpressCurrency: destination,
            sourceAddress: swappingData.sourceAddress,
            destinationAddress: swappingData.destinationAddress,
            txData: swappingData.txData,
            sourceAmount: swappingData.sourceExpressCurrencyAmount,
            destinationAmount: swappingData.destinationExpressCurrencyAmount,
            value: value,
            gas: gas
        )
    }

    func mapToExpressTransactionData(
        quoteData: ExpressQuoteDataModel,
        approvedData: ExpressApprovedDataModel,
        gas: EthereumGasDataModel
    ) throws -> ExpressTransactionData {
        guard let destination = swappingItems.destination else {
            throw ExpressManagerError.destinationNotFound
        }

        guard let walletAddress = walletAddress else {
            throw ExpressManagerError.walletAddressNotFound
        }

        return ExpressTransactionData(
            sourceExpressCurrency: swappingItems.source,
            sourceBlockchain: swappingItems.source.blockchain,
            destinationExpressCurrency: destination,
            sourceAddress: walletAddress,
            destinationAddress: approvedData.tokenAddress,
            txData: approvedData.data,
            sourceAmount: quoteData.fromTokenAmount,
            destinationAmount: quoteData.toTokenAmount,
            value: approvedData.value,
            gas: gas
        )
    }

    func mapToExpressAvailabilityModel(
        transactionData: ExpressTransactionData,
        gasOptions: [EthereumGasDataModel]
    ) async throws -> ExpressAvailabilityModel {
        let amount = transactionData.sourceExpressCurrency.convertFromWEI(value: transactionData.sourceAmount)
        let sourceBalance = swappingItems.sourceBalance
        let coinBalance = try await walletDataProvider.getBalance(for: swappingItems.source.blockchain)

        var isEnoughAmountForFee: [ExpressGasPricePolicy: Bool] = [:]
        var isEnoughAmountForExpress: [ExpressGasPricePolicy: Bool] = [:]

        for option in gasOptions {
            switch swappingItems.source.tokenItem {
            case .blockchain:
                isEnoughAmountForFee[option.policy] = sourceBalance >= option.fee
                isEnoughAmountForExpress[option.policy] = sourceBalance >= amount + option.fee
            case .token:
                isEnoughAmountForFee[option.policy] = coinBalance >= option.fee
                isEnoughAmountForExpress[option.policy] = sourceBalance >= amount
            }
        }

        let restrictions = ExpressAvailabilityModel.Restrictions(
            isEnoughAmountForExpress: isEnoughAmountForExpress,
            isEnoughAmountForFee: isEnoughAmountForFee,
            isPermissionRequired: !isEnoughAllowance()
        )

        return ExpressAvailabilityModel(
            transactionData: transactionData,
            gasOptions: gasOptions,
            restrictions: restrictions
        )
    }
}

// MARK: - Fee calculation

private extension CommonExpressManager {
    func getGasOptions(swappingData: ExpressDataModel) async throws -> [EthereumGasDataModel] {
        let value = swappingItems.source.convertFromWEI(value: swappingData.value)
        return try await walletDataProvider.getGasOptions(
            blockchain: swappingItems.source.blockchain,
            value: value,
            data: swappingData.txData,
            destinationAddress: swappingData.destinationAddress
        )
    }

    func getGasOptions(
        quoteData: ExpressQuoteDataModel,
        approvedData: ExpressApprovedDataModel
    ) async throws -> [EthereumGasDataModel] {
        let value = swappingItems.source.convertFromWEI(value: approvedData.value)
        return try await walletDataProvider.getGasOptions(
            blockchain: swappingItems.source.blockchain,
            value: value,
            data: approvedData.data,
            destinationAddress: approvedData.tokenAddress
        )
    }
}

extension CommonExpressManager {
    enum PendingTransactionState: Hashable {
        case pending(destination: String)
    }
}
