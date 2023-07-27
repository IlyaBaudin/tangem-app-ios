//
//  FakeCardHeaderPreviewProvider.swift
//  Tangem
//
//  Created by Andrew Son on 12/05/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

final class FakeCardHeaderPreviewProvider: ObservableObject {
    @Published var models: [CardHeaderViewModel] = []

    let infoProviders: [Provider] = [
        Provider(
            walletModel: FakeUserWalletModel.wallet3Cards,
            tapAction: { provider in
                provider.walletModel.cardName = provider.walletModel.cardName == "William Wallet" ? "Uilleam Uallet" : "William Wallet"
                switch provider.balance {
                case .loading:
                    provider.balance = .loaded(TotalBalanceProvider.TotalBalance(
                        balance: 4346437892534324.2189,
                        currencyCode: "USD",
                        hasError: false
                    ))
                case .loaded, .failedToLoad:
                    provider.balance = .loading
                }
            }
        ),
        Provider(
            walletModel: FakeUserWalletModel.twins,
            tapAction: { provider in
                provider.walletModel.cardName = provider.walletModel.cardName == "Wallet Hannah" ? "Wallet Jane" : "Wallet Hannah"
                switch provider.balance {
                case .loading:
                    provider.balance = .loaded(TotalBalanceProvider.TotalBalance(
                        balance: 92324.2133654889,
                        currencyCode: "EUR",
                        hasError: false
                    ))
                case .loaded, .failedToLoad:
                    provider.balance = .loading
                }
            }
        ),
        Provider(
            walletModel: FakeUserWalletModel.xrpNote,
            tapAction: { provider in
                switch provider.balance {
                case .loading:
                    provider.balance = .loaded(TotalBalanceProvider.TotalBalance(
                        balance: 4567575476468896456534878754.2114313,
                        currencyCode: "USD",
                        hasError: false
                    ))
                case .loaded, .failedToLoad:
                    provider.balance = .loading
                }
            }
        ),
    ]

    init() {
        initializeModels()
    }

    private func initializeModels() {
        models = infoProviders
            .map {
                .init(
                    cardInfoProvider: $0.walletModel,
                    cardSubtitleProvider: $0.headerSubtitleProvider,
                    balanceProvider: $0
                )
            }
    }
}

extension FakeCardHeaderPreviewProvider {
    final class Provider: TotalBalanceProviding {
        @Published var balance: LoadingValue<TotalBalanceProvider.TotalBalance> = .loading

        let walletModel: FakeUserWalletModel
        let headerSubtitleProvider: CardHeaderSubtitleProvider

        var tapAction: (Provider) -> Void

        init(walletModel: FakeUserWalletModel, tapAction: @escaping (Provider) -> Void) {
            self.walletModel = walletModel
            headerSubtitleProvider = CardHeaderSubtitleProviderFactory().provider(for: walletModel)
            self.tapAction = tapAction
        }

        func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalanceProvider.TotalBalance>, Never> {
            $balance.eraseToAnyPublisher()
        }
    }
}
