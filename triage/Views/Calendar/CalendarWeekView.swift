//
//  CalendarWeekView.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//

import SwiftUI

struct CalendarWeekView: View {
    @Environment(CalendarViewModel.self) private var vm

    var body: some View {
        VStack {
            WeekStrip(
                selectedDate: Binding(
                    get: { vm.selectedDate },
                    set: { vm.selectedDate = $0 }
                ),
                monthAnchor: Binding(
                    get: { vm.monthAnchor },
                    set: { vm.monthAnchor = $0 }
                )
            )

            WeekTimelineBoard(
                weekAnchor: vm.monthAnchor,
                selectedDate: Binding(
                    get: { vm.selectedDate },
                    set: { vm.selectedDate = $0 }
                ),
                appts: vm.visibleAppointments
            )
        }
    }
}


// MARK: - PreferenceKey
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
    let appts: [Appointment]

    private let hours = Array(0..<24)
    private let labelWidth: CGFloat = 72
    private let rightPad: CGFloat = 8
    private let dayGap: CGFloat = 8
    private let singleInset: CGFloat = 4.0
    private let topInsetInHour: CGFloat = 6.0

    private let emptyHourBaseline: CGFloat = 72
    private let minHourWithCards: CGFloat = 64

    @State private var measuredMaxHeights: [Int: CGFloat] = [:]

    var body: some View {
        GeometryReader { geo in
            let totalWidth: CGFloat   = geo.size.width
            let contentWidth: CGFloat = max(0, totalWidth - labelWidth - rightPad)
            let days: [Date]          = week(for: weekAnchor)
            let gaps: CGFloat         = CGFloat(days.count - 1) * dayGap
            let dayColWidth: CGFloat  = (contentWidth - gaps) / CGFloat(days.count)

            let byDay: [Date: [Appointment]] = groupByDay(appts)

            let hourHasAny: [Bool] = hours.map { h in
                days.contains { day in
                    let key = Calendar.current.startOfDay(for: day)
                    let dayAppts = byDay[key] ?? []
                    return dayAppts.contains { Calendar.current.component(.hour, from: $0.timeSlot.startTime) == h }
                }
            }

            let hourHeights: [CGFloat] = hours.enumerated().map { idx, _ in
                if hourHasAny[idx] {
                    let measured = (measuredMaxHeights[idx] ?? 0) + 10
                    return max(measured, minHourWithCards)
                } else {
                    return emptyHourBaseline
                }
            }

            var run: CGFloat = 0
            let yOffsets: [CGFloat] = hourHeights.map { h in defer { run += h }; return run }
            let totalHeight = hourHeights.reduce(0, +)

            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    hourGrid(with: hourHeights)
                        .padding(.leading, labelWidth)

                    HStack(alignment: .top, spacing: dayGap) {
                        ForEach(days, id: \.self) { day in
                            let key = Calendar.current.startOfDay(for: day)
                            let dayAppts = byDay[key] ?? []

                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.14))
                                    .frame(width: 1)

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

    // MARK: - Helpers ()
    private func groupByDay(_ appts: [Appointment]) -> [Date: [Appointment]] {
        let cal = Calendar.current
        return appts.reduce(into: [Date: [Appointment]]()) { dict, a in
            let key = cal.startOfDay(for: a.timeSlot.startTime)
            dict[key, default: []].append(a)
        }
    }

    private func appts(inHour hour: Int, from dayAppts: [Appointment]) -> [Appointment] {
        let cal = Calendar.current
        return dayAppts.filter { cal.component(.hour, from: $0.timeSlot.startTime) == hour }
    }

    private func groupByKind(_ appts: [Appointment]) -> [SlotKind: [Appointment]] {
        var d: [SlotKind: [Appointment]] = [:]
        for a in appts {
            d[a.inferredSlotKind, default: []].append(a)
        }
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
                    .frame(height: 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: heights[i], alignment: .top)
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

private extension Array {
    subscript(safe i: Index) -> Element? { indices.contains(i) ? self[i] : nil }
}
