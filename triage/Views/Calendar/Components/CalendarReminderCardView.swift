//
//  CalendarReminderCardView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI
import SwiftData

enum ReminderStyle {
    case needToRemind
    case remindAgain

    var accent: Color {
        switch self {
        case .needToRemind: return Color(hex:"#630B0C")
        case .remindAgain:  return Color(hex:"#0F0E46")
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
    @Bindable var appt: Appointment

    @State private var showReminder = false

    private var currentStyle: ReminderStyle { appt.isReminded ? .remindAgain : .needToRemind }

    let style: ReminderStyle
    init(appt: Appointment, style: ReminderStyle = .needToRemind) {
        self.appt = appt
        self.style = style
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(initials(displayPatientName))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(.secondaryLabel))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayPatientName)
                        .font(.headline)
                        .foregroundStyle(Color(.label))

                    Text(kindText)
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "clock").font(.subheadline.weight(.semibold))
                    Text(timeString(appt.timeSlot.startTime))
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(
                    currentStyle == .needToRemind ? currentStyle.accent : Color(.label)
                )
            }

            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    showReminder = true
                }
            } label: {
                HStack {
                    Image(systemName: "bell.fill").font(.caption.bold())
                    Text(currentStyle.pillText).font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.white)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(currentStyle.accent.opacity(currentStyle == .needToRemind ? 1 : 1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(currentStyle.accent.opacity(currentStyle == .needToRemind ? 0.5 : 0.5), lineWidth: 1)
        )
        .popover(isPresented: $showReminder) {
            ReminderPopup(appt: appt, isPresented: $showReminder) {
                showReminder = false
            }
            .presentationCompactAdaptation(.popover)
        }
    }

    // MARK: - Derived text
    private var displayPatientName: String {
        appt.patient?.fullName ?? appt.name
    }
    private var kindText: String {
        appt.package?.name ?? appt.name
    }

    private func timeString(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "hh:mm a"; return f.string(from: d)
    }
    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
}
