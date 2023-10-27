//
//  ExpressItems.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 15.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public struct ExpressItems {
    public var source: ExpressCurrency
    public var destination: ExpressCurrency?

    public var sourceBalance: Decimal = 0
    public var destinationBalance: Decimal?

    public init(source: ExpressCurrency, destination: ExpressCurrency?) {
        self.source = source
        self.destination = destination
    }
}
