//
//  CalendarReminderLog.swift
//  triage
//
//  Created by Hayya U on 04/09/25.
//

import SwiftUI

struct ReminderLogView: View {
    var logs: [History]
    var onClose: () -> Void

    // MARK: - Section model used by your ForEach
    private struct SectionGroup: Identifiable {
        let id = UUID()
        let date: String
        let logs: [History]
    }

    // Keep only reminder notification histories
    private var reminderLogs: [History] {
        logs.filter {
            if case .patitentReminderNotification = $0.type { return true }
            return false
        }
    }

    // Group by appointment date string only (remove trailing " with ...")
    private var groupedHistory: [SectionGroup] {
        let grouped = Dictionary(grouping: reminderLogs) { (h: History) -> String in
            apptDateOnly(from: h) ?? "—"
        }

        return grouped
            .map { key, items in
                SectionGroup(
                    date: key,
                    logs: items.sorted { $0.timestamp > $1.timestamp }
                )
            }
            // If your date strings are ISO-like (e.g., "2025-09-14"), this sorts correctly.
            // If not, consider converting to Date for reliable sorting.
            .sorted { $0.date > $1.date }
    }

    private func apptDateOnly(from h: History) -> String? {
        if case .patitentReminderNotification(_, let appointmentDate, _) = h.type {
            if let r = appointmentDate.range(of: " with ") {
                return String(appointmentDate[..<r.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
            return appointmentDate.trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Header
                ZStack {
                    HStack {
                        Button("Close", action: onClose)
                            .font(.body.weight(.semibold))
                        Spacer()
                    }
                    Text("Reminder Log")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(.label))
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                Divider().overlay(Color(.separator)).opacity(0.6)

                // Content (your requested block)
                if groupedHistory.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "bell.slash")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No reminder logs yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(groupedHistory, id: \.date) { section in
                                Text(section.date)
                                    .font(.headline)
                                    .padding(.vertical, 16)

                                VStack(spacing: 0) {
                                    ForEach(Array(section.logs.enumerated()), id: \.element.id) { index, log in
                                        HistoryRowView(historyLog: log)

                                        // Add divider except for last log
                                        if index < section.logs.count - 1 {
                                            Divider().padding(.horizontal, 4)
                                        }
                                    }
                                }
                                .background(Color.gray.opacity(0.05))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .frame(maxWidth: 1024)
            .padding(12)
            .transition(.scale.combined(with: .opacity))
        }
    }
}
