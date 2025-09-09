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
        case .needToRemind: return Color(red: 0.55, green: 0.09, blue: 0.10)
        case .remindAgain:  return Color(red: 0.08, green: 0.10, blue: 0.24)
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
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarViewModel.self) private var vm

    @Bindable var appt: Appointment   // @Model instance

    // ✨ Derive style from saved data
    private var currentStyle: ReminderStyle {
        appt.isReminded ? .remindAgain : .needToRemind
    }

    let style: ReminderStyle  // you can keep it if you need an initial look, but not required

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
                            .foregroundStyle(.secondary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayPatientName)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.08, green: 0.10, blue: 0.24))

                    Text(kindText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "clock").font(.subheadline.weight(.semibold))
                    Text(timeString(appt.timeSlot.startTime))
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(
                    currentStyle == .needToRemind
                    ? currentStyle.accent
                    : Color(red: 0.08, green: 0.10, blue: 0.24)
                )
            }

            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    // Write to the model, not local state
                    appt.isReminded = true
                    do { try modelContext.save() } catch {
                        assertionFailure("Save failed: \(error)")
                        print("Save failed:", error)
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "bell.fill").font(.caption.bold())
                    Text(currentStyle.pillText).font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(currentStyle.accent.opacity(currentStyle == .needToRemind ? 0.85 : 1.0))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(currentStyle.accent.opacity(currentStyle == .needToRemind ? 0.35 : 0.25), lineWidth: 1)
        )
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
