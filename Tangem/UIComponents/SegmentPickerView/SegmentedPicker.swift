//
//  SegmentedPicker.swift
//  Tangem
//
//  Created by Dmitry Fedorov on 25.07.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

struct SegmentedPicker<Option: Hashable & Identifiable>: View {
    @Binding var selectedOption: Option

    let options: [Option]
    let shouldStretchToFill: Bool
    let titleFactory: (Option) -> String

    var body: some View {
        SegmentedPickerView(
            selection: $selectedOption,
            options: options,
            shouldStretchToFill: shouldStretchToFill,
            selectionView: selectionView,
            segmentContent: { option, _ in
                segmentView(title: titleFactory(option), isSelected: selectedOption == option)
                    .animation(.none, value: selectedOption)
            }
        )
        .insets(Constants.insets)
        .segmentedControlSlidingAnimation(.easeInOut)
        .segmentedControl(interSegmentSpacing: Constants.interSegmentSpacing)
        .background(Colors.Button.secondary)
        .clipShape(RoundedRectangle(cornerRadius: Constants.containerCornerRadius))
    }

    private func segmentView(title: String, isSelected: Bool) -> some View {
        ZStack(alignment: .center) {
            Text(title)
                .font(Fonts.Bold.footnote)
                .foregroundStyle(Colors.Text.primary1)
                .opacity(isSelected ? 1.0 : 0.0)

            Text(title)
                .font(Fonts.Regular.footnote)
                .foregroundStyle(Colors.Text.primary1)
                .opacity(isSelected ? 0.0 : 1.0)
        }
        .animation(.default, value: isSelected)
        .lineLimit(1)
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
    }

    private var selectionView: some View {
        Colors.Background.primary
            .clipShape(RoundedRectangle(cornerRadius: Constants.selectionViewCornerRadius))
    }
}

private extension SegmentedPicker {
    enum Constants {
        static var insets: EdgeInsets { .init(top: 2, leading: 2, bottom: 2, trailing: 2) }
        static var interSegmentSpacing: CGFloat { 0 }
        static var containerCornerRadius: CGFloat { 8 }
        // We need to use an odd value, otherwise the rounding curvature of the selection
        // will be noticeably different from the background rounding curvature
        static var selectionViewCornerRadius: CGFloat { 7 }
    }
}