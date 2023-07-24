//
//  SingleAddressTypesConfig.swift
//  Tangem
//
//  Created by Sergey Balashov on 10.07.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

struct SingleAddressTypesConfig: AddressTypesConfig {
    func addressTypes(for blockchain: Blockchain) -> [AddressType] {
        return [.default]
    }
}
