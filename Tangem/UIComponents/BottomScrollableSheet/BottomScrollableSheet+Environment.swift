//
//  BottomScrollableSheet+Environment.swift
//  Tangem
//
//  Created by Andrey Fedorov on 01.12.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

// MARK: - Convenience extensions

extension View {
    func onBottomScrollableSheetStateChange(
        _ observer: @escaping BottomScrollableSheetStateObserver
    ) -> some View {
        return environment(\.bottomScrollableSheetStateObserver, observer)
    }
}

extension EnvironmentValues {
    var bottomScrollableSheetStateObserver: BottomScrollableSheetStateObserver? {
        get { self[BottomScrollableSheetStateObserverEnvironmentKey.self] }
        set { self[BottomScrollableSheetStateObserverEnvironmentKey.self] = newValue }
    }
}

// MARK: - Private implementation

private enum BottomScrollableSheetStateObserverEnvironmentKey: EnvironmentKey {
    static var defaultValue: BottomScrollableSheetStateObserver? { nil }
}
