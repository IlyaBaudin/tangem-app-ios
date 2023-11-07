//
//  ExpressTokensListViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 07.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

class ExpressTokensListRoutableMock: ExpressTokensListRoutable {
    init() {}
}

final class ExpressTokensListViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var searchText: String = ""
    @Published var availableTokens: [ExpressTokenItemViewModel] = []
    @Published var unavailableTokens: [ExpressTokenItemViewModel] = []

    // MARK: - Dependencies

    private unowned let coordinator: ExpressTokensListRoutable
    private var bag: Set<AnyCancellable> = []

    init(coordinator: ExpressTokensListRoutable) {
        self.coordinator = coordinator
        setupView()
        bind()
    }
}

// MARK: - Private

private extension ExpressTokensListViewModel {
    func bind() {
        $searchText
            .withWeakCaptureOf(self)
            .sink { viewModel, searchText in
                if searchText.isEmpty {
                    viewModel.availableTokens = viewModel.getAvailableTokens()
                    viewModel.unavailableTokens = viewModel.getUnavailableTokens()
                } else {
                    viewModel.availableTokens = viewModel.getAvailableTokens().filter { $0.name.contains(searchText) }
                    viewModel.unavailableTokens = viewModel.getUnavailableTokens().filter { $0.name.contains(searchText) }
                }
            }
            .store(in: &bag)
    }
    
    // Temporary. Will be replaced
    func getAvailableTokens() -> [ExpressTokenItemViewModel] {
        [
            ExpressTokenItemViewModel(
                tokenId: "Polygon",
                tokenIconItem: TokenIconItemViewModel(
                    imageURL: TokenIconURLBuilder().iconURL(id: "matic-network", size: .large),
                    networkURL: TokenIconURLBuilder().iconURL(id: "bitcoin", size: .small)
                ),
                name: "Polygon",
                symbol: "MATIC",
                balance: CurrencyAmount(value: 120, currency: .mock),
                fiatBalance: 60.30,
                isDisable: false,
                itemDidTap: {}
            ),
            ExpressTokenItemViewModel(
                tokenId: "Cardano",
                tokenIconItem: TokenIconItemViewModel(
                    imageURL: TokenIconURLBuilder().iconURL(id: "cardano", size: .large),
                    networkURL: TokenIconURLBuilder().iconURL(id: "bitcoin", size: .small)
                ),
                name: "Cardano",
                symbol: "ADA",
                balance: CurrencyAmount(value: 12.097, currency: .mock),
                fiatBalance: 4.3,
                isDisable: false,
                itemDidTap: {}
            ),
            ExpressTokenItemViewModel(
                tokenId: "Binance",
                tokenIconItem: TokenIconItemViewModel(
                    imageURL: TokenIconURLBuilder().iconURL(id: "binancecoin", size: .large),
                    networkURL: nil
                ),
                name: "Binance",
                symbol: "BNB",
                balance: CurrencyAmount(value: 1.6, currency: .mock),
                fiatBalance: 383.3,
                isDisable: false,
                itemDidTap: {}
            ),
        ]
    }
    
    // Temporary. Will be replaced
    func getUnavailableTokens() -> [ExpressTokenItemViewModel] {
        [
            ExpressTokenItemViewModel(
                tokenId: "Polygon",
                tokenIconItem: TokenIconItemViewModel(
                    imageURL: TokenIconURLBuilder().iconURL(id: "matic-network", size: .large),
                    networkURL: TokenIconURLBuilder().iconURL(id: "bitcoin", size: .small)
                ),
                name: "Polygon",
                symbol: "MATIC",
                balance: CurrencyAmount(value: 120, currency: .mock),
                fiatBalance: 60.30,
                isDisable: true,
                itemDidTap: {}
            ),
            ExpressTokenItemViewModel(
                tokenId: "Cardano",
                tokenIconItem: TokenIconItemViewModel(
                    imageURL: TokenIconURLBuilder().iconURL(id: "cardano", size: .large),
                    networkURL: TokenIconURLBuilder().iconURL(id: "bitcoin", size: .small)
                ),
                name: "Cardano",
                symbol: "ADA",
                balance: CurrencyAmount(value: 12.097, currency: .mock),
                fiatBalance: 4.3,
                isDisable: true,
                itemDidTap: {}
            ),
            ExpressTokenItemViewModel(
                tokenId: "Binance",
                tokenIconItem: TokenIconItemViewModel(
                    imageURL: TokenIconURLBuilder().iconURL(id: "binancecoin", size: .large),
                    networkURL: nil
                ),
                name: "Binance",
                symbol: "BNB",
                balance: CurrencyAmount(value: 1.6, currency: .mock),
                fiatBalance: 383.3,
                isDisable: true,
                itemDidTap: {}
            ),
        ]
    }
    
    func setupView() {
        availableTokens = getAvailableTokens()
        unavailableTokens = getUnavailableTokens()
    }
}
