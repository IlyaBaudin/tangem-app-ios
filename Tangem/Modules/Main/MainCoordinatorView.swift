//
//  MainCoordinatorView.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct MainCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: MainCoordinator

    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if let mainViewModel = coordinator.mainViewModel {
                MainView(viewModel: mainViewModel)
                    .navigationLinks(links)
            }

            sheets
        }
    }

    @ViewBuilder
    private var links: some View {
        EmptyView()
    }

    @ViewBuilder
    private var sheets: some View {
        EmptyView()
    }
}
