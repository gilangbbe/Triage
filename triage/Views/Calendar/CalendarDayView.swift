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
    private let minuteHeight: CGFloat = 2.0
    private let cardTopInset: CGFloat = 6.0
    private let innerInset: CGFloat = 3.0


    // NEW: gap between columns of concurrently overlapping appts
    private let columnGap: CGFloat = 6.0
    // OPTIONAL: treat “similar time” as overlap within N minutes
    private let overlapTolerance: TimeInterval = 5 * 60

    private struct PlacedAppt: Identifiable {
        let id: UUID
        let appt: Appt
        let columnIndex: Int
        let columnCount: Int
    }

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let labelWidth: CGFloat = 72
            let rightPad: CGFloat = 8
            let contentWidth = max(0, totalWidth - labelWidth - rightPad)

            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    hourGrid(minuteHeight: minuteHeight)

                    ForEach(layoutColumns(for: appts)) { placed in
                        let gaps = max(0, placed.columnCount - 1)
                        let totalGap = CGFloat(gaps) * columnGap
                        let colW = max(0, (contentWidth - totalGap) / CGFloat(max(1, placed.columnCount)))
                        let xOffset = labelWidth + CGFloat(placed.columnIndex) * (colW + columnGap)
                        let usableW = max(0, colW - 2 * innerInset)
                        
                        AppointmentRow(
                            appt: placed.appt,
                            day: selectedDate,
                            minuteHeight: minuteHeight,
                            cardTopInset: cardTopInset,
                            availableWidth: usableW
                        )
                        .frame(width: colW, alignment: .leading)
                        .offset(x: xOffset)
                        .padding(.trailing, rightPad)
                    }

                    NowLine(day: selectedDate, minuteHeight: minuteHeight)
                        .padding(.leading, labelWidth)
                }
                .frame(height: minuteHeight * 24 * 60)
                .padding(.top, 12)
            }
        }
    }

    private func hourGrid(minuteHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(hours, id: \.self) { h in
                HStack(spacing: 16) {
                    Text(String(format: "%02d:00", h))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(width: 56, alignment: .trailing)
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)
                }
                .frame(height: minuteHeight * 60, alignment: .top)
            }
        }
        .padding(.leading, 16)
    }

    private func layoutColumns(for appts: [Appt]) -> [PlacedAppt] {
        let events = appts.sorted {
            if $0.start == $1.start { return $0.end < $1.end }
            return $0.start < $1.start
        }

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
            let temp = info[e.id]!
            let count = clusterMaxCols[temp.cluster] ?? 1
            return PlacedAppt(id: e.id, appt: e, columnIndex: temp.col, columnCount: max(1, count))
        }
    }
}


