//
//  CalendarWeekView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    @Binding var monthAnchor: Date
    @Binding var appts: [Appt]
    
    var body: some View {
        VStack {
            WeekStrip(selectedDate: $selectedDate, monthAnchor: $monthAnchor)
            WeekTimelineBoard(weekAnchor: monthAnchor,
                              selectedDate: $selectedDate,
                              appts: appts)
        }
    }
}


// MARK: - Week Timeline Board
private struct WeekTimelineBoard: View {
    let weekAnchor: Date
    @Binding var selectedDate: Date
    let appts: [Appt]

    private let hours = Array(0..<24)
    private let minuteHeight: CGFloat = 2.0
    private let cardTopInset: CGFloat = 6.0
    private let labelWidth: CGFloat = 72
    private let rightPad: CGFloat = 8
    private let dayGap: CGFloat = 8
    private let columnGap: CGFloat = 6.0
    private let overlapTolerance: TimeInterval = 5 * 60
    private let singleInset: CGFloat = 4.0       // side padding when there's only one appt in the row
    private let clusterOuterInset: CGFloat = 8.0 // side padding for multi-appointment clusters
    private let innerInset: CGFloat = 3.0

    private struct PlacedAppt: Identifiable {
        let id: UUID
        let appt: Appt
        let columnIndex: Int
        let columnCount: Int
    }

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let contentWidth = max(0, totalWidth - labelWidth - rightPad)
            let days = week(for: weekAnchor)
            let gaps = CGFloat(days.count - 1) * dayGap
            let dayColWidth = (contentWidth - gaps) / CGFloat(days.count)


            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {

                    // Hour grid (horizontal lines across all day columns)
                    hourGrid()
                        .padding(.leading, labelWidth)

                    // Vertical day separators + tap targets + day columns
                    HStack(alignment: .top, spacing: dayGap) {
                        ForEach(days, id: \.self) { day in
                            let dayAppts = appts.filter { Calendar.current.isDate($0.start, inSameDayAs: day) }

                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.12))
                                    .frame(width: 1)
                                    .alignmentGuide(.top) { d in d[.top] }
                                    .offset(x: 0, y: 0) // left edge
                                    .opacity(0.6)

                                ForEach(layoutColumns(for: dayAppts)) { placed in
                                    let clusterCount = max(1, placed.columnCount)
                                    let (outerInset, totalGaps): (CGFloat, CGFloat) = {
                                        if clusterCount == 1 {
                                            return (singleInset, 0)
                                        } else {
                                            return (clusterOuterInset, CGFloat(clusterCount - 1) * columnGap)
                                        }
                                    }()
                                    let clusterWidth = max(0, dayColWidth - (2 * outerInset))
                                    let colW = max(0, (clusterWidth - totalGaps) / CGFloat(clusterCount))
                                    let xOffset = outerInset + CGFloat(placed.columnIndex) * (colW + columnGap)
                                    let usableW = max(0, colW - 2 * innerInset)

                                    ZStack(alignment: .topLeading) {
//                                        AppointmentRow(
//                                            appt: placed.appt,
//                                            day: day,
//                                            minuteHeight: minuteHeight,
//                                            cardTopInset: cardTopInset,
//                                            availableWidth: usableW
//                                        )
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        .padding(.horizontal, innerInset)   // keep card off the column edge
                                    }
                                    .frame(width: colW, height: minuteHeight * 24 * 60, alignment: .topLeading)
                                    .clipped(antialiased: true)             // prevent shadows/borders from bleeding across columns
                                    .offset(x: xOffset)
                                    .zIndex(Double(placed.columnIndex))     // stable stacking
                                }

                                // Red "now" line only for today's column
                                NowLine(day: day, minuteHeight: minuteHeight)
                            }
                            .frame(width: dayColWidth, height: minuteHeight * 24 * 60, alignment: .topLeading)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut) { selectedDate = day }
                            }
                        }
                    }
                    .padding(.leading, labelWidth)
                    .padding(.trailing, rightPad)

                    // Time labels gutter on the left
                    timeGutter()
                }
                .frame(height: minuteHeight * 24 * 60)
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Gutter with hour labels
    private func timeGutter() -> some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { h in
                HStack(spacing: 16) {
                    Text(String(format: "%02d:00", h))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(width: labelWidth - 16, alignment: .trailing)
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 1)
                }
                .frame(height: minuteHeight * 60, alignment: .top)
            }
        }
    }

    // MARK: - Hour grid (horizontal lines)
    private func hourGrid() -> some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { _ in
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 1)
                    .padding(.top, 0)
                    .frame(height: minuteHeight * 60, alignment: .top)
            }
        }
    }

    // MARK: - Helpers
    private func week(for anchor: Date) -> [Date] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: anchor)
        let mondayStart = cal.date(byAdding: .day, value: -(weekday == 1 ? 6 : weekday - 2), to: anchor.startOfDay) ?? anchor
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: mondayStart) }
    }

    private func layoutColumns(for appts: [Appt]) -> [PlacedAppt] {
        let events = appts.sorted { ($0.start, $0.end) < ($1.start, $1.end) }

        struct TempInfo { var col: Int; var cluster: Int }
        var active: [(appt: Appt, col: Int, cluster: Int)] = []
        var info: [UUID: TempInfo] = [:]
        var clusterMaxCols: [Int: Int] = [:]
        var currentCluster = 0

        for e in events {
            active.removeAll { $0.appt.end <= e.start.addingTimeInterval(-overlapTolerance) }
            if active.isEmpty { currentCluster += 1 }

            let used = Set(active.map { $0.col })
            var col = 0
            while used.contains(col) { col += 1 }

            info[e.id] = TempInfo(col: col, cluster: currentCluster)
            active.append((appt: e, col: col, cluster: currentCluster))
            clusterMaxCols[currentCluster] = max(clusterMaxCols[currentCluster] ?? 0, col + 1)
        }

        return events.map { e in
            let t = info[e.id]!
            let count = clusterMaxCols[t.cluster] ?? 1
            return PlacedAppt(id: e.id, appt: e, columnIndex: t.col, columnCount: max(1, count))
        }
    }
}
