//
//  UserWalletModelMock.swift
//  Tangem
//
//  Created by Sergey Balashov on 25.01.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import BlockchainSdk

class UserWalletModelMock: UserWalletModel {
    var isMultiWallet: Bool { false }

    var tokensCount: Int? { 10 }

    var userWalletId: UserWalletId { .init(with: Data()) }

    var userWallet: UserWallet {
        UserWallet(userWalletId: Data(), name: "", card: .init(card: .walletWithBackup), associatedCardIds: [], walletData: .none, artwork: nil, isHDWalletAllowed: false)
    }

    var cardNamePublisher: AnyPublisher<String, Never> { .just(output: "") }

    var numberOfCardsPublisher: AnyPublisher<Int, Never> { .just(output: 1) }

    var isWalletImported: Bool { false }

    var cardImage: ImageType? { nil }

    func initialUpdate() {}
    func updateWalletName(_ name: String) {}

    func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalanceProvider.TotalBalance>, Never> {
        .just(output: .loading)
    }
}
