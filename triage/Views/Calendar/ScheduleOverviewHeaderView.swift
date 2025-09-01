//
//  ScheduleOverviewHeaderView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

struct OverviewHeader: View {
    @State private var mode: Mode = .daily
    enum Mode { case daily, weekly }

    var body: some View {
        HStack(spacing: 12) {
            Text("Schedule Overview")
                .font(.headline)

            Spacer()

            // segmented control: Daily / Weekly
            HStack(spacing: 0) {
                SegButton(title: "Daily", isOn: mode == .daily) { mode = .daily }
                SegButton(title: "Weekly", isOn: mode == .weekly) { mode = .weekly }
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            .padding(.trailing, 8)

            // plus button
            Button {
                // TODO: create appointment
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(Color(red: 0.08, green: 0.10, blue: 0.24)))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    private struct SegButton: View {
        let title: String
        let isOn: Bool
        let action: () -> Void
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isOn ? .white : .clear)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

