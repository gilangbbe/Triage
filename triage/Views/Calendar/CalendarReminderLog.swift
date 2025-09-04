//
//  CalendarReminderLog.swift
//  triage
//
//  Created by Hayya U on 04/09/25.
//

import SwiftUI

struct ReminderEntry: Identifiable, Hashable {
    let id = UUID()
    let patientName: String
    let apptKind: String
    let apptDate: Date
    let sentAt: Date
}

// MARK: - Reminder Log overlay

struct ReminderLogView: View {
    var entries: [ReminderEntry]
    var onClose: () -> Void

    private let cal = Calendar.current
    private let headerLocale = Locale(identifier: "id_ID")

    private var sections: [(day: Date, items: [ReminderEntry])] {
        let grouped = Dictionary(grouping: entries) { cal.startOfDay(for: $0.sentAt) }
        return grouped
            .map { ($0.key, $0.value.sorted { $0.sentAt > $1.sentAt }) }
            .sorted { $0.0 > $1.0 }
    }

    var body: some View {
        ZStack {
            // dark scrim
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { onClose() } }

            VStack(spacing: 16) {
                // header
                ZStack {
                    HStack {
                        Button("Close", action: onClose)
                            .font(.body.weight(.semibold))
                        Spacer()
                    }
                    Text("Reminder Log")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(red: 0.08, green: 0.10, blue: 0.24))
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                Divider().opacity(0.15)

                // content
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        ForEach(sections, id: \.day) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(sectionHeader(for: section.day))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                    .padding(.leading, 8)

                                VStack(spacing: 6) {
                                    ForEach(section.items) { item in
                                        ReminderRow(entry: item)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 10)
                                        if item.id != section.items.last?.id {
                                            Divider().opacity(0.08)
                                        }
                                    }
                                }
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.12), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
                            }
                            .padding(.horizontal, 20)
                        }
                        Spacer(minLength: 8)
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: 820)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.12), lineWidth: 1)
            )
            .padding(24)
            .transition(.scale.combined(with: .opacity))
        }
    }

    private func sectionHeader(for day: Date) -> String {
        let df = DateFormatter()
        df.locale = headerLocale
        df.setLocalizedDateFormatFromTemplate("d MMMM") // “28 Agustus”
        return df.string(from: day).uppercased()
    }
}

private struct ReminderRow: View {
    let entry: ReminderEntry
    private let cal = Calendar.current

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6))
                    .frame(width: 36, height: 36)
                Image(systemName: "person.fill")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(styledMessage(entry))
                    .font(.callout)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            Text(time(entry.sentAt))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(minWidth: 72, alignment: .trailing)
        }
    }

    private func styledMessage(_ e: ReminderEntry) -> AttributedString {
        var s = AttributedString("Patient ")
        var name = AttributedString(e.patientName); name.font = .callout.bold(); s.append(name)
        s.append(AttributedString(" has an appointment on "))
        let (dateStr, timeStr) = pretty(e.apptDate)
        var d = AttributedString(dateStr); d.font = .callout.bold(); s.append(d)
        s.append(AttributedString(" at "))
        var t = AttributedString(timeStr); t.font = .callout.bold(); s.append(t)
        return s
    }

    private func time(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "hh:mm a"
        return f.string(from: date)
    }
    private func pretty(_ date: Date) -> (String, String) {
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        let month = DateFormatter().monthSymbols[(comps.month ?? 1) - 1]
        let day = comps.day ?? 1
        let ordinal: String = {
            let teen = (11...13).contains(day % 100)
            if teen { return "th" }
            switch day % 10 { case 1: return "st"; case 2: return "nd"; case 3: return "rd"; default: return "th" }
        }()
        return ("\(month) \(day)\(ordinal)", time(date))
    }
}
