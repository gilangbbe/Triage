//
//  CalendarWeekStripView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

// MARK: - Week Strip
struct WeekStrip: View {
    @Binding var selectedDate: Date
    @Binding var monthAnchor: Date
    
    var body: some View {
        let days = week(for: monthAnchor)
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button {
                    monthAnchor = Calendar.current.date(byAdding: .day, value: -7, to: monthAnchor) ?? monthAnchor
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(Color(.tertiaryLabel))
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
                        .foregroundStyle(Color(.tertiaryLabel))
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
        let weekday = cal.component(.weekday, from: anchor)
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
                .foregroundStyle(Color(.secondaryLabel))

            Text(dayString(date))
                .font(.body.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color(.label))
                .frame(width: 36, height: 36)
                .background(
                    Circle().fill(
                        isSelected
                        ? Color(.systemBlue).opacity(0.80)
                        : (isToday ? Color(.systemBlue).opacity(0.30)
                                   : .clear)
                    )
                )
                .overlay(
                    Circle()
                        .stroke(
                            (isToday && !isSelected)
                            ? Color(.systemBlue).opacity(0.30)
                            : .clear,
                            lineWidth: 1
                        )
                )
        }
    }

    private func shortWeekday(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "E"
        return String(f.string(from: d).prefix(1)).uppercased()
    }
    
    private func dayString(_ d: Date) -> String {
        DateFormatter.with("d").string(from: d)
    }
}
