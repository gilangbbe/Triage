//
//  OverviewHeaderView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

struct OverviewHeader: View {
    @Binding var showAddAppointment: Bool
    var body: some View {
            HStack {
                Text("Schedule Overview")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.primary)

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showAddAppointment = true }
                } label: {
                    Text("Add")
                        .font(.headline)
                        .foregroundStyle(Color("TextPrimary"))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
    }
}
