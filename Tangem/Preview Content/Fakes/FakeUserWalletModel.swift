//
//  FakeUserWalletModel.swift
//  Tangem
//
//  Created by Andrew Son on 28/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk

class FakeUserWalletModel: UserWalletModel, ObservableObject {
    @Published var cardName: String

    let walletModelsManager: WalletModelsManager
    let userTokenListManager: UserTokenListManager
    let totalBalanceProvider: TotalBalanceProviding
    let signer: TangemSigner = .init(with: "", sdk: .init())

    let userWallet: UserWallet
    let isMultiWallet: Bool
    let userWalletId: UserWalletId

    var tokensCount: Int? { walletModelsManager.walletModels.filter { !$0.isMainToken }.count }

    internal init(
        cardName: String,
        isMultiWallet: Bool,
        userWalletId: UserWalletId,
        walletModels: [WalletModel],
        userWallet: UserWallet
    ) {
        self.cardName = cardName
        self.isMultiWallet = isMultiWallet
        self.userWalletId = userWalletId
        walletModelsManager = WalletModelsManagerMock()
        userTokenListManager = CommonUserTokenListManager(hasTokenSynchronization: false, userWalletId: userWalletId.value, hdWalletsSupported: true)
        totalBalanceProvider = TotalBalanceProviderMock()
        self.userWallet = userWallet
    }

    func initialUpdate() {}

    func updateWalletName(_ name: String) {}

    func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalanceProvider.TotalBalance>, Never> {
        return .just(output: .loading)
    }
}

extension FakeUserWalletModel: CardHeaderInfoProvider {
    var cardNamePublisher: AnyPublisher<String, Never> { $cardName.eraseToAnyPublisher() }

    var cardImage: ImageType? {
        switch userWallet.walletData {
        case .none: return Assets.Cards.wallet
        case .twin: return Assets.Cards.twin
        default: return Assets.Cards.wallet2Triple
        }
    }
}
