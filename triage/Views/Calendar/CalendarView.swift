//
//  CalendarView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

//
//  CalendarView.swift
//  triage
//

import SwiftUI

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

        func at(_ hour: Int, _ minute: Int = 0, on base: Date = day) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: base)!
        }
        func plus(_ minutes: Int, to d: Date) -> Date {
            cal.date(byAdding: .minute, value: minutes, to: d)!
        }

        let sept1 = cal.date(from: DateComponents(year: 2025, month: 9, day: 1))!
        let sept5 = cal.date(from: DateComponents(year: 2025, month: 9, day: 5))!

        if cal.isDate(day, inSameDayAs: sept1) {
            let s7 = at(7)
            let s13 = at(13)

            return [
                .init(patient: "Mr Longest Name Possible",
                      tag: "Medical",
                      tagIcon: "staroflife.fill",
                      start: s7, end: plus(60, to: s7), avatarInitial: "K"),

                .init(patient: "Mr Longest Name Possible",
                      tag: "Laboratory",
                      tagIcon: "staroflife.fill",
                      start: s7, end: plus(60, to: s7), avatarInitial: "K"),

                .init(patient: "Ms Short Name",
                      tag: "Radiology",
                      tagIcon: "staroflife.fill",
                      start: s7, end: plus(60, to: s7), avatarInitial: "S"),

                .init(patient: "Ms Test",
                      tag: "Radiology",
                      tagIcon: "staroflife.fill",
                      start: s13, end: plus(60, to: s13), avatarInitial: "S"),

                .init(patient: "Ms Short Name",
                      tag: "Radiology",
                      tagIcon: "staroflife.fill",
                      start: s7, end: plus(60, to: s7), avatarInitial: "S"),

                .init(patient: "Ms Test",
                      tag: "Radiology",
                      tagIcon: "staroflife.fill",
                      start: s13, end: plus(60, to: s13), avatarInitial: "S")
            ]
        } else if cal.isDate(day, inSameDayAs: sept5) {
            let s10 = at(10)
            let s11 = at(11)

            return [
                .init(patient: "John Doe",
                      tag: "Medical",
                      tagIcon: "staroflife.fill",
                      start: s10, end: plus(60, to: s10), avatarInitial: "JD"),
                .init(patient: "Jane Roe",
                      tag: "Laboratory",
                      tagIcon: "staroflife.fill",
                      start: s11, end: plus(60, to: s11), avatarInitial: "JR")
            ]
        } else {
            return []
        }
    }
}


// MARK: - Theme
struct CalTheme {
    static let navy = Color(red: 16/255, green: 27/255, blue: 79/255)
    static let grid = Color.secondary.opacity(0.25)
    static let chipBG = Color.green.opacity(0.22)
    static let chipStroke = Color.green.opacity(0.55)
    static let cardBG = Color(uiColor: .secondarySystemBackground)
}

// MARK: - View
struct CalendarView: View {
    enum Scope: String, CaseIterable { case day = "Day", week = "Week" }

    @Environment(\.horizontalSizeClass) private var hClass
    @State private var scope: Scope = .day
    @State private var selectedDate = Date()
    @State private var monthAnchor = Date()
    @State private var appts: [Appt] = []
    @State private var showLog = false
    @State private var logEntries: [ReminderEntry] = []
    

    var body: some View {
        ZStack {
            HStack(spacing: 0) {

                if scope == .day {
                    SidebarPanel(selectedDate: $selectedDate, showLog: $showLog, logEntries: $logEntries, appts: appts)
                        .frame(width: 360)
                        .background(Color(.systemBackground))
                        .overlay(Divider(), alignment: .trailing)
                }

                VStack(spacing: 0) {
                    HStack {
                        
                        if scope.rawValue == "Week" {
                            MonthYearSelector(monthAnchor: $monthAnchor)
                        }
                        
                        Spacer()
                        EnumPillSegmentedControl(
                            selection: $scope,
                            titles: Scope.allCases.map(\.rawValue),
                            width: 300, height: 32,
                            font: .callout.weight(.semibold),
                            trackColor: Color(.systemGray6),
                            trackStroke: Color(.systemGray4),
                            textColor: CalTheme.navy
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)

                    Divider().overlay(Color(.systemGray4))

                    Group {
                        switch scope {
                        case .day:
                            CalendarDayView(
                                selectedDate: $selectedDate,
                                monthAnchor: $monthAnchor,
                                appts: $appts,
                            )
                        case .week:
                            CalendarWeekView(
                                selectedDate: $selectedDate,
                                monthAnchor: $monthAnchor,
                                appts: $appts
                            )
                        }
                    }
                }
                .background(Color(uiColor: .systemBackground))
                .padding(.top, 8)
                .padding(.horizontal, 24)
            }
            .task { loadAppts() }
            .onChange(of: selectedDate) { _ in loadAppts() }
            .onChange(of: monthAnchor)  { _ in loadAppts() }
            .onChange(of: scope)        { _ in loadAppts() }
            .navigationBarHidden(true)
            
            if showLog {
                ReminderLogView(entries: logEntries) {
                    withAnimation(.easeInOut(duration: 0.2)) { showLog = false }
                }
                .zIndex(1)
            }
        }
    }

    // CalendarView.swift

    private func loadAppts() {
        _ = Calendar.current
        switch scope {
        case .day:
            appts = Appt.mock(on: selectedDate)

        case .week:
            let days = week(for: monthAnchor)
            appts = days.flatMap { Appt.mock(on: $0) }
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

private struct EnumPillSegmentedControl<E: CaseIterable & Equatable>: View where E.AllCases: RandomAccessCollection {
    @Binding var selection: E
    let titles: [String]

    var width: CGFloat = 200
    var height: CGFloat = 32
    var font: Font = .subheadline.weight(.semibold)
    var trackColor: Color = Color(.systemGray6)
    var trackStroke: Color = Color(.systemGray4)
    var textColor: Color = .primary
    private let inset: CGFloat = 5

    private var index: Int {
        Array(E.allCases).firstIndex(of: selection) ?? 0
    }

    var body: some View {
        let all = Array(E.allCases)
        let count = CGFloat(max(all.count, 1))
        let innerWidth = width - inset * 2
        let segW = innerWidth / count
        let pillH = height - inset * 2

        ZStack(alignment: .leading) {
            Capsule()
                .fill(trackColor)
                .overlay(Capsule().stroke(trackStroke, lineWidth: 1))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 3)
                    .frame(width: segW, height: pillH)
                    .offset(x: segW * CGFloat(index))
            }
            .padding(inset)

            HStack(spacing: 0) {
                ForEach(Array(all.enumerated()), id: \.offset) { i, value in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                            selection = value
                        }
                    } label: {
                        Text(titles[i])
                            .font(font)
                            .foregroundColor(selection == value ? .blue : .black)
                            .frame(width: segW, height: height)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, inset)
        }
        .frame(width: width, height: height)
        .clipShape(Capsule())
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

