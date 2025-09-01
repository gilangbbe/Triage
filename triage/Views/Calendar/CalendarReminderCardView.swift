//
//  CalendarReminderCardView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

enum ReminderStyle {
    case needToRemind
    case remindAgain

    var accent: Color {
        switch self {
        case .needToRemind: return Color(red: 0.55, green: 0.09, blue: 0.10) // deep red
        case .remindAgain:  return Color(red: 0.08, green: 0.10, blue: 0.24) // navy
        }
    }
    var pillText: String {
        switch self {
        case .needToRemind: return "Need to Remind"
        case .remindAgain:  return "Remind Again"
        }
    }
}

struct ReminderCard: View {
    let appt: Appt
    let style: ReminderStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                // Avatar w/ initials
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(initials(appt.patient))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(appt.patient)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.08, green: 0.10, blue: 0.24))
                        .lineLimit(1)

                    Text(appt.tag) // e.g., Medical Check Up
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // time on the right
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.subheadline.weight(.semibold))
                    Text(timeString(appt.start))
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(style == .needToRemind ? style.accent : Color(red: 0.08, green: 0.10, blue: 0.24))
            }

            // Bottom action pill
            HStack {
                Image(systemName: "bell.fill")
                    .font(.caption.bold())
                Text(style.pillText)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(style.accent.opacity(style == .needToRemind ? 0.85 : 1.0))
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style.accent.opacity(style == .needToRemind ? 0.35 : 0.25), lineWidth: 1)
        )
    }

    private func timeString(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: d)
    }
    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
}

