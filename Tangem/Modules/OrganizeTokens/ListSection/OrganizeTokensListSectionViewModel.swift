//
//  OrganizeTokensListSection.swift
//  Tangem
//
//  Created by m3g0byt3 on 06.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct OrganizeTokensListSectionViewModel: Hashable, Identifiable {
    enum SectionStyle: Hashable {
        case invisible
        case fixed(title: String)
        case draggable(title: String)
    }

    var id = UUID()
    var style: SectionStyle
    var items: [OrganizeTokensListItemViewModel]
}
