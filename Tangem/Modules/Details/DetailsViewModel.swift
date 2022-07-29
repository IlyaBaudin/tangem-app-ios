//
//  DetailsViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import TangemSdk
import BlockchainSdk

class DetailsViewModel: ObservableObject {
    // MARK: - Dependencies

    @Injected(\.cardsRepository) private var cardsRepository: CardsRepository
    @Injected(\.onboardingStepsSetupService) private var onboardingStepsSetupService: OnboardingStepsSetupService
    private let dataCollector: DetailsFeedbackDataCollector


    // MARK: - View State

    @Published var cardModel: CardViewModel
    @Published var error: AlertBinder?

    var canCreateBackup: Bool {
        if !cardModel.cardInfo.isTangemWallet {
            return false
        }

        if !cardModel.cardInfo.card.settings.isBackupAllowed {
            return false
        }

        // todo: respect involved cards

        return cardModel.cardInfo.card.backupStatus == .noBackup
    }

    var shouldShowWC: Bool {
        if cardModel.cardInfo.isTangemNote {
            return false
        }

        if cardModel.cardInfo.card.isStart2Coin {
            return false
        }

        if cardModel.cardInfo.card.isTwinCard {
            return false
        }

        if !cardModel.cardInfo.card.supportedCurves.contains(.secp256k1) {
            return false
        }

        return true
    }

    var isTwinCard: Bool {
        cardModel.isTwinCard
    }

    var cardTOUURL: URL? {
        guard cardModel.isStart2CoinCard else { // is this card is S2C
            return nil
        }

        return buildCardTOUURL()
    }

    var applicationInfoFooter: String? {
        guard let appName = InfoDictionaryUtils.appName.value,
              let version = InfoDictionaryUtils.version.value,
              let bundleVersion = InfoDictionaryUtils.bundleVersion.value else {
            return nil
        }

        return String(
            format: "%@ %@ (%@)",
            arguments: [appName, version, bundleVersion]
        )
    }

    // MARK: - Private

    private var bag = Set<AnyCancellable>()
    private unowned let coordinator: DetailsRoutable

    init(cardModel: CardViewModel, coordinator: DetailsRoutable) {
        self.cardModel = cardModel
        self.coordinator = coordinator
        dataCollector = DetailsFeedbackDataCollector(cardModel: cardModel)

        bind()
    }

    func prepareTwinOnboarding() {
        onboardingStepsSetupService.twinRecreationSteps(for: cardModel.cardInfo)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    Analytics.log(error: error)
                    print("Failed to load image for new card")
                    self.error = error.alertBinder
                case .finished:
                    break
                }
            } receiveValue: { [weak self] steps in
                guard let self = self else { return }

                let input = OnboardingInput(steps: steps,
                                            cardInput: .cardModel(self.cardModel),
                                            welcomeStep: nil,
                                            currentStepIndex: 0,
                                            isStandalone: true)

                self.openOnboarding(with: input)
            }
            .store(in: &bag)
    }

    func prepareBackup() {
        onboardingStepsSetupService.backupSteps(cardModel.cardInfo)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    Analytics.log(error: error)
                    print("Failed to load image for new card")
                    self.error = error.alertBinder
                case .finished:
                    break
                }
            } receiveValue: { [weak self] steps in
                guard let self = self else { return }

                let input = OnboardingInput(steps: steps,
                                            cardInput: .cardModel(self.cardModel),
                                            welcomeStep: nil,
                                            currentStepIndex: 0,
                                            isStandalone: true)

                self.openOnboarding(with: input)
            }
            .store(in: &bag)
    }
}

// MARK: - Navigation

extension DetailsViewModel {
    func openOnboarding(with input: OnboardingInput) {
        coordinator.openOnboardingModal(with: input)
    }

    func openMail() {
        coordinator.openMail(with: dataCollector,
                             support: cardModel.emailSupport,
                             emailType: .appFeedback(support: cardModel.isStart2CoinCard ? .start2coin : .tangem))
    }

    func openWalletConnect() {
        coordinator.openWalletConnect(with: cardModel)
    }

    func openDisclaimer() {
        coordinator.openDisclaimer()
    }

    func openCardTOU(url: URL) {
        coordinator.openCardTOU(url: url)
    }

    func openCardSettings() {
        coordinator.openScanCardSettings()
    }

    func openAppSettings() {
        coordinator.openAppSettings()
    }

    func openSupportChat() {
        coordinator.openSupportChat()
    }

    func openSocialNetwork(network: SocialNetwork) {
        guard let url = network.url else {
            return
        }

        coordinator.openInSafari(url: url)
    }
}

// MARK: - Private

private extension DetailsViewModel {
    func bind() {
        cardModel.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &bag)
    }

    func buildCardTOUURL() -> URL? {
        let baseurl = "https://app.tangem.com/tou/"
        let regionCode = regionCode(for: cardModel.cardInfo.card.cardId) ?? "fr"
        let languageCode = Locale.current.languageCode ?? "fr"
        let filename = filename(languageCode: languageCode, regionCode: regionCode)
        let url = URL(string: baseurl + filename)
        return url
    }

    func filename(languageCode: String, regionCode: String) -> String {
        switch (languageCode, regionCode) {
        case ("fr", "ch"):
            return "Start2Coin-fr-ch-tangem.pdf"
        case ("de", "ch"):
            return "Start2Coin-de-ch-tangem.pdf"
        case ("en", "ch"):
            return "Start2Coin-en-ch-tangem.pdf"
        case ("it", "ch"):
            return "Start2Coin-it-ch-tangem.pdf"
        case ("fr", "fr"):
            return "Start2Coin-fr-fr-atangem.pdf"
        case ("de", "at"):
            return "Start2Coin-de-at-tangem.pdf"
        case (_, "fr"):
            return "Start2Coin-fr-fr-atangem.pdf"
        case (_, "ch"):
            return "Start2Coin-en-ch-tangem.pdf"
        case (_, "at"):
            return "Start2Coin-de-at-tangem.pdf"
        default:
            return "Start2Coin-fr-fr-atangem.pdf"
        }
    }

    func regionCode(for cid: String) -> String? {
        let cidPrefix = cid[cid.index(cid.startIndex, offsetBy: 1)]
        switch cidPrefix {
        case "0":
            return "fr"
        case "1":
            return "ch"
        case "2":
            return "at"
        default:
            return nil
        }
    }
}
