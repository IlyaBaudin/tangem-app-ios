//
//  MainViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class MainViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var models: [UserWalletModel] = []
    @Published var cardsIndicies = [0, 1, 2]
    @Published var selectedCardIndex = 0

    // MARK: - Dependencies

    private let userWalletRepository: UserWalletRepository
    private unowned let coordinator: MainRoutable

    private var bag = Set<AnyCancellable>()

    init(coordinator: MainRoutable, userWalletRepository: UserWalletRepository) {
        self.coordinator = coordinator
        self.userWalletRepository = userWalletRepository

        models = userWalletRepository.models
    }

    convenience init(
        cardViewModel: CardViewModel,
        coordinator: MainRoutable,
        userWalletRepository: UserWalletRepository
    ) {
        self.init(coordinator: coordinator, userWalletRepository: userWalletRepository)

        if let selectedIndex = models.firstIndex(where: { $0.userWalletId == cardViewModel.userWalletId }) {
            selectedCardIndex = selectedIndex
        }
    }

    func scanNewCard() {}

    func openDetails() {}

    private func bind() {}
}
