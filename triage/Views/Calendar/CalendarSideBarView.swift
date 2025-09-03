//
//  CalendarSideBar.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

struct SidebarPanel: View {
    @Binding var selectedDate: Date
    let appts: [Appt]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // page title
                Text("Schedule")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color(red: 0.08, green: 0.10, blue: 0.24))
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                // "Today's Schedule" header
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Today’s Schedule")
                            .font(.headline)
                        Spacer()
                        if !todaysAppts.isEmpty {
                            Text("\(todaysAppts.count)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                        }
                    }

                    Text(dateString(selectedDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)

                // Flat list of reminders, sorted by priority
                VStack(spacing: 12) {
                    ForEach(sortedReminders) { a in
                        ReminderCard(appt: a, style: .needToRemind) // or dynamic style if you have a flag
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 24)
            }
        }
    }

    // MARK: Data helpers
    private var todaysAppts: [Appt] {
        appts.filter { Calendar.current.isDate($0.start, inSameDayAs: selectedDate) }
    }

    private var sortedReminders: [Appt] {
        // Replace this with real priority logic when available
        todaysAppts.sorted { $0.start < $1.start }
    }

    private func dateString(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        return df.string(from: d)
    }
}
