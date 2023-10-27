//
//  ExpressPreviewData.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 12.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public struct ExpressPreviewData {
    public let expectedAmount: Decimal

    public let isPermissionRequired: Bool
    public let hasPendingTransaction: Bool
    public let isEnoughAmountForExpress: Bool

    public init(
        expectedAmount: Decimal,
        isPermissionRequired: Bool,
        hasPendingTransaction: Bool,
        isEnoughAmountForExpress: Bool
    ) {
        self.expectedAmount = expectedAmount
        self.isPermissionRequired = isPermissionRequired
        self.hasPendingTransaction = hasPendingTransaction
        self.isEnoughAmountForExpress = isEnoughAmountForExpress
    }
}
