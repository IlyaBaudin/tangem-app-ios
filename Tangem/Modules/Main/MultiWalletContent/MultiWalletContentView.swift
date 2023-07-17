//
//  MultiWalletContentView.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct MultiWalletContentView: View {
    @ObservedObject private var viewModel: MultiWalletContentViewModel

    init(viewModel: MultiWalletContentViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Hello, Multiwallet!")
        }
    }
}

struct MultiWalletContentView_Preview: PreviewProvider {
    static let viewModel = MultiWalletContentViewModel(coordinator: MultiWalletContentCoordinator())

    static var previews: some View {
        MultiWalletContentView(viewModel: viewModel)
    }
}
