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
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 24)
                        .background(RoundedRectangle(cornerSize: CGSize(width:24,height:24)).fill(Color(.systemBlue)))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
    }
}
