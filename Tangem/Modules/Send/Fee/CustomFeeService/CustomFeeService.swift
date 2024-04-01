//
//  CustomFeeService.swift
//  Tangem
//
//  Created by Andrey Chukavin on 01.04.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk
import Combine

protocol CustomFeeService: AnyObject {
    var customFeePublisher: AnyPublisher<Fee?, Never> { get }
    func setInput(_ input: SendModel)
    func setFee(_ fee: Fee?)
    func didChangeCustomFee(enteredFee: Decimal?, input: SendFeeViewModelInput, walletInfo: SendWalletInfo)
    func models() -> [SendCustomFeeInputFieldModel]
    func recalculateFee(enteredFee: Decimal?, input: SendFeeViewModelInput, walletInfo: SendWalletInfo) -> Fee?
}
