//
//  MainViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

class MultiWalletCardHeaderSubtitleProvider: CardHeaderSubtitleProvider {
    private let subject: PassthroughSubject<String, Never> = .init()
    private let separator = " • "
    private let userWalletModel: UserWalletModel

    private var suffix: String {
        if userWalletModel.userWallet.card.wallets.contains(where: { $0.isImported ?? false }) {
            return separator + Localization.commonSeedPhrase
        }

        return ""
    }

    var subtitlePublisher: AnyPublisher<String, Never> {
        subject.eraseToAnyPublisher()
    }

    init(userWalletModel: UserWalletModel) {
        self.userWalletModel = userWalletModel
    }

    private func bind() {}
}

class SingleWalletCardHeaderSubtitleProvider: CardHeaderSubtitleProvider {
    private let subject: PassthroughSubject<String, Never> = .init()

    private let userWalletModel: UserWalletModel
    private let walletModel: WalletModel?
    private var stateUpdateSubscription: AnyCancellable?

    var subtitlePublisher: AnyPublisher<String, Never> {
        subject.eraseToAnyPublisher()
    }

    init(userWalletModel: UserWalletModel, walletModel: WalletModel?) {
        self.userWalletModel = userWalletModel
        self.walletModel = walletModel
        bind()
    }

    private func bind() {
//        stateUpdateSubscription = walletModel?.$state
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] newState in
//                if self?.userWalletModel.userWallet.isLocked ?? false {
//                    return
//                }
        ////                if case .idle = newState {
//                guard let walletModel = self?.walletModel else {
//                    return
//                }
//
//                let balance = walletModel.getBalance(for: .coin)
//                self?.subject.send(balance.isEmpty ? BalanceFormatter.defaultEmptyBalanceString : balance)
        ////                }
//            })
    }
}

final class MainViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var pages: [CardMainPageBuilder] = []
    @Published var cardsIndicies = [0, 1, 2]
    @Published var selectedCardIndex = 0

    // MARK: - Dependencies

    private let userWalletRepository: UserWalletRepository
    private var coordinator: MainRoutable?

    private var bag = Set<AnyCancellable>()

    init(
        coordinator: MainRoutable,
        userWalletRepository: UserWalletRepository,
        mainPageContentFactory: MainPageContentFactory = CommonMainPageContentFactory()
    ) {
        self.coordinator = coordinator
        self.userWalletRepository = userWalletRepository

        pages = mainPageContentFactory.createPages(from: userWalletRepository.models)
    }

    convenience init(
        cardViewModel: CardViewModel,
        coordinator: MainRoutable,
        userWalletRepository: UserWalletRepository
    ) {
        self.init(coordinator: coordinator, userWalletRepository: userWalletRepository)

        if let selectedIndex = pages.firstIndex(where: { $0.id == cardViewModel.userWalletId.stringValue }) {
            selectedCardIndex = selectedIndex
        }
    }

    func scanNewCard() {}

    func openDetails() {}

    func onPullToRefresh(completionHandler: @escaping RefreshCompletionHandler) {
        let page = pages[selectedCardIndex]
        let model = userWalletRepository.models[selectedCardIndex]
        switch page {
        case .singleWallet:
            model.walletModelsManager.updateAll(silent: false, completion: completionHandler)
        case .multiWallet:
            model.userTokenListManager.updateLocalRepositoryFromServer { _ in
                model.walletModelsManager.updateAll(silent: true, completion: completionHandler)
            }
        }
    }

    private func bind() {}
}
