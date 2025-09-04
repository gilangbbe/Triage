//
//  CalendarSideBar.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

struct SidebarPanel: View {
    @Binding var selectedDate: Date
    @Binding var showLog: Bool
    @Binding var logEntries: [ReminderEntry]
    let appts: [Appt]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Schedule")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(Color(red: 0.08, green: 0.10, blue: 0.24))
                    Spacer()
                    Button {
                        logEntries = buildLog(from: appts, asOf: selectedDate)
                        withAnimation(.easeInOut(duration: 0.2)) { showLog = true }
                    } label: {
                        Label("Reminder Log", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            .labelStyle(.iconOnly)
                            .font(.title3.weight(.semibold))
                            .padding(10)
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)

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

                    DaySelector(date: $selectedDate)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 20)


                VStack(spacing: 12) {
                    ForEach(sortedReminders) { a in
                        ReminderCard(appt: a, style: .needToRemind)
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 24)
            }
        }
    }
    
    private func buildLog(from appts: [Appt], asOf day: Date) -> [ReminderEntry] {
        let cal = Calendar.current
        let todays = appts.filter { cal.isDate($0.start, inSameDayAs: day) }
        let sentBase = cal.date(byAdding: .day, value: -1, to: day) ?? day
        let sentAt = cal.date(bySettingHour: 7, minute: 36, second: 0, of: sentBase) ?? sentBase

        return todays.map {
            ReminderEntry(patientName: $0.patient,
                          apptKind: $0.tag,
                          apptDate: $0.start,
                          sentAt: sentAt)
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
