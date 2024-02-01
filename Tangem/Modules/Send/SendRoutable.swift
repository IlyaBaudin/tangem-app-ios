//
//  SendRoutable.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

protocol SendRoutable: SendFinishRoutable, AnyObject {
    func openMail(with dataCollector: EmailDataCollector, recipient: String)
    func openQRScanner(with codeBinding: Binding<String>, networkName: String)
    func presentNetworkCurrency(for walletModel: WalletModel, userWalletModel: UserWalletModel)
}
