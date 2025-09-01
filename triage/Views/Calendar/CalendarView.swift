//
//  CalendarView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
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
        let targetDate = cal.date(from: DateComponents(year: 2025, month: 9, day: 1))!
        
        guard cal.isDate(day, inSameDayAs: targetDate) else {
            return []
        }
        
        let s1 = cal.date(bySettingHour: 7, minute: 00, second: 0, of: day)!
        let s3 = cal.date(bySettingHour: 8, minute: 00, second: 0, of: day)!
        let e1 = cal.date(byAdding: .minute, value: 60, to: s1)!
        let e2 = cal.date(byAdding: .minute, value: 60, to: s1)!
        let e3 = cal.date(byAdding: .minute, value: 60, to: s3)!
        return [
            .init(patient: "Mr Longest Name Possible",
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

struct CalTheme {
    static let navy = Color(red: 16/255, green: 27/255, blue: 79/255)
    static let grid = Color.secondary.opacity(0.25)
    static let chipBG = Color.green.opacity(0.22)
    static let chipStroke = Color.green.opacity(0.55)
    static let cardBG = Color(uiColor: .secondarySystemBackground)
}

struct CalendarView: View {
    enum Scope: String, CaseIterable { case day = "Day", week = "Week" }
    @Environment(\.horizontalSizeClass) private var hClass
    @State private var scope: Scope = .day
    @State private var selectedDate = Date()
    @State private var monthAnchor = Date()
    @State private var appts: [Appt] = []
    
    var body: some View {
        HStack(spacing: 0) {
            SidebarPanel(selectedDate: $selectedDate, appts: appts)
                .frame(width: 360)                          // tweak width if needed
                .background(Color(.systemBackground))
                .overlay(Divider(), alignment: .trailing)

            VStack(spacing: 0) {
                Header(monthAnchor: $monthAnchor, scope: $scope)
                OverviewHeader()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                if scope.rawValue == "Day" {
                    CalendarDayView(selectedDate: $selectedDate,
                                    monthAnchor: $monthAnchor,
                                    appts: $appts)
                } else if scope.rawValue == "Week" {
                    CalendarWeekView(selectedDate: $selectedDate,
                                     monthAnchor: $monthAnchor,
                                     appts: $appts)
                }
            }
            .background(Color(uiColor: .systemBackground))
            .padding(.top, 8)
            .padding(.horizontal, 24)
        }
        .onChange(of: selectedDate) { _, newDate in
            appts = Appt.mock(on: newDate)
        }
        .onChange(of: scope) { _, _ in
            appts = Appt.mock(on: selectedDate)
        }
        .navigationBarHidden(true)
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

