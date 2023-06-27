//
//  MainCoordinator.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class MainCoordinator: CoordinatorObject {
    let dismissAction: Action
    let popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Root view model

    @Published private(set) var mainViewModel: MainViewModel?

    // MARK: - Child coordinators

    // MARK: - Child view models

    required init(
        dismissAction: @escaping Action,
        popToRootAction: @escaping ParamsAction<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {

    }
}

// MARK: - Options

extension MainCoordinator {
    struct Options {
        let cardViewModel: CardViewModel
    }
}

// MARK: - MainRoutable

extension MainCoordinator: MainRoutable {}
