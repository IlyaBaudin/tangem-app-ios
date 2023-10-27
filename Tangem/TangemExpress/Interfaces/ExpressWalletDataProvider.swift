//
//  ExpressWalletDataProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 15.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import struct TangemSwapping.EthereumGasDataModel

public protocol ExpressWalletDataProvider {
    func getWalletAddress(currency: ExpressCurrency) -> String?

    func getGasOptions(
        blockchain: ExpressBlockchain,
        value: Decimal,
        data: Data,
        destinationAddress: String
    ) async throws -> [EthereumGasDataModel]

    func getBalance(for currency: ExpressCurrency) -> Decimal?
    func getBalance(for currency: ExpressCurrency) async throws -> Decimal
    func getBalance(for blockchain: ExpressBlockchain) async throws -> Decimal

    func getAllowance(for currency: ExpressCurrency, from spender: String) async throws -> Decimal
    func getApproveData(for currency: ExpressCurrency, from spender: String, policy: ExpressApprovePolicy) -> Data
}
