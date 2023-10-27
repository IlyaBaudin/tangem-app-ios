//
//  ExpressDataModel.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 08.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public struct ExpressDataModel {
    public let sourceAddress: String
    public let destinationAddress: String

    /// WEI
    public let value: Decimal
    public let txData: Data

    /// WEI
    public let sourceExpressCurrencyAmount: Decimal
    public let destinationExpressCurrencyAmount: Decimal

    /// Contract address
    public let sourceTokenAddress: String?
    /// Contract address
    public let destinationTokenAddress: String?

    public init(swappingData: ExpressData) throws {
        guard let sourceExpressCurrencyAmount = Decimal(string: swappingData.fromTokenAmount),
              let destinationExpressCurrencyAmount = Decimal(string: swappingData.toTokenAmount),
              let value = Decimal(string: swappingData.tx.value) else {
            throw CommonError.noData
        }

        self.sourceExpressCurrencyAmount = sourceExpressCurrencyAmount
        self.destinationExpressCurrencyAmount = destinationExpressCurrencyAmount
        self.value = value

        txData = Data(hexString: swappingData.tx.data)
        sourceAddress = swappingData.tx.from
        destinationAddress = swappingData.tx.to
        sourceTokenAddress = swappingData.fromToken.address
        destinationTokenAddress = swappingData.toToken.address
    }
}
