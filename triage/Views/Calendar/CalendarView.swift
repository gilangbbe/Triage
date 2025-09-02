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
        let target = cal.date(from: DateComponents(year: 2025, month: 9, day: 1))!

        guard cal.isDate(day, inSameDayAs: target) else { return [] }

        func at(_ hour: Int, _ minute: Int = 0) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: day)!
        }
        func plus(_ minutes: Int, to d: Date) -> Date {
            cal.date(byAdding: .minute, value: minutes, to: d)!
        }

        let s1 = at(7)
        let s3 = at(8)

        return [
            .init(patient: "Mr Longest Name Possible",
                  tag: "Medical",
                  tagIcon: "staroflife.fill",
                  start: s1, end: plus(60, to: s1), avatarInitial: "K"),
            
            .init(patient: "Mr Longest Name Possible",
                  tag: "Labor",
                  tagIcon: "staroflife.fill",
                  start: s1, end: plus(60, to: s1), avatarInitial: "K"),

            .init(patient: "Ms Short Name",
                  tag: "Radiology",
                  tagIcon: "staroflife.fill",            // ← fixed typo
                  start: s1, end: plus(60, to: s1), avatarInitial: "S"),

            .init(patient: "Ms Test",
                  tag: "Radiology",
                  tagIcon: "staroflife.fill",            // ← fixed typo
                  start: s3, end: plus(60, to: s3), avatarInitial: "S")
        ]
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

    var body: some View {
        HStack(spacing: 0) {

            if scope == .day {
                SidebarPanel(selectedDate: $selectedDate, appts: appts)
                    .frame(width: 360)
                    .background(Color(.systemBackground))
                    .overlay(Divider(), alignment: .trailing)
            }

            VStack(spacing: 0) {
                // Segmented header
                HStack {
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
                            appts: $appts
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
        .onChange(of: scope)        { _ in loadAppts() }
        .navigationBarHidden(true)
    }

    private func loadAppts() {
        appts = Appt.mock(on: selectedDate)
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

            // labels
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

