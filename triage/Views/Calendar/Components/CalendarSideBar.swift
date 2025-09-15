//
//  CalendarSideBar.swift
//  triage
//
//  Created by Hayya U on 01/09/25.
//
import SwiftUI

struct SidebarPanel: View {
    @Environment(CalendarViewModel.self) private var vm
    @Binding var selectedDate: Date
    @Binding var showLog: Bool

    let appointments: [Appointment]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Schedule")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color.primary)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showLog = true }
                } label: {
                    Label("Reminder Log", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
                .padding(.top, 6)
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Today’s Schedule")
                        .font(.headline)
                    Spacer()
                    if !todaysAppts.isEmpty {
                        Text("\(todaysAppts.count)")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
                
                DaySelector(date: $selectedDate)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sortedReminders, id: \.persistentModelID) { a in
                        ReminderCard(appt: a, style: .needToRemind)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 24)
            }
            .refreshable {
                await MainActor.run { vm.reloadForVisibleInterval() }
            }
        }
    }

    // MARK: - Data helpers
    private var todaysAppts: [Appointment] {
        let cal = Calendar.current
        return appointments.filter { 
            guard let timeSlot = $0.timeSlot else { return false }
            return cal.isDate(timeSlot.startTime, inSameDayAs: selectedDate) 
        }
    }

    private var sortedReminders: [Appointment] {
        todaysAppts.sorted {
            if $0.isReminded == $1.isReminded {
                guard let timeSlot1 = $0.timeSlot, let timeSlot2 = $1.timeSlot else { return false }
                return timeSlot1.startTime < timeSlot2.startTime
            }
            return $0.isReminded == false && $1.isReminded == true
        }
    }
}
