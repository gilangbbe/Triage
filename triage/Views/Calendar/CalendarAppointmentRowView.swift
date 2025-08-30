//
//  AppointmentRowView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

struct AppointmentRow: View {
    let appt: Appt
    let day: Date
    let minuteHeight: CGFloat
    let cardTopInset: CGFloat
    let availableWidth: CGFloat

    private let compactThreshold: CGFloat = 150
    private let minCardHeight: CGFloat = 60

    var body: some View {
        let y = yOffsetForStart(appt.start) + cardTopInset
        let h = max(minCardHeight, durationHeight(start: appt.start, end: appt.end))
        let isCompact = availableWidth < compactThreshold

        Group {
            if isCompact {
                // COMPACT LAYOUT for narrow columns
                HStack(spacing: 8) {
                    // slim accent/track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.green.opacity(0.25))
                        .frame(width: 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(appt.patient)
                            .font(.caption.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        // tag: icon-only when extremely tight, else small pill
                        if availableWidth < 110 {
                            Image(systemName: appt.tagIcon)
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)
                        } else {
                            Label(appt.tag, systemImage: appt.tagIcon)
                                .font(.caption2.bold())
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.06))
                )

            } else {
                // REGULAR LAYOUT
                HStack(spacing: 12) {
                    Text(appt.patient)
                        .font(.title3.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()
                    Label(appt.tag, systemImage: appt.tagIcon)
                        .font(.caption2.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.06))
                )
            }
        }
        .frame(height: h, alignment: .top)
        .offset(y: y + 8)
    }

    // MARK: - Position & sizing helpers
    private func yOffsetForStart(_ date: Date) -> CGFloat {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let total = CGFloat((comps.hour ?? 0) * 60 + (comps.minute ?? 0))
        return total * minuteHeight
    }

    private func durationHeight(start: Date, end: Date) -> CGFloat {
        let mins = max(0, Calendar.current.dateComponents([.minute], from: start, to: end).minute ?? 0)
        return CGFloat(mins) * minuteHeight - 8
    }

    private func timeString(_ d: Date) -> String { DateFormatter.with("HH:mm").string(from: d) }
}
