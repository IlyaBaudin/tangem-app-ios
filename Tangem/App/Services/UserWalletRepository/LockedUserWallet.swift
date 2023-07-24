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
    let walletModelsManager: WalletModelsManager = WalletModelsManagerMock()

    var tokensCount: Int? { nil }

    var isMultiWallet: Bool { config.hasFeature(.multiCurrency) }

    var userWalletId: UserWalletId { .init(value: userWallet.userWalletId) }

    private(set) var userWallet: UserWallet

    private let config: UserWalletConfig
    private let cardNameSubject: CurrentValueSubject<String, Never>

    private var bag = Set<AnyCancellable>()

    init(with userWallet: UserWallet) {
        self.userWallet = userWallet
        cardNameSubject = .init(userWallet.name)
        config = UserWalletConfigFactory(userWallet.cardInfo()).makeConfig()
    }

    func initialUpdate() {}

    func updateWalletName(_ name: String) {
        userWallet.name = name
    }

    func updateWalletModels() {}

    func updateAndReloadWalletModels(silent: Bool, completion: @escaping () -> Void) {}

    func totalBalancePublisher() -> AnyPublisher<LoadingValue<TotalBalanceProvider.TotalBalance>, Never> {
        .just(output: .loaded(.init(balance: 0, currencyCode: "", hasError: false)))
    }

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
        var userTokens: [StorageEntry] { [] }

        var userTokensPublisher: AnyPublisher<[StorageEntry], Never> { .just(output: []) }

        func update(_ type: CommonUserTokenListManager.UpdateType, shouldUpload: Bool) {}

        func upload() {}

        func updateLocalRepositoryFromServer(result: @escaping (Result<Void, Error>) -> Void) {
            result(.success(()))
        }
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
