//
//  CalendarHeaderView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

struct Header: View {
    @Binding var monthAnchor: Date
    @Binding var scope: CalendarView.Scope
    
    var body: some View {
        HStack(alignment: .center) {
            Text(monthYear(monthAnchor))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(CalTheme.navy)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("", selection: $scope) {
                ForEach(CalendarView.Scope.allCases, id: \.self) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 380)
        }
        .padding(.bottom, 12)
        .padding(.horizontal, 8)
    }
    
    private func monthYear(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: d)
    }
}
