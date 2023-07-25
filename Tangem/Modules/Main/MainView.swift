//
//  MainView.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        CardsInfoPagerView(
            data: viewModel.pages,
            selectedIndex: $viewModel.selectedCardIndex,
            headerFactory: { info in
                info.header
            },
            contentFactory: { info in
                info.body
            },
            onPullToRefresh: viewModel.onPullToRefresh(completionHandler:)
        )
        .navigationBarBackButtonHidden(true)
        .background(Colors.Background.secondary.edgesIgnoringSafeArea(.all))
        .ignoresSafeArea(.keyboard)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MainView_Preview: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: .init(coordinator: MainCoordinator(), userWalletRepository: FakeUserWalletRepository()))
    }
}
