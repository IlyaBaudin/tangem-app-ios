//
//  ExchangeManagerDelegate.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 24.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol ExchangeManagerDelegate: AnyObject {
    func exchangeManagerDidUpdate(exchangeItems: ExchangeItems)
    func exchangeManagerDidUpdate(availabilityState: ExchangeAvailabilityState)
    func exchangeManagerDidUpdate(availabilityForExchange: Bool, limit: Decimal?)
}
