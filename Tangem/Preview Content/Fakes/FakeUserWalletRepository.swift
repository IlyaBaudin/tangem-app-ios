//
//  FakeUserWalletRepository.swift
//  Tangem
//
//  Created by Andrew Son on 28/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk

class FakeUserWalletRepository: UserWalletRepository {
    var models: [UserWalletModel] = []

    var selectedModel: CardViewModel?

    var selectedUserWalletId: Data?

    var isEmpty: Bool { models.isEmpty }

    var count: Int { models.count }

    var isLocked: Bool = false

    var eventProvider: AnyPublisher<UserWalletRepositoryEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private let eventSubject = PassthroughSubject<UserWalletRepositoryEvent, Never>()

    init() {
        models = [
            FakeUserWalletModel(
                cardName: "William Wallet",
                isMultiWallet: true,
                userWalletId: .init(with: Data.randomData(count: 32)),
                walletModels: [
                    WalletModel(
                        walletManager: FakeWalletManager(wallet: .ethereumWalletStub),
                        amountType: .coin,
                        isCustom: false
                    ),
                    WalletModel(
                        walletManager: FakeWalletManager(wallet: .ethereumWalletStub),
                        amountType: .token(value: .sushiMock),
                        isCustom: false
                    ),
                ],
                userWallet: UserWalletStubs.walletV2Stub
            ),
            FakeUserWalletModel(
                cardName: "Tangem Twins",
                isMultiWallet: false,
                userWalletId: .init(with: Data.randomData(count: 32)),
                walletModels: [
                    WalletModel(
                        walletManager: FakeWalletManager(wallet: .btcWalletStub),
                        amountType: .coin,
                        isCustom: false
                    ),
                ],
                userWallet: UserWalletStubs.twinStub
            ),
        ]
    }

    func unlock(with method: UserWalletRepositoryUnlockMethod, completion: @escaping (UserWalletRepositoryResult?) -> Void) {}

    func setSelectedUserWalletId(_ userWalletId: Data?, reason: UserWalletRepositorySelectionChangeReason) {}

    func updateSelection() {}

    func logoutIfNeeded() {}

    func add(_ completion: @escaping (UserWalletRepositoryResult?) -> Void) {}

    func save(_ cardViewModel: CardViewModel) {}

    func contains(_ userWallet: UserWallet) -> Bool {
        false
    }

    func save(_ userWallet: UserWallet) {}

    func delete(_ userWallet: UserWallet, logoutIfNeeded shouldAutoLogout: Bool) {}

    func clear() {}

    func initialize() {}
}
