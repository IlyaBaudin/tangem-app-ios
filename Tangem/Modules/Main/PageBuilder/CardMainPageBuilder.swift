//
//  CardMainPageBuilder.swift
//  Tangem
//
//  Created by Andrew Son on 17/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

enum CardMainPageBuilder: Identifiable {
    case singleWallet(id: String, headerModel: MultiWalletCardHeaderViewModel, bodyModel: SingleWalletContentCoordinator)
    case multiWallet(id: String, headerModel: MultiWalletCardHeaderViewModel, bodyModel: MultiWalletContentCoordinator)

    var id: String {
        switch self {
        case .singleWallet(let id, _, _):
            return id
        case .multiWallet(let id, _, _):
            return id
        }
    }

    @ViewBuilder
    var header: some View {
        switch self {
        case .singleWallet(_, let headerModel, _):
            MultiWalletCardHeaderView(viewModel: headerModel)
        case .multiWallet(_, let headerModel, _):
            MultiWalletCardHeaderView(viewModel: headerModel)
        }
    }

    @ViewBuilder
    func body(_ connector: CardsInfoPagerScrollViewConnector) -> some View {
        switch self {
        case .singleWallet(_, _, let bodyModel):
            CardsPagerContent(scrollViewConnector: connector) {
                SingleWalletContentCoordinatorView(coordinator: bodyModel)
            }
        case .multiWallet(_, _, let bodyModel):
            CardsPagerContent(scrollViewConnector: connector) {
                MultiWalletContentCoordinatorView(coordinator: bodyModel)
            }
        }
    }
}
