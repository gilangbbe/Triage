//
//  CalendarReminderCardView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
    let appt: Appointment
    let style: ReminderStyle
    var onReminded: (() -> Void)? = nil

    @State private var showReminder = false
    @State private var displayStyle: ReminderStyle

    @State private var popupEdge: Edge = .leading
    @State private var buttonGlobalFrame: CGRect = .zero

    init(appt: Appointment, style: ReminderStyle, onReminded: (() -> Void)? = nil) {
        self.appt = appt
        self.style = style
        self.onReminded = onReminded
        _displayStyle = State(initialValue: style)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
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
                        .lineLimit(1)

                    Text(kindText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.subheadline.weight(.semibold))
                    Text(timeString(appt.timeSlot.startTime))
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(displayStyle == .needToRemind
                                  ? displayStyle.accent
                                  : Color(red: 0.08, green: 0.10, blue: 0.24))
            }

            Button {
                withAnimation(.easeInOut(duration: 0.18)) { displayStyle = .remindAgain }
                onReminded?()
                withAnimation(.easeInOut(duration: 0.18)) {
                    updateEdgeIfNeeded()
                    showReminder = true
                }
            } label: {
                HStack {
                    Image(systemName: "bell.fill")
                        .font(.caption.bold())
                    Text(displayStyle.pillText)
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(displayStyle.accent.opacity(displayStyle == .needToRemind ? 0.85 : 1.0))
                )
            }
            .buttonStyle(.plain)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { buttonGlobalFrame = proxy.frame(in: .global) }
                        .onChange(of: proxy.frame(in: .global)) { _, new in
                            buttonGlobalFrame = new
                        }
                }
            )
            .popover(isPresented: $showReminder,
                     attachmentAnchor: .rect(.bounds),
                     arrowEdge: popupEdge) {
                ReminderPopup(appt: appt) { showReminder = false }
                    .presentationCompactAdaptation(.popover)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(displayStyle.accent.opacity(displayStyle == .needToRemind ? 0.35 : 0.25), lineWidth: 1)
        )
        .onChange(of: style) { _, new in
            displayStyle = new
        }
        #if canImport(UIKit)
        // Re-evaluate side on size class / rotation changes
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            updateEdgeIfNeeded()
        }
        #endif
    }

    // MARK: - Derived text
    private var displayPatientName: String {
        appt.patient?.fullName ?? appt.name
    }
    private var kindText: String {
        appt.package?.name ?? appt.name   // adjust if you have a dedicated kind/title
    }

    /// Decide which side to show the popover based on available horizontal room.
    private func updateEdgeIfNeeded() {
        #if canImport(UIKit)
        let screen = UIScreen.main.bounds
        let rightSpace = screen.maxX - buttonGlobalFrame.maxX
        let leftSpace  = buttonGlobalFrame.minX - screen.minX
        let desiredWidth: CGFloat = 360

        withAnimation(.easeInOut(duration: 0.15)) {
            if rightSpace >= desiredWidth || rightSpace >= leftSpace {
                popupEdge = .leading
            } else {
                popupEdge = .trailing
            }
        }
        #endif
    }

    // MARK: - Helpers
    private func timeString(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        return f.string(from: d)
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
}
