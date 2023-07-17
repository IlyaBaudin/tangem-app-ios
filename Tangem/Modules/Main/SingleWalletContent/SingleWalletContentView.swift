//
//  SingleWalletContentView.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct SingleWalletContentView: View {
    @ObservedObject private var viewModel: SingleWalletContentViewModel

    init(viewModel: SingleWalletContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Hello, single wallet!")
        }
    }
}

struct SingleWalletContentView_Preview: PreviewProvider {
    static let viewModel = SingleWalletContentViewModel(coordinator: SingleWalletContentCoordinator())

    static var previews: some View {
        SingleWalletContentView(viewModel: viewModel)
    }
}
