//
//  CalendarDayView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI


struct CalendarDayView: View {
    @Binding var selectedDate: Date
    @Binding var monthAnchor: Date
    @Binding var appts: [Appt]
    
    var body: some View {
        VStack {
            WeekStrip(selectedDate: $selectedDate, monthAnchor: $monthAnchor)
            TimelineBoard(selectedDate: selectedDate, appts: appts)
            Spacer()
        }
    }
}


// MARK: - Timeline Board
private struct TimelineBoard: View {
    let selectedDate: Date
    let appts: [Appt]

    private let hours = Array(0..<24)
    private let rowHeight: CGFloat = 128
    private let timeTextWidth: CGFloat = 56
    private let timeLeadingPad: CGFloat = 12      // <- keep this consistent with gutter
    private let rightPad: CGFloat = 8

    private let rowSideInset: CGFloat = 24
    private let itemGap: CGFloat = 16
    private let minCardWidth: CGFloat = 220
    private let maxCardWidth: CGFloat = 320
    private let rowTopPadding: CGFloat = 16       // <- tiny space below the hour line

    private var timeGutterWidth: CGFloat { timeTextWidth + timeLeadingPad } // 80

    var body: some View {
        let dayAppts = appts.filter { Calendar.current.isDate($0.start, inSameDayAs: selectedDate) }
        let grouped = groupByHour(dayAppts)

        ScrollView(.vertical, showsIndicators: true) {
            ZStack(alignment: .topLeading) {

                // Hour grid (aligned with gutter) – line at TOP of each row
                hourGrid(rowHeight: rowHeight)
                    .padding(.leading, timeLeadingPad)
                    .padding(.trailing, rightPad)

                // Rows
                VStack(spacing: 0) {
                    ForEach(hours, id: \.self) { h in
                        HStack(spacing: 0) {
                            // left gutter = grid gutter
                            Color.clear.frame(width: timeGutterWidth)

                            if let slot = grouped[h], !slot.isEmpty {
                                GeometryReader { rowGeo in
                                    let available = max(0, rowGeo.size.width - rowSideInset * 2)
                                    let count = CGFloat(slot.count)
                                    let totalGaps = max(0, count - 1) * itemGap
                                    let rawWidth = (available - totalGaps) / max(1, count)
                                    let cardW = min(maxCardWidth, max(minCardWidth, rawWidth))

                                    HStack(spacing: itemGap) {
                                        ForEach(slot) { a in
                                            SlotAppointmentCard(appt: a, availableWidth: cardW)
                                                .frame(width: cardW)
                                        }
                                    }
                                    .padding(.horizontal, rowSideInset)
                                    .padding(.top, rowTopPadding)        // <- start cards just below the line
                                    .frame(height: rowHeight, alignment: .top) // <- TOP aligned content
                                }
                                .frame(height: rowHeight)
                            } else {
                                // keep empty hours the same height, aligned to top
                                Spacer(minLength: 0)
                            }
                        }
                        .frame(height: rowHeight, alignment: .top)    // <- TOP aligned row
                    }
                }
                .padding(.trailing, rightPad)
            }
            .frame(height: rowHeight * 24)
        }
    }

    // MARK: Helpers

    private func groupByHour(_ appts: [Appt]) -> [Int: [Appt]] {
        var dict: [Int: [Appt]] = [:]
        let cal = Calendar.current
        for a in appts {
            let hour = cal.component(.hour, from: a.start)
            dict[hour, default: []].append(a)
        }
        for k in dict.keys { dict[k]?.sort { ($0.start, $0.patient) < ($1.start, $1.patient) } }
        return dict
    }

    // Hour grid with the line at the TOP of each row
    private func hourGrid(rowHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { h in
                HStack(spacing: 0) {
                    Text(String(format: "%02d.00", h))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(width: timeTextWidth, alignment: .trailing)

                    // the hour line
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                }
                .frame(height: rowHeight, alignment: .top)  // <- place contents at TOP
            }
        }
    }
}
