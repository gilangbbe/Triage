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

    // Only keep reminder notification histories
    private var reminderLogs: [History] {
        logs.filter {
            if case .patitentReminderNotification = $0.type { return true }
            return false
        }
    }

    private var sections: [(dateString: String, items: [History])] {
        let grouped = Dictionary(grouping: reminderLogs) { apptDateOnly(from: $0) ?? "—" }
        return grouped
            .map { (key, items) in
                (dateString: key, items: items.sorted { $0.timestamp > $1.timestamp })
            }
            .sorted { $0.dateString > $1.dateString }
    }

    private func apptDateOnly(from h: History) -> String? {
        if case .patitentReminderNotification(_, let appointmentDate, _) = h.type {
            if let range = appointmentDate.range(of: " with ") {
                return String(appointmentDate[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            }
            return appointmentDate
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

                // Content
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        ForEach(sections, id: \.dateString) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.dateString.uppercased())
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .padding(.leading, 8)

                                VStack(spacing: 0) {
                                    ForEach(section.items, id: \.id) { item in
                                        ReminderRow(history: item)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)

                                        if item.id != section.items.last?.id {
                                            Divider().overlay(Color(.separator)).opacity(0.35)
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        Spacer(minLength: 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: 1024)
            .padding(12)
            .transition(.scale.combined(with: .opacity))
        }
    }

    // MARK: - Helpers
    private func apptDateString(from h: History) -> String? {
        if case .patitentReminderNotification(_, let appointmentDate, _) = h.type {
            return appointmentDate
        }
        return nil
    }
}

private struct ReminderRow: View {
    let history: History

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.tertiarySystemFill))
                    .frame(width: 36, height: 36)
                Image(systemName: "bell.fill")
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.footnote.weight(.bold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(styledMessage(history))
                    .font(.callout)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            // Show the reminder log creation time
            Text(time(history.timestamp))
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(Color(.secondaryLabel))
                .frame(minWidth: 64, alignment: .trailing)
        }
    }

    private func styledMessage(_ h: History) -> AttributedString {
        switch h.type {
        case .patitentReminderNotification(let patientName, let appointmentDate, let AppointmentTime):
            var s = AttributedString("Patient ")
            var name = AttributedString(patientName); name.font = .callout.bold(); s.append(name)
            s.append(AttributedString(" has an appointment on "))
            var d = AttributedString(appointmentDate); d.font = .callout.bold(); s.append(d)
            s.append(AttributedString(" at "))
            var t = AttributedString(AppointmentTime); t.font = .callout.bold(); s.append(t)
            return s

        default:
            return AttributedString("")
        }
    }

    private func time(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
