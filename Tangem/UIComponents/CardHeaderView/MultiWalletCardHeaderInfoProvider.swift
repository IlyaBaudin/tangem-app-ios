//
//  MultiWalletCardHeaderInfoProvider.swift
//  Tangem
//
//  Created by Andrew Son on 22/05/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol CardHeaderSubtitleProvider: AnyObject {
    var subtitlePublisher: AnyPublisher<String, Never> { get }
}

protocol CardHeaderInfoProvider: AnyObject {
    var cardNamePublisher: AnyPublisher<String, Never> { get }
    var cardImage: ImageType? { get }
}
