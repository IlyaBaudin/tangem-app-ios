//
//  SingleWalletCardHeaderSubtitleProvider.swift
//  Tangem
//
//  Created by Andrew Son on 26/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class SingleWalletCardHeaderSubtitleProvider: CardHeaderSubtitleProvider {
    private let subject: PassthroughSubject<CardHeaderSubtitleInfo, Never> = .init()
    private let isLoadingSubject: CurrentValueSubject<Bool, Never>

    private let userWalletModel: UserWalletModel
    private let walletModel: WalletModel?
    private var stateUpdateSubscription: AnyCancellable?

    var subtitlePublisher: AnyPublisher<CardHeaderSubtitleInfo, Never> {
        subject.eraseToAnyPublisher()
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    var containsSensitiveInfo: Bool { true }

    init(userWalletModel: UserWalletModel, walletModel: WalletModel?) {
        self.userWalletModel = userWalletModel
        self.walletModel = walletModel
        isLoadingSubject = .init(!userWalletModel.userWallet.isLocked)
        bind()
    }

    private func bind() {
        stateUpdateSubscription = walletModel?.walletDidChangePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newState in
                guard let self else { return }

                isLoadingSubject.send(false)

                if userWalletModel.userWallet.isLocked {
                    displayLockedWalletMessage()
                    return
                }

                switch newState {
                case .failed(let error):
                    print("Failed to load balance: \(error)")
                case .noAccount(let message):
                    print("No account: \(message)")
                case .created, .loading, .noDerivation:
                    break
                case .idle:
                    formatBalanceMessage()
                }
            })
    }

    private func formatBalanceMessage() {
        guard let walletModel else { return }

        let balance = walletModel.balance
        subject.send(.init(message: balance, formattingOption: .default))
    }

    private func formatErrorMessage(with text: String) {
        subject.send(.init(message: text, formattingOption: .error))
    }

    private func displayLockedWalletMessage() {
        subject.send(.init(message: Localization.commonLocked, formattingOption: .default))
    }
}
