//
//  MultiWalletCardHeaderViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 10/05/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

final class MultiWalletCardHeaderViewModel: ObservableObject {
    let cardImage: ImageType?

    @Published private(set) var cardName: String = ""
    @Published private(set) var subtitleAttributedString: String = ""
    @Published private(set) var balance: NSAttributedString = .init(string: "")
    @Published var isLoadingBalance: Bool = true
    @Published var showSensitiveInformation: Bool = true

    var isWithCardImage: Bool { cardImage != nil }

    private let cardInfoProvider: CardHeaderInfoProvider
    private let cardSubtitleProvider: CardHeaderSubtitleProvider?
    private let balanceProvider: TotalBalanceProviding

    private var bag: Set<AnyCancellable> = []

    init(
        cardInfoProvider: CardHeaderInfoProvider,
        cardSubtitleProvider: CardHeaderSubtitleProvider? = nil,
        balanceProvider: TotalBalanceProviding
    ) {
        self.cardInfoProvider = cardInfoProvider
        self.cardSubtitleProvider = cardSubtitleProvider
        self.balanceProvider = balanceProvider

        cardImage = cardInfoProvider.cardImage
        bind()
    }

    private func bind() {
        cardInfoProvider.cardNamePublisher
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.cardName, on: self)
            .store(in: &bag)

        cardSubtitleProvider?.subtitlePublisher
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.subtitleAttributedString, on: self)
            .store(in: &bag)

        balanceProvider.totalBalancePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                switch newValue {
                case .loading:
                    self?.isLoadingBalance = true
                case .loaded(let balance):
                    self?.isLoadingBalance = false

                    let balanceFormatter = BalanceFormatter()
                    let fiatBalanceFormatted = balanceFormatter.formatFiatBalance(balance.balance, formattingOptions: .defaultFiatFormattingOptions)
                    self?.balance = balanceFormatter.formatTotalBalanceForMain(fiatBalance: fiatBalanceFormatted, formattingOptions: .defaultOptions)
                case .failedToLoad(let error):
                    AppLog.shared.debug("Failed to load total balance. Reason: \(error)")
                    self?.isLoadingBalance = false

                    self?.balance = NSAttributedString(string: BalanceFormatter.defaultEmptyBalanceString)
                }
            }
            .store(in: &bag)
    }
}
