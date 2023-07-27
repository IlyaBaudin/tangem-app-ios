//
//  CardMainPageBuilderFactory.swift
//  Tangem
//
//  Created by Andrew Son on 17/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol MainPageContentFactory {
    func createPages(from models: [UserWalletModel]) -> [CardMainPageBuilder]
}

struct CommonMainPageContentFactory: MainPageContentFactory {
    func createPages(from models: [UserWalletModel]) -> [CardMainPageBuilder] {
        return models.compactMap {
            let id = $0.userWalletId.stringValue

            if $0.isMultiWallet {
                let coordinator = MultiWalletContentCoordinator()
                coordinator.start(with: .init())
                let header = MultiWalletCardHeaderViewModel(
                    cardInfoProvider: $0,
                    cardSubtitleProvider: MultiWalletCardHeaderSubtitleProvider(userWalletModel: $0),
                    balanceProvider: $0
                )

                return .multiWallet(
                    id: id,
                    headerModel: header,
                    bodyModel: coordinator
                )
            }

            let coordinator = SingleWalletContentCoordinator()
            coordinator.start(with: .init())
            let header = MultiWalletCardHeaderViewModel(
                cardInfoProvider: $0,
                cardSubtitleProvider: SingleWalletCardHeaderSubtitleProvider(userWalletModel: $0, walletModel: $0.walletModelsManager.walletModels.first),
                balanceProvider: $0
            )
            return .singleWallet(
                id: id,
                headerModel: header,
                bodyModel: coordinator
            )
        }
    }
}
