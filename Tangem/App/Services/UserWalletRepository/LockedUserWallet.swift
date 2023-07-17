//
//  LockedUserWallet.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk

class LockedUserWallet: UserWalletModel {
    private(set) var userWallet: UserWallet

    private let config: UserWalletConfig
    private let cardNameSubject: CurrentValueSubject<String, Never>

    private var bag = Set<AnyCancellable>()

    init(with userWallet: UserWallet) {
        self.userWallet = userWallet
        cardNameSubject = .init(userWallet.name)
        config = UserWalletConfigFactory(userWallet.cardInfo()).makeConfig()
    }

    var isMultiWallet: Bool { config.hasFeature(.multiCurrency) }

    var userWalletId: UserWalletId { .init(value: userWallet.userWalletId) }

    var walletModels: [WalletModel] { [] }

    var userTokenListManager: UserTokenListManager { DummyUserTokenListManager() }

    var totalBalanceProvider: TotalBalanceProviding { DummyTotalBalanceProvider() }

    func subscribeToWalletModels() -> AnyPublisher<[WalletModel], Never> { .just(output: []) }

    func getSavedEntries() -> [StorageEntry] { [] }

    func getEntriesWithoutDerivation() -> [StorageEntry] { [] }

    func subscribeToEntriesWithoutDerivation() -> AnyPublisher<[StorageEntry], Never> { .just(output: []) }

    func canManage(amountType: BlockchainSdk.Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool { false }

    func update(entries: [StorageEntry]) {}

    func append(entries: [StorageEntry]) {}

    func remove(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) {}

    func initialUpdate() {}

    func updateWalletName(_ name: String) {
        userWallet.name = name
    }

    func updateWalletModels() {}

    func updateAndReloadWalletModels(silent: Bool, completion: @escaping () -> Void) {}

    private func bind() {
        cardNameSubject
            .sink { [weak self] newName in
                self?.userWallet.name = newName
            }
            .store(in: &bag)
    }
}

extension LockedUserWallet {
    struct DummyUserTokenListManager: UserTokenListManager {
        var didPerformInitialLoading: Bool { false }

        func update(userWalletId: Data) {}

        func update(_ type: CommonUserTokenListManager.UpdateType) {}

        func updateLocalRepositoryFromServer(result: @escaping (Result<UserTokenList, Error>) -> Void) {}

        func getEntriesFromRepository() -> [StorageEntry] { [] }

        func clearRepository(completion: @escaping () -> Void) {}
    }

    struct DummyTotalBalanceProvider: TotalBalanceProviding {
        func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalanceProvider.TotalBalance>, Never> {
            Empty().eraseToAnyPublisher()
        }
    }
}

extension LockedUserWallet: MultiWalletCardHeaderInfoProvider {
    var cardNamePublisher: AnyPublisher<String, Never> {
        cardNameSubject.eraseToAnyPublisher()
    }

    var numberOfCardsPublisher: AnyPublisher<Int, Never> {
        .just(output: config.cardsCount)
            .eraseToAnyPublisher()
    }

    var isWalletImported: Bool {
        false
    }

    var cardImage: ImageType? {
        config.cardImage
    }
}
