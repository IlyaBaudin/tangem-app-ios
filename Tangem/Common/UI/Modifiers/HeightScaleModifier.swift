//
//  HeightScaleModifier.swift
//  Tangem
//
//  Created by Andrew Son on 05/10/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct HeightScaleModifier: ViewModifier {
    let height: CGFloat

    func body(content: Content) -> some View {
        content.scaleEffect(y: height, anchor: .top)
            .offset(y: -75 + 75 * height)
    }
}

extension AnyTransition {
    static var notificationTransition: AnyTransition {
        AnyTransition.modifier(
            active: HeightScaleModifier(height: 0.6),
            identity: HeightScaleModifier(height: 1)
        ).animation(.easeInOut(duration: 0.3))
            .combined(with: .asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.4)), removal: .opacity.animation(.easeOut(duration: 0.3))))
    }
}
