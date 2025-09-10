//
//  CalendarDayView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

struct CalendarDayView: View {
    @Environment(CalendarViewModel.self) private var vm
    @Binding var showAddAppointment: Bool

    var body: some View {
        VStack {
            OverviewHeader(showAddAppointment: $showAddAppointment)
            TimelineBoard(
                selectedDate: vm.selectedDate,
                appointments: vm.appointments(on: vm.selectedDate)
            )
            .padding(.top, 24)

            Spacer()
        }
    }
}

// MARK: - Timeline Board
private struct TimelineBoard: View {
    let selectedDate: Date
    let appointments: [Appointment]

    private let minEmptyRowHeight: CGFloat = 128
    private let timeTextWidth: CGFloat = 56
    private let timeLeadingPad: CGFloat = 12
    private let rightPad: CGFloat = 8
    private let rowSideInset: CGFloat = 24
    private let rowTopPadding: CGFloat = 16
    private let hours = Array(0..<24)

    private var timeGutterWidth: CGFloat { timeTextWidth + timeLeadingPad }

    var body: some View {
        let grouped = groupByHour(appointments)

        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 0) {
                ForEach(hours, id: \.self) { h in
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 1)

                    HStack(alignment: .top, spacing: 0) {
                        Text(String(format: "%02d.00", h))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(width: timeGutterWidth, alignment: .trailing)

                        if let slotAppts = grouped[h], !slotAppts.isEmpty {
                            // Keep your existing row as-is
                            SlotBucketsRow(appts: slotAppts)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, rowSideInset)
                                .padding(.top, rowTopPadding)
                                .padding(.bottom, rowTopPadding)
                                .padding(.trailing, rightPad)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, rightPad)
                                .frame(height: minEmptyRowHeight)
                        }
                    }
                }
            }
        }
    }

    // MARK: Helpers
    private func groupByHour(_ appts: [Appointment]) -> [Int: [Appointment]] {
        let cal = Calendar.current
        var dict: [Int: [Appointment]] = [:]

        for a in appts {
            let hour = cal.component(.hour, from: a.timeSlot.startTime)
            dict[hour, default: []].append(a)
        }

        for k in dict.keys {
            dict[k]?.sort {
                ($0.timeSlot.startTime, $0.name) < ($1.timeSlot.startTime, $1.name)
            }
        }
        return dict
    }
}
