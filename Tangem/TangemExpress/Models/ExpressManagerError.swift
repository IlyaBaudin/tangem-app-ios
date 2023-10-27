//
//  ExpressManagerError.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 05.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public enum ExpressManagerError: Error {
    case walletAddressNotFound
    case destinationNotFound
    case amountNotFound
    case gasModelNotFound
    case contractAddressNotFound
}
