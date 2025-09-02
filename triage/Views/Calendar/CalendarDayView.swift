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
            OverviewHeader()
            TimelineBoard(selectedDate: selectedDate, appts: appts).padding(.top, 24)
            Spacer()
        }
    }
}

// MARK: - Timeline Board (24h grid; booked hours auto-size)
private struct TimelineBoard: View {
    let selectedDate: Date
    let appts: [Appt]

    // Layout
    private let minEmptyRowHeight: CGFloat = 128
    private let timeTextWidth: CGFloat = 56
    private let timeLeadingPad: CGFloat = 12
    private let rightPad: CGFloat = 8
    private let rowSideInset: CGFloat = 24
    private let rowTopPadding: CGFloat = 16
    private let hours = Array(0..<24)

    private var timeGutterWidth: CGFloat { timeTextWidth + timeLeadingPad }

    var body: some View {
        let dayAppts = appts.filter { Calendar.current.isDate($0.start, inSameDayAs: selectedDate) }
        let grouped = groupByHour(dayAppts)

        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                ForEach(hours, id: \.self) { h in
                    // hour separator at top of the row
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)

                    HStack(alignment: .top, spacing: 0) {
                        // FIXED gutter (no Spacer!)
                        Text(String(format: "%02d.00", h))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(width: timeGutterWidth, alignment: .trailing)

                        // Content column
                        if let slotAppts = grouped[h], !slotAppts.isEmpty {
                            SlotBucketsRow(appts: slotAppts)
                                .frame(maxWidth: .infinity, alignment: .leading)   // <- stick left
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, rowSideInset)
                                .padding(.top, rowTopPadding)
                                .padding(.bottom, rowTopPadding)
                                .padding(.trailing, rightPad)
                        } else {
                            // Empty hour: consistent height, still consume width
                            Color.clear
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, rightPad)
                                .frame(height: minEmptyRowHeight)
                        }
                    }
                }
            }
        }
    }

    // MARK: Helpers
    private func groupByHour(_ appts: [Appt]) -> [Int: [Appt]] {
        var dict: [Int: [Appt]] = [:]
        let cal = Calendar.current
        for a in appts {
            dict[cal.component(.hour, from: a.start), default: []].append(a)
        }
        for k in dict.keys {
            dict[k]?.sort { ($0.start, $0.patient) < ($1.start, $1.patient) }
        }
        return dict
    }
}


// PreferenceKey — keep the LATEST measurement per hour.
private struct HourHeightKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int : CGFloat], nextValue: () -> [Int : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}
