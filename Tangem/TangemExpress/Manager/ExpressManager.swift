//
//  ExpressManager.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 07.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol ExpressManager {
    func getAmount() -> Decimal?
    func getExpressItems() -> ExpressItems
    func getReferrerAccount() -> ExpressReferrerAccount?
    func getExpressApprovePolicy() -> ExpressApprovePolicy
    func getExpressGasPricePolicy() -> ExpressGasPricePolicy
    func isEnoughAllowance() -> Bool

    func update(swappingItems: ExpressItems)
    func update(amount: Decimal?)
    func update(approvePolicy: ExpressApprovePolicy)
    func update(gasPricePolicy: ExpressGasPricePolicy)

    @discardableResult
    func refreshBalances() async -> ExpressItems
    func refresh(type: ExpressManagerRefreshType) async -> ExpressAvailabilityState

    /// Call it to save transaction in pending list
    func didSendApproveTransaction(swappingTxData: ExpressTransactionData)
}
