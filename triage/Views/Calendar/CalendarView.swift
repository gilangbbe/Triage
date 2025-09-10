//
//  CalendarView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(CalendarViewModel.self) private var vm
    @Environment(AppointmentListViewModel.self) private var listVM

    @Environment(\.horizontalSizeClass) private var hClass
    @Environment(\.modelContext) private var modelContext

    @State private var showLog = false
    @State private var showAddAppointment = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                if vm.scope == .day {
                    SidebarPanel(
                        selectedDate: Binding(
                            get: { vm.selectedDate },
                            set: { vm.selectedDate = $0 }
                        ),
                        showLog: $showLog,
                        appointments: vm.appointments(on: vm.selectedDate)
                    )

                    .frame(width: 360)
                    .background(Color(.systemBackground))
                    .overlay(Divider(), alignment: .trailing)
                }

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        if vm.scope == .week {
                            MonthYearSelector(
                                monthAnchor: Binding(
                                    get: { vm.monthAnchor },
                                    set: { vm.monthAnchor = $0 }
                                )
                            )
                        }
                        Spacer()
                        EnumPillSegmentedControl(
                            selection: Binding(
                                get: { vm.scope },
                                set: { vm.scope = $0 }
                            ),
                            titles: CalendarViewModel.Scope.allCases.map(\.rawValue),
                            width: 300, height: 32,
                            font: .callout.weight(.semibold),
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)

                    Divider().overlay(Color(.systemGray4))

                    Group {
                        switch vm.scope {
                        case .day:
                            CalendarDayView(showAddAppointment: $showAddAppointment)
                        case .week:
                            CalendarWeekView()
                        }
                    }
                }
                .background(Color(uiColor: .systemBackground))
                .padding(.top, 8)
                .padding(.horizontal, 24)
            }
            .onAppear { vm.reloadForVisibleInterval() }
            .task(id: vm.scope) { vm.reloadForVisibleInterval() }
            .task(id: vm.selectedDate.startOfDay) { vm.reloadForVisibleInterval() }
            .task(id: vm.monthAnchor.startOfDay) { vm.reloadForVisibleInterval() }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showLog) {
            ReminderLogView(
                logs: HistoryManager.shared.history,
                onClose: { withAnimation(.easeInOut(duration: 0.2)) { showLog = false } }
            )
        }
        .sheet(isPresented: $showAddAppointment) {
            AddAppointmentView(appointmentManager: listVM.manager)
        }
    }
}


private struct EnumPillSegmentedControl<E: CaseIterable & Equatable>: View where E.AllCases: RandomAccessCollection {
    @Binding var selection: E
    let titles: [String]

    var width: CGFloat = 200
    var height: CGFloat = 32
    var font: Font = .subheadline.weight(.semibold)

    var trackColor: Color = Color(.secondarySystemBackground)
    var pillColor: Color = Color(.tertiarySystemBackground)
    var textColor: Color = Color(.secondaryLabel)
    var selectedText: Color = Color(.label)

    private let inset: CGFloat = 5
    private var index: Int { Array(E.allCases).firstIndex(of: selection) ?? 0 }

    var body: some View {
        let all = Array(E.allCases)
        let count = CGFloat(max(all.count, 1))
        let innerWidth = width - inset * 2
        let segW = innerWidth / count
        let pillH = height - inset * 2

        ZStack(alignment: .leading) {
            Capsule()
                .fill(trackColor)
            
            Capsule()
                .fill(pillColor)
                .frame(width: segW, height: pillH)
                .offset(x: segW * CGFloat(index))
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
                            .foregroundStyle(selection == value ? selectedText : textColor)
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

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
        CalendarView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
