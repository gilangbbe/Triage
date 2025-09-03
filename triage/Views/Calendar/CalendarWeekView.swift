//
//  CalendarWeekView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    @Binding var monthAnchor: Date
    @Binding var appts: [Appt]
    
    var body: some View {
        VStack {
            WeekStrip(selectedDate: $selectedDate, monthAnchor: $monthAnchor)
            WeekTimelineBoard(
                weekAnchor: monthAnchor,
                selectedDate: $selectedDate,
                appts: appts
            )
        }
    }
}

// MARK: - PreferenceKey to bubble up measured heights per HOUR (take max across days)
private struct HourHeightKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int : CGFloat], nextValue: () -> [Int : CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { max($0, $1) })
    }
}

// MARK: - Week Timeline Board
private struct WeekTimelineBoard: View {
    let weekAnchor: Date
    @Binding var selectedDate: Date
    let appts: [Appt]

    // Layout
    private let hours = Array(0..<24)
    private let labelWidth: CGFloat = 72
    private let rightPad: CGFloat = 8
    private let dayGap: CGFloat = 8
    private let singleInset: CGFloat = 4.0
    private let topInsetInHour: CGFloat = 6.0

    // Baselines for hours with/without cards
    private let emptyHourBaseline: CGFloat = 72          // no events that hour
    private let minHourWithCards: CGFloat = 64           // collapsed content floor

    // live measurements (max across all days for each hour)
    @State private var measuredMaxHeights: [Int: CGFloat] = [:]

    var body: some View {
        GeometryReader { geo in
            // simple, typed locals
            let totalWidth: CGFloat   = geo.size.width
            let contentWidth: CGFloat = max(0, totalWidth - labelWidth - rightPad)
            let days: [Date]          = week(for: weekAnchor)
            let gaps: CGFloat         = CGFloat(days.count - 1) * dayGap
            let dayColWidth: CGFloat  = (contentWidth - gaps) / CGFloat(days.count)

            // group incoming appts by day
            let byDay: [Date: [Appt]] = groupByDay(appts)

            // which hours actually have any appt (over the week)
            let hourHasAny: [Bool] = hours.map { h in
                days.contains { day in
                    let key = Calendar.current.startOfDay(for: day)
                    let dayAppts = byDay[key] ?? []
                    return dayAppts.contains { Calendar.current.component(.hour, from: $0.start) == h }
                }
            }

            // final hour heights: baseline vs. measured max across days for that hour
            let hourHeights: [CGFloat] = hours.enumerated().map { idx, _ in
                if hourHasAny[idx] {
                    // take measured (plus some breathing room), clamped to a minimum
                    let measured = (measuredMaxHeights[idx] ?? 0) + 10
                    return max(measured, minHourWithCards)
                } else {
                    return emptyHourBaseline
                }
            }

            // cumulative Y offsets for positioning cards
            var run: CGFloat = 0
            let yOffsets: [CGFloat] = hourHeights.map { h in defer { run += h }; return run }
            let totalHeight = hourHeights.reduce(0, +)

            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    // hour grid matching variable row heights
                    hourGrid(with: hourHeights)
                        .padding(.leading, labelWidth)

                    // columns for 7 days
                    HStack(alignment: .top, spacing: dayGap) {
                        ForEach(days, id: \.self) { day in
                            let key = Calendar.current.startOfDay(for: day)
                            let dayAppts = byDay[key] ?? []

                            ZStack(alignment: .topLeading) {
                                // left hairline
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.14))
                                    .frame(width: 1)

                                // one summary card per HOUR if that day has appts in that hour
                                ForEach(hours, id: \.self) { h in
                                    let inHour = appts(inHour: h, from: dayAppts)
                                    if !inHour.isEmpty {
                                        let grouped = groupByKind(inHour)

                                        WeekSlotSummaryCard(kindGroups: grouped)
                                            .offset(x: singleInset,
                                                    y: (yOffsets[safe: h] ?? 0) + topInsetInHour)
                                            .background(
                                                GeometryReader { cardGeo in
                                                    Color.clear.preference(
                                                        key: HourHeightKey.self,
                                                        value: [h: cardGeo.size.height]
                                                    )
                                                }
                                            )
                                    }
                                }
                            }
                            .frame(width: dayColWidth, height: totalHeight, alignment: .topLeading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut) { selectedDate = day }
                            }
                        }
                    }
                    .padding(.leading, labelWidth)
                    .padding(.trailing, rightPad)

                    // time gutter using the same variable heights
                    timeGutter(with: hourHeights)
                }
                .animation(.easeInOut(duration: 0.22), value: measuredMaxHeights)
                .frame(height: totalHeight)
                .onPreferenceChange(HourHeightKey.self) { incoming in
                    withAnimation(.easeInOut(duration: 0.22)) {
                        measuredMaxHeights = incoming
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func groupByDay(_ appts: [Appt]) -> [Date: [Appt]] {
        let cal = Calendar.current
        return appts.reduce(into: [Date: [Appt]]()) { dict, a in
            let key = cal.startOfDay(for: a.start)
            dict[key, default: []].append(a)
        }
    }

    private func appts(inHour hour: Int, from dayAppts: [Appt]) -> [Appt] {
        let cal = Calendar.current
        return dayAppts.filter { cal.component(.hour, from: $0.start) == hour }
    }

    private func groupByKind(_ appts: [Appt]) -> [SlotKind: [Appt]] {
        var d: [SlotKind: [Appt]] = [:]
        for a in appts { d[a.slotKind, default: []].append(a) }
        return d
    }

    private func timeGutter(with heights: [CGFloat]) -> some View {
        VStack(spacing: 0) {
            ForEach(hours.indices, id: \.self) { i in
                HStack(spacing: 16) {
                    Text(String(format: "%02d:00", hours[i]))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(width: labelWidth - 16, alignment: .trailing)
                    Rectangle().fill(.clear).frame(height: 1)
                }
                .frame(height: heights[i], alignment: .top)
                .transition(.move(edge: .top))
            }
        }
    }

    private func hourGrid(with heights: [CGFloat]) -> some View {
        VStack(spacing: 0) {
            ForEach(heights.indices, id: \.self) { i in
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)                                  // the line
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: heights[i], alignment: .top)        // row height
            }
        }
    }

    private func week(for anchor: Date) -> [Date] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: anchor)
        let mondayStart = cal.date(
            byAdding: .day,
            value: -(weekday == 1 ? 6 : weekday - 2),
            to: cal.startOfDay(for: anchor)
        ) ?? anchor
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: mondayStart) }
    }
}

// tiny safe-subscript helper
private extension Array {
    subscript(safe i: Index) -> Element? { indices.contains(i) ? self[i] : nil }
}
