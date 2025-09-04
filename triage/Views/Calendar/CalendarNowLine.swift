//
//  NowLineView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

struct NowLine: View {
    let day: Date
    let minuteHeight: CGFloat

    var body: some View {
        if Calendar.current.isDateInToday(day) {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
            let mins = CGFloat((comps.hour ?? 0) * 60 + (comps.minute ?? 0))
            Rectangle()
                .fill(Color.red.opacity(0.7))
                .frame(height: 1)
                .offset(y: mins * minuteHeight)
        } else {
            EmptyView()
        }
    }
}
