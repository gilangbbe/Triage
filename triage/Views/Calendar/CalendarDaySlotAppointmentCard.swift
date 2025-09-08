//
//  AppointmentRowView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

// MARK: - SlotKind stays the same
enum SlotKind: CaseIterable, Hashable {
    case medical, radiology, laboratory

    var title: String {
        switch self {
        case .medical:    return "Medical Check Up"
        case .radiology:  return "Radiology"
        case .laboratory: return "Laboratorium"
        }
    }

    var tint: Color {
        switch self {
        case .medical:    return Color(red: 0.93, green: 0.96, blue: 1.00)
        case .radiology:  return Color(red: 0.92, green: 0.98, blue: 0.93)
        case .laboratory: return Color(red: 1.00, green: 0.94, blue: 0.95)
        }
    }

    var pillFill: Color {
        switch self {
        case .medical:    return Color(red: 0.83, green: 0.88, blue: 0.98)
        case .radiology:  return Color(red: 0.82, green: 0.94, blue: 0.84)
        case .laboratory: return Color(red: 1.00, green: 0.86, blue: 0.88)
        }
    }

    var textColor: Color { Color(red: 0.07, green: 0.10, blue: 0.27) }
}

extension Appointment {
    var inferredSlotKind: SlotKind {
        // Prefer a concrete property if you have it:
        // if let k = self.slotKindProperty { return k }
        let basis = (package?.name ?? name).lowercased()
        if basis.contains("medical")        { return .medical }
        if basis.contains("radio")          { return .radiology }
        if basis.contains("lab")            { return .laboratory }
        if basis.contains("consult")        { return .radiology }
        return .medical
    }

    var displayPatientName: String { patient?.fullName ?? name }
}

// MARK: - Simple row for a patient name (unchanged layout)
private struct SlotPatientRow: View {
    let text: String
    let textColor: Color
    var body: some View {
        HStack {
            Text(text)
                .font(.title3.weight(.semibold))
                .foregroundStyle(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Bucket card (uses Appointment)
private struct SlotBucketCard: View {
    enum Kind { case medical, radiology, lab }

    let kind: Kind
    let patients: [Appointment]
    @State private var isExpanded = true

    private let navy = Color(red: 16/255, green: 27/255, blue: 79/255)

    private var cardTint: Color {
        switch kind {
        case .medical:   return Color(red: 0.93, green: 0.96, blue: 1.00)
        case .radiology: return Color(red: 0.92, green: 0.98, blue: 0.93)
        case .lab:       return Color(red: 1.00, green: 0.94, blue: 0.95)
        }
    }
    private var pillTint: Color {
        switch kind {
        case .medical:   return Color(red: 0.83, green: 0.88, blue: 0.98)
        case .radiology: return Color(red: 0.82, green: 0.94, blue: 0.84)
        case .lab:       return Color(red: 1.00, green: 0.86, blue: 0.88)
        }
    }
    private var titleText: String {
        switch kind {
        case .medical:   return "Medical Check Up"
        case .radiology: return "Radiology"
        case .lab:       return "Laboratorium"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(navy)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 8).fill(pillTint))

                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(navy.opacity(0.6))
                        .font(.subheadline.weight(.semibold))
                        .padding(6)
                }
                .buttonStyle(.plain)
            }

            let show = isExpanded ? min(3, patients.count) : min(1, patients.count)
            if show > 0 {
                VStack(spacing: 0) {
                    ForEach(0..<show, id: \.self) { i in
                        HStack {
                            Text(patients[i].displayPatientName)
                                .font(.body)
                                .foregroundStyle(navy)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(8)
                        if i < show - 1 {
                            Divider().overlay(navy.opacity(0.08))
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(cardTint))
    }
}

// MARK: - Row that groups by kind (uses Appointment)
struct SlotBucketsRow: View {
    let appts: [Appointment]

    private func bucketKind(for appt: Appointment) -> SlotBucketCard.Kind {
        switch appt.inferredSlotKind {
        case .medical:    return .medical
        case .radiology:  return .radiology
        case .laboratory: return .lab
        }
    }

    var body: some View {
        let grouped: [SlotBucketCard.Kind: [Appointment]] = {
            var d: [SlotBucketCard.Kind: [Appointment]] = [:]
            for a in appts {
                let k = bucketKind(for: a)
                d[k, default: []].append(a)
            }
            for k in d.keys { d[k]?.sort { $0.displayPatientName < $1.displayPatientName } }
            return d
        }()

        let visible: [SlotBucketCard.Kind] = [.medical, .radiology, .lab]
            .filter { !(grouped[$0] ?? []).isEmpty }

        HStack(alignment: .top, spacing: 24) {
            ForEach(visible, id: \.self) { k in
                SlotBucketCard(kind: k, patients: grouped[k] ?? [])
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
