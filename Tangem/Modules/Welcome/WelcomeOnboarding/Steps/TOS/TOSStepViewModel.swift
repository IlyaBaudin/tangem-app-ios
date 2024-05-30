//
//  TOSStepViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.05.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

class TOSStepViewModel: ObservableObject {
    private weak var routable: WelcomeOnboardingStepRoutable?

    init(routable: any WelcomeOnboardingStepRoutable) {
        self.routable = routable
    }
}
