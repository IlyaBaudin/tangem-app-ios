//
//  MainView.swift
//  Tangem
//
//  Created by Andrew Son on 27/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI
import BlockchainSdk

struct CardsPagerContent<Content: View>: View {
    private let coordinateSpaceName = UUID()

    private let contentView: Content
    private let scrollViewConnector: CardsInfoPagerScrollViewConnector

    init(scrollViewConnector: CardsInfoPagerScrollViewConnector, @ViewBuilder content: () -> Content) {
        self.scrollViewConnector = scrollViewConnector
        contentView = content()
    }

    var body: some View {
        RefreshableScrollView(onRefresh: { completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion()
            }
        }) {
            LazyVStack(spacing: 0.0) {
                scrollViewConnector.headerPlaceholderView

                Spacer(minLength: 16)

                contentView
            }
            .readContentOffset(
                inCoordinateSpace: .named(coordinateSpaceName),
                bindTo: scrollViewConnector.contentOffset
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        CardsInfoPagerView(
            data: viewModel.pages,
            selectedIndex: $viewModel.selectedCardIndex,
            headerFactory: { info in
                info.header
            },
            contentFactory: { info, scrollViewConnector in
                info.body(scrollViewConnector)
            }
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
