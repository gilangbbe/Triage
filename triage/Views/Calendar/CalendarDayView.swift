//
//  CalendarDayView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

// MARK: - Theme
struct CalTheme {
    static let navy = Color(red: 16/255, green: 27/255, blue: 79/255)
    static let grid = Color.secondary.opacity(0.25)
    static let chipBG = Color.green.opacity(0.22)
    static let chipStroke = Color.green.opacity(0.55)
    static let cardBG = Color(uiColor: .secondarySystemBackground)
}

// MARK: - Models
struct Appt: Identifiable, Hashable {
    let id = UUID()
    var patient: String
    var tag: String
    var tagIcon: String
    var start: Date
    var end: Date
    var avatarInitial: String
}

extension Appt {
    static func mock(on day: Date) -> [Appt] {
        let cal = Calendar.current
        let targetDate = cal.date(from: DateComponents(year: 2025, month: 8, day: 28))!
        
        guard cal.isDate(day, inSameDayAs: targetDate) else {
            return []
        }
        
        let s1 = cal.date(bySettingHour: 7, minute: 00, second: 0, of: day)!
        let s3 = cal.date(bySettingHour: 8, minute: 35, second: 0, of: day)!
        let e1 = cal.date(byAdding: .minute, value: 90, to: s1)!
        let e2 = cal.date(byAdding: .minute, value: 30, to: s1)!
        let e3 = cal.date(byAdding: .minute, value: 90, to: s3)!
        return [
            .init(patient: "Mr Longest Name Possible",
                  tag: "Medical Check Up",
                  tagIcon: "staroflife.fill",
                  start: s1, end: e1, avatarInitial: "K"),
            
            .init(patient: "Mr PPPPPP",
                  tag: "Medical Check Up",
                  tagIcon: "staroflife.fill",
                  start: s1, end: e1, avatarInitial: "K"),
            
                .init(patient: "Mr PPPPPP",
                      tag: "Medical Check Up",
                      tagIcon: "staroflife.fill",
                      start: s1, end: e1, avatarInitial: "K"),
            
            .init(patient: "Ms Short Name",
                  tag: "Consultation",
                  tagIcon: "startoflife.fill",
                  start: s1, end: e2, avatarInitial: "S"),
            
            .init(patient: "Ms Test",
                  tag: "Consultation",
                  tagIcon: "startoflife.fill",
                  start: s3, end: e3, avatarInitial: "S")
        ]
    }
}

// MARK: - Root iPad Screen
struct CalendarView: View {
    enum Scope: String, CaseIterable { case day = "Day", week = "Week", month = "Month", year = "Year" }
    @Environment(\.horizontalSizeClass) private var hClass
    @State private var scope: Scope = .day
    @State private var selectedDate = Date()
    @State private var monthAnchor = Date()
    
    private var appts: [Appt] { Appt.mock(on: selectedDate) }
    
    var body: some View {
        VStack(spacing: 0) {
            Header(monthAnchor: $monthAnchor, scope: $scope)
            WeekStrip(selectedDate: $selectedDate, monthAnchor: $monthAnchor)
            TimelineBoard(selectedDate: selectedDate, appts: appts)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarHidden(true)
        .padding(.top, 8)
        .padding(.horizontal, 24)
    }
}

// MARK: - Header (Month + Segmented)
private struct Header: View {
    @Binding var monthAnchor: Date
    @Binding var scope: CalendarView.Scope
    
    var body: some View {
        HStack(alignment: .center) {
            Text(monthYear(monthAnchor))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(CalTheme.navy)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Picker("", selection: $scope) {
                ForEach(CalendarView.Scope.allCases, id: \.self) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 380)
        }
        .padding(.bottom, 12)
        .padding(.horizontal, 8)
    }
    
    private func monthYear(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: d)
    }
}

// MARK: - Week Strip
private struct WeekStrip: View {
    @Binding var selectedDate: Date
    @Binding var monthAnchor: Date
    
    var body: some View {
        let days = week(for: monthAnchor)
        
        VStack(spacing: 0) {
            // Week navigation and days
            HStack(spacing: 0) {
                Button {
                    monthAnchor = Calendar.current.date(byAdding: .day, value: -7, to: monthAnchor) ?? monthAnchor
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 44)
                
                ForEach(days, id: \.self) { d in
                    DayCell(date: d, isSelected: Calendar.current.isDate(d, inSameDayAs: selectedDate))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedDate = d
                            }
                        }
                }

                Button {
                    monthAnchor = Calendar.current.date(byAdding: .day, value: 7, to: monthAnchor) ?? monthAnchor
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 44)
            }
            .padding(.vertical, 8)
        }
        .id(days.first ?? Date())
    }
    
    private func week(for anchor: Date) -> [Date] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: anchor) // 1 = Sun
        let mondayStart = cal.date(byAdding: .day, value: -(weekday == 1 ? 6 : weekday - 2), to: anchor.startOfDay) ?? anchor
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: mondayStart) }
    }
}

// MARK: - Day Cell
private struct DayCell: View {
    let date: Date
    let isSelected: Bool

    var body: some View {
        let isToday = Calendar.current.isDateInToday(date)
        VStack(spacing: 8) {
            Text(shortWeekday(date))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(dayString(date))
                .font(.body.weight(.semibold))
                .foregroundStyle(isSelected ? .white : CalTheme.navy)
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(isSelected ? CalTheme.navy
                                             : (isToday ? CalTheme.navy.opacity(0.12) : .clear))
                )
                .overlay(
                    Circle()
                        .stroke(isToday && !isSelected ? CalTheme.navy.opacity(0.35) : .clear, lineWidth: 1)
                )
        }
    }

    private func shortWeekday(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "E"
        return f.string(from: d).prefix(1).uppercased()
    }
    
    private func dayString(_ d: Date) -> String {
        DateFormatter.with("d").string(from: d)
    }
}

// MARK: - Timeline Board
private struct TimelineBoard: View {
    let selectedDate: Date
    let appts: [Appt]
    private let hours = Array(0..<24)
    private let minuteHeight: CGFloat = 2.0
    private let cardTopInset: CGFloat = 6.0

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
                        // total gap between columns in this cluster
                        let gaps = max(0, placed.columnCount - 1)
                        let totalGap = CGFloat(gaps) * columnGap
                        let colW = max(0, (contentWidth - totalGap) / CGFloat(max(1, placed.columnCount)))
                        let xOffset = labelWidth + CGFloat(placed.columnIndex) * (colW + columnGap)

                        AppointmentRow(
                            appt: placed.appt,
                            day: selectedDate,
                            minuteHeight: minuteHeight,
                            cardTopInset: cardTopInset
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

    // MARK: - Overlap layout with tolerance
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


// MARK: - Appointment Row
private struct AppointmentRow: View {
    let appt: Appt
    let day: Date
    let minuteHeight: CGFloat
    let cardTopInset: CGFloat

    var body: some View {
        let y = yOffsetForStart(appt.start) + cardTopInset
        let h = max(60, durationHeight(start: appt.start, end: appt.end))

        HStack(spacing: 14) {
            Text(appt.patient)
                .font(.title3.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Label(appt.tag, systemImage: appt.tagIcon)
                .font(.caption2.bold())
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.green.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(height: h, alignment: .top)   // card height derived from duration
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.06)))
        .offset(y: y+8)
    }

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

// MARK: - Now Line
private struct NowLine: View {
    let day: Date
    let minuteHeight: CGFloat

    var body: some View {
        if Calendar.current.isDateInToday(day) {
            let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
            let mins = CGFloat((comps.hour ?? 0) * 60 + (comps.minute ?? 0))
            Rectangle()
                .fill(Color.red.opacity(0.7))
                .frame(height: 1)
                .offset(y: mins * minuteHeight)
        } else {
            EmptyView()
        }
    }
}


// MARK: - Helpers
extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}

extension DateFormatter {
    static func with(_ fmt: String) -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = fmt
        return f
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
        CalendarView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

