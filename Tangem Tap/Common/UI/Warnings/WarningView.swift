//
//  WarningView.swift
//  Tangem Tap
//
//  Created by Andrew Son on 22/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import SwiftUI

struct Counter {
    let number: Int
    let totalCount: Int
}

struct CounterView: View {
    
    let counter: Counter
    
    var body: some View {
        HStack {
            Text("\(counter.number)/\(counter.totalCount)")
                .font(.system(size: 13, weight: .medium, design: .default))
        }
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
        .frame(minWidth: 40, minHeight: 24, maxHeight: 24)
        .background(Color.tangemTapGrayDark5)
        .cornerRadius(50)
    }
}

struct WarningView: View {
    
    let warning: TapWarning
    var buttonAction: () -> Void = { }
    
    var body: some View {
        ZStack {
            warning.priority.backgroundColor
                .cornerRadius(6)
            VStack(alignment: .leading, spacing: 0) {
                Text(warning.title)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .foregroundColor(.white)
                Text(warning.message)
                    .font(.system(size: 13, weight: .medium))
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(warning.priority.messageColor)
                    .padding(.bottom, warning.type.isWithAction ? 8 : 16)
                    
                if warning.type.isWithAction {
                    HStack {
                        Spacer()
                        Button(action: buttonAction, label: {
                            Text("wallet_warning_button_ok")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        })
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 20))
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, 16)
        
    }
}

struct WarningView_Previews: PreviewProvider {
    @State static var warnings: [TapWarning] = [WarningEvent.devCard.warning, WarningEvent.numberOfSignedHashesIncorrect.warning, WarningEvent.oldDeviceOldCard.warning]
    static var previews: some View {
        ScrollView {
            ForEach(Array(warnings.enumerated()), id: \.element) { (i, item) in
                WarningView(warning: warnings[i]) {
                    withAnimation {
                        print("Ok button tapped")
                        warnings.remove(at: i)
                    }
                }
                .transition(.opacity)
            }
        }
        
    }
}
