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
    @Published var models: [MultiWalletCardHeaderViewModel] = []

    let infoProviders = [
        CardInfoProvider(
            cardName: "William Wallet",
            cardImage: Assets.Cards.wallet2Triple,
            subtitleInfo: .init(message: Localization.cardLabelCardCount(3) + " • " + Localization.commonSeedPhrase, formattingOption: .default),
            isLoadingSubtitle: false,
            subtitleContainsSensitiveInfo: false,
            tapAction: { provider in
                provider.cardName = provider.cardName == "William Wallet" ? "Uilleam Uallet" : "William Wallet"
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

        CardInfoProvider(
            cardName: "Wallet 2 Twins",
            cardImage: Assets.Cards.wallet2Double,
            subtitleInfo: .init(message: Localization.cardLabelCardCount(2), formattingOption: .default),
            isLoadingSubtitle: false,
            subtitleContainsSensitiveInfo: false,
            tapAction: { provider in
                provider.cardName = provider.cardName == "Wallet Hannah" ? "Wallet Jane" : "Wallet Hannah"
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

        CardInfoProvider(
            cardName: "Plain Old Wallet wallet wallet wallet wallet wallet wallet",
            cardImage: Assets.Cards.wallet,
            subtitleInfo: .init(message: Localization.cardLabelCardCount(2), formattingOption: .default),
            isLoadingSubtitle: false,
            subtitleContainsSensitiveInfo: false,
            tapAction: { provider in
                provider.cardName = provider.cardName == "POWwwwwwww" ? "Plain Old Wallet wallet wallet wallet wallet wallet wallet" : "POWwwwwwww"
                switch provider.balance {
                case .loading:
                    provider.balance = .loaded(TotalBalanceProvider.TotalBalance(
                        balance: 0.0,
                        currencyCode: "EUR",
                        hasError: false
                    ))
                case .loaded, .failedToLoad:
                    provider.balance = .loading
                }
            }
        ),

        CardInfoProvider(
            cardName: "Note",
            cardImage: Assets.Cards.noteDoge,
            subtitleInfo: .init(message: Localization.commonLocked, formattingOption: .default),
            isLoadingSubtitle: true,
            subtitleContainsSensitiveInfo: true,
            tapAction: { provider in
                switch provider.balance {
                case .loading:
                    provider.isLoadingSubtitle = true
                    provider.balance = .loaded(TotalBalanceProvider.TotalBalance(
                        balance: nil,
                        currencyCode: "RUB",
                        hasError: true
                    ))
                case .loaded, .failedToLoad:
                    provider.isLoadingSubtitle = false
                    provider.balance = .loading
                }
            }
        ),

        CardInfoProvider(
            cardName: "XRP Note",
            cardImage: nil,
            subtitleInfo: .init(message: Localization.walletErrorNoAccount, formattingOption: .error),
            isLoadingSubtitle: false,
            subtitleContainsSensitiveInfo: false,
            tapAction: { provider in
                switch provider.balance {
                case .loading:
                    provider.balance = .loaded(TotalBalanceProvider.TotalBalance(
                        balance: 454.2114313,
                        currencyCode: "USD",
                        hasError: false
                    ))
                case .loaded, .failedToLoad:
                    provider.balance = .loading
                }
            }
        ),

        CardInfoProvider(
            cardName: "BTC bird kookee kookee kookoo-kooroo-kookoo kookoo-kooroo-kookoo kookee kookee",
            cardImage: nil,
            subtitleInfo: .init(message: "1233543.02432 BTC", formattingOption: .default),
            isLoadingSubtitle: true,
            subtitleContainsSensitiveInfo: false,
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
        models = infoProviders.map {
            .init(cardInfoProvider: $0, cardSubtitleProvider: $0, balanceProvider: $0)
        }
    }
}

extension FakeCardHeaderPreviewProvider {
    final class CardInfoProvider: CardHeaderInfoProvider, TotalBalanceProviding, CardHeaderSubtitleProvider {
        @Published var cardName: String
        @Published var balance: LoadingValue<TotalBalanceProvider.TotalBalance> = .loading
        @Published var subtitleInfo = CardHeaderSubtitleInfo.empty
        @Published var isLoadingSubtitle: Bool

        let cardImage: ImageType?
        let containsSensitiveInfo: Bool

        var tapAction: (CardInfoProvider) -> Void

        var cardNamePublisher: AnyPublisher<String, Never> { $cardName.eraseToAnyPublisher() }

        var subtitlePublisher: AnyPublisher<CardHeaderSubtitleInfo, Never> { $subtitleInfo.eraseToAnyPublisher() }

        var isLoadingPublisher: AnyPublisher<Bool, Never> { $isLoadingSubtitle.eraseToAnyPublisher() }

        init(cardName: String, cardImage: ImageType?, subtitleInfo: CardHeaderSubtitleInfo, isLoadingSubtitle: Bool, subtitleContainsSensitiveInfo: Bool, tapAction: @escaping (CardInfoProvider) -> Void) {
            self.cardName = cardName
            self.cardImage = cardImage
            self.subtitleInfo = subtitleInfo
            self.isLoadingSubtitle = isLoadingSubtitle
            containsSensitiveInfo = subtitleContainsSensitiveInfo

            self.tapAction = tapAction
        }

        func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalanceProvider.TotalBalance>, Never> {
            $balance.eraseToAnyPublisher()
        }
    }
}
