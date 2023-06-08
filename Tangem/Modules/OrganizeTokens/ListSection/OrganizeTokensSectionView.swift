//
//  OrganizeTokensSectionView.swift
//  Tangem
//
//  Created by m3g0byt3 on 06.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct OrganizeTokensSectionView: View {
    let title: String
    let isDraggable: Bool

    var body: some View {
        HStack(spacing: 12.0) {
            Text(title)
                .style(Fonts.Bold.footnote, color: Colors.Text.tertiary)
                .lineLimit(1)

            Spacer(minLength: 0.0)

            if isDraggable {
                Assets.OrganizeTokens.groupDragAndDropIcon
                    .image
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(size: .init(bothDimensions: 20.0))
                    .foregroundColor(Colors.Icon.informative)
            }
        }
        .padding(.horizontal, 14.0)
        .frame(height: 42.0)
    }
}

// MARK: - Previews

struct OrganizeTokensSectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Group {
                OrganizeTokensSectionView(
                    title: "Bitcoin network",
                    isDraggable: true
                )

                OrganizeTokensSectionView(
                    title: "Bitcoin network",
                    isDraggable: false
                )
            }
            .background(Colors.Background.primary)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(Colors.Background.secondary)
    }
}
