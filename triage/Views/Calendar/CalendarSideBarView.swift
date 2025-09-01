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
                // page title (optional)
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
                        // small count badge
                        let todays = todaysAppts
                        if !todays.isEmpty {
                            Text("\(todays.count)")
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

                // Section 1
                SectionHeader(title: "NEED TO REMIND")
                    .padding(.top, 4)
                    .padding(.horizontal, 20)

                VStack(spacing: 12) {
                    ForEach(needToRemind) { a in
                        ReminderCard(appt: a, style: .needToRemind)
                    }
                }
                .padding(.horizontal, 16)

                // Section 2
                SectionHeader(title: "REMIND AGAIN")
                    .padding(.top, 8)
                    .padding(.horizontal, 20)

                VStack(spacing: 12) {
                    ForEach(remindAgain) { a in
                        ReminderCard(appt: a, style: .remindAgain)
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 24)
            }
        }
    }

    // MARK: Derived groups (replace with real flags later)
    private var todaysAppts: [Appt] {
        appts.filter { Calendar.current.isDate($0.start, inSameDayAs: selectedDate) }
              .sorted { $0.start < $1.start }
    }

    /// Placeholder split: morning vs afternoon
    private var needToRemind: [Appt] {
        todaysAppts.filter { Calendar.current.component(.hour, from: $0.start) <= 12 }
    }
    private var remindAgain: [Appt] {
        todaysAppts.filter { Calendar.current.component(.hour, from: $0.start) > 12 }
    }

    // MARK: helpers
    private func dateString(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM d, yyyy"
        return df.string(from: d)
    }
}

private struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
    }
}

