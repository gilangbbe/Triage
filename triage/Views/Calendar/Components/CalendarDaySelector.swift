//
//  CalendarDaySelector.swift
//  triage
//
//  Created by Hayya U on 04/09/25.
//

import SwiftUI

struct DaySelector: View {
    @Binding var date: Date

    @State private var isOpen = false
    @State private var draft = Date()

    private let cal = Calendar.current

    var body: some View {
        Button {
            draft = date
            withAnimation(.easeInOut(duration: 0.18)) { isOpen = true }
        } label: {
            HStack(spacing: 6) {
                Text(formatted(date))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color(.label))
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
                HStack {
                    Text("Select Date")
                        .font(.headline)
                    Spacer()
                    Button("Today") {
                        draft = Date()
                    }
                    Button("Done") {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            date = draft
                            isOpen = false
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                DatePicker(
                    "",
                    selection: $draft,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(.horizontal)

                // Quick step (previous / next day)
                HStack(spacing: 12) {
                    Button {
                        draft = cal.date(byAdding: .day, value: -1, to: draft) ?? draft
                    } label: { stepLabel("chevron.left") }

                    Button {
                        draft = cal.date(byAdding: .day, value: 1, to: draft) ?? draft
                    } label: { stepLabel("chevron.right") }
                }
                .padding(.bottom, 12)
            }
            .frame(minWidth: 340, idealWidth: 380, maxWidth: 420)
            .presentationCompactAdaptation(.popover)
        }
        .accessibilityLabel(Text("Selected date"))
        .accessibilityValue(Text(formatted(date)))
    }

    // MARK: - Helpers
    private func stepLabel(_ systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.body.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.12)))
    }

    private func formatted(_ date: Date) -> String {
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        let monthName = cal.monthSymbols[(comps.month ?? 1) - 1]
        let day = comps.day ?? 1
        let year = comps.year ?? 2000
        return "\(monthName) \(day)\(ordinal(day)), \(year)"
    }

    private func ordinal(_ n: Int) -> String {
        let teen = (11...13).contains(n % 100)
        if teen { return "th" }
        switch n % 10 {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }
}
