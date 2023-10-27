//
//  ExpressData.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 31.03.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

public struct ExpressData: Decodable {
    public let fromToken: ExpressTokenData
    public let toToken: ExpressTokenData
    public let toTokenAmount: String
    public let fromTokenAmount: String
    public let protocols: [[[ProtocolInfo]]]
    public let tx: TransactionData
}
