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

struct CardsInfoPagerBodyView<ContentModel>: View {
    private let contentModel: ContentModel
    private let scrollViewConnector: CardsInfoPagerScrollViewConnector
    private let coordinateSpaceName = UUID()

    init(contentModel: ContentModel, scrollViewConnector: CardsInfoPagerScrollViewConnector) {
        self.contentModel = contentModel
        self.scrollViewConnector = scrollViewConnector
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0.0) {
                scrollViewConnector.placeholderView

                Spacer(minLength: 16)

                Text("Element with index")
            }
            .readContentOffset(
                to: scrollViewConnector.contentOffsetBinding,
                inCoordinateSpace: .named(coordinateSpaceName)
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        CardsInfoPagerView(
            data: viewModel.cardsIndicies,
            selectedIndex: $viewModel.selectedCardIndex,
            headerFactory: { pageViewModel in
                Text("")
//                MultiWalletCardHeaderView(viewModel: pageViewModel.header)
//                    .cornerRadius(14.0)
            },
            contentFactory: { element, scrollViewConnector in
                CardsInfoPagerBodyView(contentModel: element, scrollViewConnector: scrollViewConnector)
            }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Assets.tangemLogo.image
                    .foregroundColor(Colors.Icon.primary1)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 0) {
                    Button(action: {
                        print("Scan button tapped")
                    }) {
                        Assets.scanWithPhone.image
                            .foregroundColor(Colors.Icon.primary1)
                    }

                    Button {
                        print("Details navigation tapped")
                    } label: {
                        Assets.verticalDots.image
                            .foregroundColor(Colors.Icon.primary1)
                    }
                }
            }
        }
    }
}

class FakeUserWalletModel: UserWalletModel, ObservableObject {
    var isMultiWallet: Bool
    var userWalletId: UserWalletId
    @Published var walletModels: [WalletModel]
    var userTokenListManager: UserTokenListManager
    var totalBalanceProvider: TotalBalanceProviding
    var userWallet: UserWallet

    internal init(isMultiWallet: Bool, userWalletId: UserWalletId, walletModels: [WalletModel], userWallet: UserWallet) {
        self.isMultiWallet = isMultiWallet
        self.userWalletId = userWalletId
        self.walletModels = walletModels
        self.userTokenListManager = CommonUserTokenListManager(hasTokenSynchronization: false, userWalletId: userWalletId.value)
        self.totalBalanceProvider = TotalBalanceProviderMock()
        self.userWallet = userWallet
    }

    func subscribeToWalletModels() -> AnyPublisher<[WalletModel], Never> {
        $walletModels.eraseToAnyPublisher()
    }

    func getSavedEntries() -> [StorageEntry] {
        []
    }

    func getEntriesWithoutDerivation() -> [StorageEntry] {
        []
    }

    func subscribeToEntriesWithoutDerivation() -> AnyPublisher<[StorageEntry], Never> {
        .just(output: [])
    }

    func canManage(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool {
        true
    }

    func update(entries: [StorageEntry]) {

    }

    func append(entries: [StorageEntry]) {

    }

    func remove(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) {

    }

    func initialUpdate() {

    }

    func updateWalletName(_ name: String) {

    }

    func updateWalletModels() {

    }

    func updateAndReloadWalletModels(silent: Bool, completion: @escaping () -> Void) {

    }
}

class FakeUserWalletRepo: UserWalletRepository {
    var models: [UserWalletModel] = []

    var selectedModel: CardViewModel?

    var selectedUserWalletId: Data?

    var isEmpty: Bool { models.contains(where: { $0.walletModels.isEmpty })}

    var count: Int { models.count }

    var isLocked: Bool = false

    var eventProvider: AnyPublisher<UserWalletRepositoryEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private let eventSubject = PassthroughSubject<UserWalletRepositoryEvent, Never>()

    init() { }

    func unlock(with method: UserWalletRepositoryUnlockMethod, completion: @escaping (UserWalletRepositoryResult?) -> Void) {

    }

    func setSelectedUserWalletId(_ userWalletId: Data?, reason: UserWalletRepositorySelectionChangeReason) {

    }

    func updateSelection() {

    }

    func logoutIfNeeded() {

    }

    func add(_ completion: @escaping (UserWalletRepositoryResult?) -> Void) {

    }

    func save(_ cardViewModel: CardViewModel) {

    }

    func contains(_ userWallet: UserWallet) -> Bool {
        false
    }

    func save(_ userWallet: UserWallet) {

    }

    func delete(_ userWallet: UserWallet, logoutIfNeeded shouldAutoLogout: Bool) {

    }

    func clear() {

    }

    func initialize() {

    }


}

struct MainView_Preview: PreviewProvider {
    static let viewModel = MainViewModel(coordinator: MainCoordinator(), userWalletRepository: FakeUserWalletRepo())

    static var previews: some View {
        NavigationView {
            MainView(viewModel: viewModel)
        }
    }
}
