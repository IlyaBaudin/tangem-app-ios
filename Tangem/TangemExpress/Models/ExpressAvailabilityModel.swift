//
//  ExpressAvailabilityModel.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 18.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import struct TangemSwapping.EthereumGasDataModel

public struct ExpressAvailabilityModel {
    public let transactionData: ExpressTransactionData
    public let gasOptions: [EthereumGasDataModel]
    public let restrictions: Restrictions

    public var destinationAmount: Decimal {
        transactionData.destinationExpressCurrency.convertFromWEI(
            value: transactionData.destinationAmount
        )
    }

    public func isEnoughAmountForExpress(for policy: ExpressGasPricePolicy) -> Bool {
        restrictions.isEnoughAmountForExpress[policy] ?? false
    }

    public func isEnoughAmountForFee(for policy: ExpressGasPricePolicy) -> Bool {
        restrictions.isEnoughAmountForFee[policy] ?? false
    }

    public init(
        transactionData: ExpressTransactionData,
        gasOptions: [EthereumGasDataModel],
        restrictions: Restrictions
    ) {
        self.transactionData = transactionData
        self.gasOptions = gasOptions
        self.restrictions = restrictions
    }
}

public extension ExpressAvailabilityModel {
    struct Restrictions {
        public let isEnoughAmountForExpress: [ExpressGasPricePolicy: Bool]
        public let isEnoughAmountForFee: [ExpressGasPricePolicy: Bool]
        public let isPermissionRequired: Bool

        public init(
            isEnoughAmountForExpress: [ExpressGasPricePolicy: Bool],
            isEnoughAmountForFee: [ExpressGasPricePolicy: Bool],
            isPermissionRequired: Bool
        ) {
            self.isEnoughAmountForExpress = isEnoughAmountForExpress
            self.isEnoughAmountForFee = isEnoughAmountForFee
            self.isPermissionRequired = isPermissionRequired
        }
    }
}
