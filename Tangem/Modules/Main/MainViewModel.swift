//
//  MainViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

enum CardHeaderSubtitleFormattingOption {
    case `default`
    case error

    var textColor: Color {
        switch self {
        case .default: return Colors.Text.tertiary
        case .error: return Colors.Text.attention
        }
    }

    var font: Font {
        Fonts.Regular.caption2
    }
}

struct CardHeaderSubtitleInfo {
    let message: String
    let formattingOption: CardHeaderSubtitleFormattingOption

    static let empty: CardHeaderSubtitleInfo = .init(message: "", formattingOption: .default)
}

final class MainViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var pages: [CardMainPageBuilder] = []
    @Published var selectedCardIndex = 0
    @Published var isHorizontalScrollDisabled = false

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

        disableHorizontalScrollIfNeeded()
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

    private func disableHorizontalScrollIfNeeded() {
        isHorizontalScrollDisabled = pages.count <= 1
    }

    private func bind() {}
}
