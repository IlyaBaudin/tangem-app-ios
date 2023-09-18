//
//  ManageTokensSheetView.swift
//  Tangem
//
//  Created by Sergey Balashov on 01.08.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

extension View {
    func manageTokens(
        viewModel: ManageTokensSheetViewModel,
        stateObject: BottomScrollableSheetStateObject
    ) -> some View {
        modifier(ManageTokensViewModifier(
            viewModel: viewModel,
            stateObject: stateObject
        )
        )
    }
}

struct ManageTokensViewModifier: ViewModifier {
    @ObservedObject private var viewModel: ManageTokensSheetViewModel
    // @ObservedObject
    private var stateObject: BottomScrollableSheetStateObject

    init(
        viewModel: ManageTokensSheetViewModel,
        stateObject: BottomScrollableSheetStateObject
    ) {
        self.viewModel = viewModel
        self.stateObject = stateObject
    }

    func body(content: Content) -> some View {
//        ZStack {
        content
            .overlay(bottomSheet)

//            bottomSheet
//
//            sheets
//        }
    }

    private var bottomSheet: some View {
        BottomScrollableSheet(stateObject: stateObject) {
            TextField("Placeholder", text: $viewModel.searchText)
                .frame(height: 46)
                .padding(.horizontal, 12)
                .background(Colors.Field.primary)
                .cornerRadius(14)
                .padding(.horizontal, 16)
        } content: {
            LazyVStack(spacing: .zero) {
                ForEach(0 ..< 3) { i in
                    Button(action: viewModel.toggleItem) {
                        TestText(text: i.description)
                            .frame(height: 100)
                            .background(Color.green.opacity(0.4))
                            .id(i)
//                            .contentShape(Rectangle())
                    }
//                    .buttonStyle(PlainButtonStyle())
//                        .onAppear {
//                            print("onAppear \(index)", Date().timeIntervalSince1970)
//                        }

//                    Divider()
                }
            }
            .readGeometry(inCoordinateSpace: .global) { value in
                if stateObject.contentSize != value.size {
                    stateObject.contentSize = value.size
                    print("readGeometry --> value", value.size)
                }
            }
        }
    }

    private var sheets: some View {
        NavHolder()
            .bottomSheet(item: $viewModel.bottomSheet) {
                BottomSheetContainer_Previews.BottomSheetView(viewModel: $0)
            }
    }
}

struct ManageTokensSheetView<RootContent: View>: View {
    @ObservedObject private var viewModel: ManageTokensSheetViewModel
    // @ObservedObject
    private var stateObject: BottomScrollableSheetStateObject
    private let content: () -> RootContent

    init(
        viewModel: ManageTokensSheetViewModel,
        stateObject: BottomScrollableSheetStateObject,
        @ViewBuilder content: @escaping () -> RootContent
    ) {
        self.viewModel = viewModel
        self.stateObject = stateObject
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content()

            bottomSheet

            sheets
        }
    }

    private var bottomSheet: some View {
        BottomScrollableSheet(stateObject: stateObject) {
            TextField("Placeholder", text: $viewModel.searchText)
                .frame(height: 46)
                .padding(.horizontal, 12)
                .background(Colors.Field.primary)
                .cornerRadius(14)
                .padding(.horizontal, 16)
        } content: {
            LazyVStack(spacing: .zero) {
                ForEach(0 ..< 3) { i in
                    Button(action: viewModel.toggleItem) {
                        TestText(text: i.description)
                            .frame(height: 100)
                            .background(Color.green.opacity(0.4))
                            .id(i)
//                            .contentShape(Rectangle())
                    }
//                    .buttonStyle(PlainButtonStyle())
//                        .onAppear {
//                            print("onAppear \(index)", Date().timeIntervalSince1970)
//                        }

//                    Divider()
                }
            }
            .readGeometry(inCoordinateSpace: .global) { value in
                if stateObject.contentSize != value.size {
                    stateObject.contentSize = value.size
                    print("readGeometry --> value", value.size)
                }
            }
        }
    }

    private var sheets: some View {
        NavHolder()
            .bottomSheet(item: $viewModel.bottomSheet) {
                BottomSheetContainer_Previews.BottomSheetView(viewModel: $0)
            }
    }
}

private var index: Int = 0

struct TestText: View, Identifiable {
    var id: String { text }

    let text: String
    init(text: String) {
        self.text = text
        index += 1

        print("init TestText index \(index), text: \(text)")
    }

    var body: some View {
        Text(text)
            .font(.title3)
            .foregroundColor(Color.black.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all)
            .lineLimit(1)
    }
}
