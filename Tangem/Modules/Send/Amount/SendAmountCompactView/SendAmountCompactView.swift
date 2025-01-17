//
//  SendAmountCompactView.swift
//  Tangem
//
//  Created by Sergey Balashov on 19.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct SendAmountCompactView: View {
    @ObservedObject var viewModel: SendAmountCompactViewModel
    let type: SendCompactViewEditableType
    let namespace: SendAmountView.Namespace

    var body: some View {
        GroupedSection(viewModel) { _ in
            amountContent
        }
        .innerContentPadding(16)
        .backgroundColor(type.background)
        .geometryEffect(.init(id: namespace.names.amountContainer, namespace: namespace.id))
        .readGeometry(\.size, bindTo: $viewModel.viewSize)
        .contentShape(Rectangle())
        .onTapGesture {
            if case .enabled(.some(let action)) = type {
                action()
            }
        }
    }

    private var amountContent: some View {
        VStack(spacing: 18) {
            TokenIcon(tokenIconInfo: viewModel.tokenIconInfo, size: CGSize(width: 36, height: 36))
                .matchedGeometryEffect(id: namespace.names.tokenIcon, in: namespace.id)

            VStack(alignment: .center, spacing: 6) {
                ZStack {
                    Text(viewModel.amount ?? " ")
                        .style(
                            DecimalNumberTextField.Appearance().font,
                            color: DecimalNumberTextField.Appearance().textColor
                        )
                        .infinityFrame(axis: .horizontal, alignment: .center)
                        .minimumScaleFactor(SendView.Constants.amountMinTextScale)
                        .matchedGeometryEffect(id: namespace.names.amountCryptoText, in: namespace.id)
                }
                // We have to keep frame until SendDecimalNumberTextField size fix
                // Just on appear it has the zero height. Is cause break animation
                .frame(height: 35)

                // Keep empty text so that the view maintains its place in the layout
                Text(viewModel.alternativeAmount ?? " ")
                    .style(Fonts.Regular.footnote, color: Colors.Text.tertiary)
                    .lineLimit(1)
                    .matchedGeometryEffect(id: namespace.names.amountFiatText, in: namespace.id)
            }
            .infinityFrame(axis: .horizontal, alignment: .center)
        }
    }
}
