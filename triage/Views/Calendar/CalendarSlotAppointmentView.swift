//
//  AppointmentRowView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

struct SlotAppointmentCard: View {
    let appt: Appt
    var availableWidth: CGFloat? = nil   // optional hint from the row

    // ---- Style constants tuned to your reference ----
    private let cardCorner: CGFloat = 12
    private let pillCorner: CGFloat = 8
    private let badgeCorner: CGFloat = 8
    private let badgeSize: CGFloat = 22

    private let minCardHeight: CGFloat = 64
    private let compactThreshold: CGFloat = 220

    // Colors
    private let accentNavy = Color(red: 0.08, green: 0.10, blue: 0.24)
    private let cardFill   = Color(.secondarySystemBackground)
    private let pillFill   = Color(.systemGray5)

    var body: some View {
        let isCompact = (availableWidth ?? .infinity) < compactThreshold

        VStack(spacing: 10) {
            // TAG PILL
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: badgeCorner)
                        .fill(accentNavy)
                    Image(systemName: appt.tagIcon)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                .frame(width: badgeSize, height: badgeSize)

                Text(appt.tag)
                    .font(isCompact ? .callout.weight(.ultraLight)
                          : .title3.weight(.light))
                    .foregroundStyle(accentNavy)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
            }
            .padding(.horizontal, 14)
            .frame(height: isCompact ? 34 : 38)
            .background(RoundedRectangle(cornerRadius: pillCorner).fill(pillFill))

            // PATIENT NAME
            Text(appt.patient)
                .font(isCompact ? .headline.weight(.medium)
                      : .title3.weight(.semibold))
                .foregroundStyle(accentNavy)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        // Center the card’s content vertically & horizontally inside its slot
        .frame(minHeight: minCardHeight)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(RoundedRectangle(cornerRadius: cardCorner).fill(cardFill))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(appt.tag), \(appt.patient)")
    }
}
