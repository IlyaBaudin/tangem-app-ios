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

    var isMultiWallet: Bool
    var userWalletId: UserWalletId
    @Published var walletModels: [WalletModel]
    var userTokenListManager: UserTokenListManager
    var totalBalanceProvider: TotalBalanceProviding
    var userWallet: UserWallet

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
        self.walletModels = walletModels
        userTokenListManager = CommonUserTokenListManager(hasTokenSynchronization: false, userWalletId: userWalletId.value)
        totalBalanceProvider = TotalBalanceProviderMock()
        self.userWallet = userWallet
    }

    func subscribeToWalletModels() -> AnyPublisher<[WalletModel], Never> {
        $walletModels.eraseToAnyPublisher()
    }

    func getSavedEntries() -> [StorageEntry] {
        []
    }

    func getEntriesWithoutDerivation() -> [StorageEntry] {
        []
    }

    func subscribeToEntriesWithoutDerivation() -> AnyPublisher<[StorageEntry], Never> {
        .just(output: [])
    }

    func canManage(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool {
        true
    }

    func update(entries: [StorageEntry]) {}

    func append(entries: [StorageEntry]) {}

    func remove(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) {}

    func initialUpdate() {}

    func updateWalletName(_ name: String) {}

    func updateWalletModels() {}

    func updateAndReloadWalletModels(silent: Bool, completion: @escaping () -> Void) {}
}

extension FakeUserWalletModel: MultiWalletCardHeaderInfoProvider {
    var cardNamePublisher: AnyPublisher<String, Never> { $cardName.eraseToAnyPublisher() }

    var numberOfCardsPublisher: AnyPublisher<Int, Never> {
        .just(output: 3)
    }

    var isWalletImported: Bool {
        true
    }

    var cardImage: ImageType? {
        switch userWallet.walletData {
        case .none: return Assets.Cards.wallet
        case .twin: return Assets.Cards.twin
        default: return Assets.Cards.wallet2Triple
        }
    }
}
