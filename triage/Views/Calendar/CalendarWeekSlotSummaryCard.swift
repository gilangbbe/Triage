//
//  CalendarWeekSlotSummaryCard.swift
//  triage
//
//  Created by Hayya U on 03/09/25.
//

import SwiftUI

struct WeekSlotSummaryCard: View {
    let kindGroups: [SlotKind: [Appt]]
    @State private var expandedKinds: Set<SlotKind> = []

    private var orderedKinds: [SlotKind] {
        let order: [SlotKind] = [.medical, .radiology, .laboratory]
        return order.filter { (kindGroups[$0] ?? []).isEmpty == false }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(orderedKinds, id: \.self) { kind in
                let patients = kindGroups[kind] ?? []
                let cap = 3
                let shown = min(patients.count, cap)
                let isExpanded = expandedKinds.contains(kind)

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        if isExpanded { expandedKinds.remove(kind) }
                        else { expandedKinds.insert(kind) }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Text(kind.title)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(color(for: kind).opacity(0.08))
                                )
                                .layoutPriority(1)
                            
                            Text("\(shown)/\(cap)")
                                .font(.caption2.weight(.light))
                                .monospacedDigit()
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(color(for: kind).opacity(0.08))
                                )
                                .foregroundStyle(.primary)
                        }

                        if isExpanded {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(Array(patients.enumerated()), id: \.offset) { _, appt in
                                    Text(appt.patient)
                                        .font(.caption2)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 4)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color(for: kind).opacity(0.08))
                    )
                    .transition(.move(edge: .top))

                }
                .buttonStyle(.plain)
            }
        }
    }

    private func color(for kind: SlotKind) -> Color {
        switch kind {
        case .medical:    return .blue
        case .radiology:  return .green
        case .laboratory: return .red
        }
    }
}
