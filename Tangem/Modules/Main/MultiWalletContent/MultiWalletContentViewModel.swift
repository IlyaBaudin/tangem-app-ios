//
//  MultiWalletContentViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class MultiWalletContentViewModel: ObservableObject {
    // MARK: - ViewState

    // MARK: - Dependencies

    private unowned let coordinator: MultiWalletContentRoutable

    init(
        coordinator: MultiWalletContentRoutable
    ) {
        self.coordinator = coordinator
    }
}
