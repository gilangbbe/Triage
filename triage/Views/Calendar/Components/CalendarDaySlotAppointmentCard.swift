//
//  AppointmentRowView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

// MARK: - SlotKind
enum SlotKind: CaseIterable, Hashable {
    case medical, radiology, laboratory, doctor

    var title: String {
        switch self {
        case .medical:    return "Medical Check Up"
        case .radiology:  return "Radiology"
        case .laboratory: return "Laboratorium"
        case .doctor:     return "Doctor"
        }
    }

    /// Accent colors that adapt automatically across Light/Dark
    var accent: Color {
        switch self {
        case .medical:    return Color(.systemBlue)
        case .radiology:  return Color(.systemGreen)
        case .laboratory: return Color(.systemPink)
        case .doctor:     return Color(.systemTeal)
        }
    }

    /// Card tint: keep neutral so it contrasts well in Dark Mode.
    /// Use system backgrounds to get automatic adaptation.
    var tint: Color {
        Color(.secondarySystemBackground)
    }

    /// Pill fill: a soft wash of the accent color.
    /// Using opacity over system background keeps it readable in Dark Mode.
    var pillFill: Color {
        accent.opacity(0.30)
    }

    var textColor: Color { Color(.label) }
}

// MARK: - Simple row for a patient name
private struct SlotPatientRow: View {
    let text: String
    let textColor: Color
    var body: some View {
        HStack {
            Text(text)
                .font(.title3.weight(.semibold))
                .foregroundStyle(textColor)
                .minimumScaleFactor(0.8)
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

// MARK: - Bucket card
private struct SlotBucketCard: View {
    enum Kind { case medical, radiology, lab , doctor}

    let kind: Kind
    let patients: [Appointment]
    @State private var isExpanded = true

    private let labelColor = Color(.label)

    private var accent: Color {
        switch kind {
        case .medical:   return Color(.systemBlue)
        case .radiology: return Color(.systemGreen)
        case .lab:       return Color(.systemPink)
        case .doctor:     return Color(.systemTeal)
        }
    }

    private var cardTint: Color {
        switch kind {
        case .medical:   return Color(.systemBlue).opacity(0.20)
        case .radiology: return Color(.systemGreen).opacity(0.20)
        case .lab:       return Color(.systemPink).opacity(0.20)
        case .doctor:     return Color(.systemTeal).opacity(0.20)
        }
    }

    private var pillTint: Color {
        accent.opacity(0.20)
    }

    private var titleText: String {
        switch kind {
        case .medical:   return "Medical Check Up"
        case .radiology: return "Radiology"
        case .lab:       return "Laboratorium"
        case .doctor:    return "Doctor"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(labelColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(pillTint)
                    )

                Spacer(minLength: 8)

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundStyle(Color(.tertiaryLabel))
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
                                .foregroundStyle(labelColor)
                            Spacer()
                        }
                        .padding(8)
                        if i < show - 1 {
                            Divider().overlay(Color(.separator))
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(cardTint)
        )
    }
}

// MARK: - Row that groups by kind
struct SlotBucketsRow: View {
    let appts: [Appointment]

    private func bucketKind(for appt: Appointment) -> SlotBucketCard.Kind {
        switch appt.inferredSlotKind {
        case .medical:    return .medical
        case .radiology:  return .radiology
        case .doctor:     return .doctor
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
            for k in d.keys {
                d[k]?.sort { $0.displayPatientName < $1.displayPatientName }
            }
            return d
        }()

        let visible: [SlotBucketCard.Kind] = [.medical, .radiology, .lab, .doctor]
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
