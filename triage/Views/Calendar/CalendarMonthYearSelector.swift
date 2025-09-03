//
//  CalendarMonthYearSelector.swift
//  triage
//
//  Created by Hayya U on 04/09/25.
//

import SwiftUI

// MARK: - MonthYearSelector
struct MonthYearSelector: View {
    @Binding var monthAnchor: Date

    @State private var isOpen = false
    @State private var draftMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var draftYear: Int  = Calendar.current.component(.year, from: Date())

    private let cal = Calendar.current
    private let years = Array(2000...2100)  // adjust as needed

    var body: some View {
        Button {
            // seed draft from current anchor
            let comps = cal.dateComponents([.year, .month], from: monthAnchor)
            draftMonth = comps.month ?? 1
            draftYear  = comps.year  ?? years.first!
            withAnimation(.snappy) { isOpen = true }
        } label: {
            HStack(spacing: 8) {
                Text(formattedTitle(for: monthAnchor)) // "August 2025" w/ bold month
                Image(systemName: "chevron.down")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isOpen ? 180 : 0))
                    .animation(.easeInOut(duration: 0.18), value: isOpen)
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isOpen, arrowEdge: .top) {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Text("Select Month & Year")
                        .font(.headline)
                    Spacer()
                    Button("Done") {
                        withAnimation(.easeInOut) {
                            monthAnchor = cal.date(from: DateComponents(year: draftYear, month: draftMonth, day: 1)) ?? monthAnchor
                            isOpen = false
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                // Wheels
                HStack(spacing: 0) {
                    Picker("Month", selection: $draftMonth) {
                        ForEach(1...12, id: \.self) { m in
                            Text(cal.monthSymbols[m - 1]).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)

                    Picker("Year", selection: $draftYear) {
                        ForEach(years, id: \.self) { y in
                            Text("\(y)").tag(y)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .labelsHidden()
                .frame(height: 180)

                // Quick actions
                HStack(spacing: 12) {
                    Button {
                        shift(byMonths: -1)
                    } label: { labelChevron("chevron.left", "Prev") }

                    Button {
                        let now = Date()
                        let comps = cal.dateComponents([.year, .month], from: now)
                        draftMonth = comps.month ?? draftMonth
                        draftYear  = comps.year  ?? draftYear
                    } label: { labelChevron("calendar", "Today") }

                    Button {
                        shift(byMonths: +1)
                    } label: { labelChevron("chevron.right", "Next") }
                }
                .padding(.bottom, 12)
            }
            .padding(.vertical, 6)
            .presentationCompactAdaptation(.popover)
        }
        .accessibilityLabel(Text("Month and year"))
        .accessibilityValue(Text(formattedPlain(for: monthAnchor)))
    }

    // MARK: helpers

    private func shift(byMonths delta: Int) {
        let current = cal.date(from: DateComponents(year: draftYear, month: draftMonth, day: 1)) ?? Date()
        let next = cal.date(byAdding: .month, value: delta, to: current) ?? current
        let c = cal.dateComponents([.year, .month], from: next)
        draftMonth = c.month ?? draftMonth
        draftYear  = c.year  ?? draftYear
    }

    private func formattedPlain(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: date)
    }

    private func formattedTitle(for date: Date) -> AttributedString {
        let comps = cal.dateComponents([.year, .month], from: date)
        let monthName = cal.monthSymbols[(comps.month ?? 1) - 1]
        let yearStr = String(comps.year ?? 2000)

        var attr = AttributedString("\(monthName) \(yearStr)")
        if let monthRange = attr.range(of: monthName) {
            attr[monthRange].font = .system(size: 22, weight: .bold)   // bold month
            attr[monthRange].foregroundColor = Color(.label)
        }
        if let yearRange = attr.range(of: yearStr) {
            attr[yearRange].font = .system(size: 22, weight: .regular) // regular year
            attr[yearRange].foregroundColor = Color(.label)
        }
        return attr
    }

    private func labelChevron(_ systemName: String, _ text: String) -> some View {
        Label(text, systemImage: systemName)
            .labelStyle(.iconOnly) // keep it compact; swap to automatic if you want text
            .font(.body.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.12)))
    }
}
