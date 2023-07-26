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
    var cardsCount: Int

    var tokensCount: Int? { walletModelsManager.walletModels.filter { !$0.isMainToken }.count }
    var updatePublisher: AnyPublisher<Void, Never> { _updatePublisher.eraseToAnyPublisher() }

    private let _updatePublisher: PassthroughSubject<Void, Never> = .init()

    internal init(
        cardName: String,
        isMultiWallet: Bool,
        cardsCount: Int,
        userWalletId: UserWalletId,
        walletModels: [WalletModel],
        userWallet: UserWallet
    ) {
        self.cardName = cardName
        self.isMultiWallet = isMultiWallet
        self.cardsCount = cardsCount
        self.userWalletId = userWalletId
        walletModelsManager = WalletModelsManagerMock()
        userTokenListManager = CommonUserTokenListManager(hasTokenSynchronization: false, userWalletId: userWalletId.value, hdWalletsSupported: true)
        totalBalanceProvider = TotalBalanceProviderMock()
        self.userWallet = userWallet
    }

    func initialUpdate() {}

    func updateWalletName(_ name: String) {
        cardName = name
        _updatePublisher.send(())
    }

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
