//
//  ExpressAvailabilityState.swift
//  TangemExpress
//
//  Created by Sergey Balashov on 24.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public enum ExpressAvailabilityState {
    case idle
    case loading(_ type: ExpressManagerRefreshType)
    case preview(_ model: ExpressPreviewData)
    case available(_ model: ExpressAvailabilityModel)
    case requiredRefresh(occurredError: Error)
}
