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
    let appt: Appt
    let style: ReminderStyle
    var onReminded: (() -> Void)? = nil

    @State private var showReminder = false
    @State private var displayStyle: ReminderStyle

    // --- for side popover placement ---
    @State private var popupEdge: Edge = .leading
    @State private var buttonGlobalFrame: CGRect = .zero

    init(appt: Appt, style: ReminderStyle, onReminded: (() -> Void)? = nil) {
        self.appt = appt
        self.style = style
        self.onReminded = onReminded
        _displayStyle = State(initialValue: style)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack(alignment: .center, spacing: 12) {
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

                    Text(appt.tag)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.subheadline.weight(.semibold))
                    Text(timeString(appt.start))
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(displayStyle == .needToRemind
                                  ? displayStyle.accent
                                  : Color(red: 0.08, green: 0.10, blue: 0.24))
            }

            // Action pill
            Button {
                withAnimation(.easeInOut(duration: 0.18)) { displayStyle = .remindAgain }
                onReminded?()
                withAnimation(.easeInOut(duration: 0.18)) {
                    updateEdgeIfNeeded()     // decide side before showing
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
            // Measure the button's global frame so we can decide left/right placement.
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { buttonGlobalFrame = proxy.frame(in: .global) }
                        .onChange(of: proxy.frame(in: .global)) { buttonGlobalFrame = $0 }
                }
            )
            // Popover placed to the SIDE of the button
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
        .onChange(of: style) { new in
            displayStyle = new
        }
        // Re-evaluate side on size class / rotation changes
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            updateEdgeIfNeeded()
        }
    }

    /// Decide which side to show the popover based on available horizontal room.
    private func updateEdgeIfNeeded() {
        let screen = UIScreen.main.bounds
        // space available on each side of the button
        let rightSpace = screen.maxX - buttonGlobalFrame.maxX
        let leftSpace  = buttonGlobalFrame.minX - screen.minX

        // approximate popup width you use; tweak if you change layout
        let desiredWidth: CGFloat = 360

        withAnimation(.easeInOut(duration: 0.15)) {
            // Prefer the right side (.leading). If not enough space, flip to left (.trailing).
            if rightSpace >= desiredWidth || rightSpace >= leftSpace {
                popupEdge = .leading   // popover appears at RIGHT of the button
            } else {
                popupEdge = .trailing  // popover appears at LEFT of the button
            }
        }
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

// MARK: - Popup

private struct ReminderPopup: View {
    let appt: Appt
    var onClose: () -> Void

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button { onClose() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }

            Text(reminderMessage(for: appt))
                .font(.body)
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

            HStack {
                Spacer()
                Button {
                    #if canImport(UIKit)
                    UIPasteboard.general.string = plainReminder(for: appt)
                    #endif
                    withAnimation(.easeInOut(duration: 0.15)) { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.15)) { copied = false }
                    }
                } label: {
                    Label(copied ? "Copied!" : "Copy Reminder", systemImage: "doc.on.doc")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 6, y: 2)
        )
    }

    // Build the styled message by appending runs (no weird debug text)
    private func reminderMessage(for appt: Appt) -> AttributedString {
        var result = AttributedString("Hello ")

        var name = AttributedString(appt.patient)
        name.font = .body.bold()
        result.append(name)

        result.append(AttributedString(",\nThis is a friendly reminder for your "))

        var tag = AttributedString(appt.tag)
        tag.font = .body.bold()
        result.append(tag)

        result.append(AttributedString(" appointment scheduled at "))

        var t = AttributedString(time(appt.start))
        t.font = .body.bold()
        result.append(t)

        result.append(AttributedString(".\nPlease arrive 15 minutes earlier for registration."))

        return result
    }

    private func plainReminder(for appt: Appt) -> String {
        "Hello \(appt.patient),\nThis is a friendly reminder for your \(appt.tag) appointment scheduled at \(time(appt.start)).\nPlease arrive 15 minutes earlier for registration."
    }

    private func time(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "hh:mm a"
        return f.string(from: d)
    }
}
