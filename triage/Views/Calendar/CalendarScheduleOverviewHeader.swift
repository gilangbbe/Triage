//
//  ScheduleOverviewHeaderView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

struct OverviewHeader: View {
    var body: some View {
            HStack {
                Text("Schedule Overview")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.primary)

                Spacer()

                Button {
                } label: {
                    Text("Add")
                        .font(.headline)
                        .foregroundStyle(Color.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
    }
}
