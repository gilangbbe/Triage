//
//  AppointmentRowView.swift
//  triage
//
//  Created by Hayya U on 29/08/25.
//

import SwiftUI

// MARK: - 3 fixed buckets
enum SlotKind: CaseIterable, Hashable { case medical, radiology, laboratory

    var title: String {
        switch self {
        case .medical:     return "Medical Check Up"
        case .radiology:   return "Radiology"
        case .laboratory:  return "Laboratorium"
        }
    }

    var tint: Color {
        switch self {
        case .medical:     return Color(red: 0.93, green: 0.96, blue: 1.00)
        case .radiology:   return Color(red: 0.92, green: 0.98, blue: 0.93)
        case .laboratory:  return Color(red: 1.00, green: 0.94, blue: 0.95)
        }
    }

    var pillFill: Color {
        switch self {
        case .medical:     return Color(red: 0.83, green: 0.88, blue: 0.98)
        case .radiology:   return Color(red: 0.82, green: 0.94, blue: 0.84)
        case .laboratory:  return Color(red: 1.00, green: 0.86, blue: 0.88)
        }
    }
    var textColor: Color { Color(red: 0.07, green: 0.10, blue: 0.27) }
}

// MARK: - Map your appointment tag to a SlotKind
extension Appt {
    var slotKind: SlotKind {
        let t = tag.lowercased()
        if t.contains("medical")   { return .medical }
        if t.contains("radio")     { return .radiology }
        if t.contains("lab")       { return .laboratory }
        if t.contains("consult")   { return .radiology }   // <— so your sample “Consultation” shows up
        return .medical
    }
}

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

private struct SlotBucketCard: View {
    enum Kind { case medical, radiology, lab }

    let kind: Kind
    let patients: [Appt]
    @State private var isExpanded = true

    private let navy = Color(red: 16/255, green: 27/255, blue: 79/255)

    private var cardTint: Color {
        switch kind {
        case .medical:  return Color(red: 0.93, green: 0.96, blue: 1.00)
        case .radiology:return Color(red: 0.92, green: 0.98, blue: 0.93)
        case .lab:      return Color(red: 1.00, green: 0.94, blue: 0.95)
        }
    }
    private var pillTint: Color {
        switch kind {
        case .medical:  return Color(red: 0.83, green: 0.88, blue: 0.98)
        case .radiology:return Color(red: 0.82, green: 0.94, blue: 0.84)
        case .lab:      return Color(red: 1.00, green: 0.86, blue: 0.88)
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
            // Header pill + chevron
            HStack(spacing: 10) {
                Text(titleText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(navy)
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

            // Names (1 when collapsed, up to 3 when expanded)
            let show = isExpanded ? min(3, patients.count) : min(1, patients.count)
            if show > 0 {
                VStack(spacing: 0) {
                    ForEach(0..<show, id: \.self) { i in
                        HStack {
                            Text(patients[i].patient)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(navy)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        if i < show - 1 {
                            Divider().overlay(navy.opacity(0.08))
                        }
                    }
                }
                // Let content define height so row can grow/shrink
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).fill(cardTint))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(navy.opacity(0.06)))
        .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
    }
}


struct SlotBucketsRow: View {
    let appts: [Appt]

    // Map tags -> card kind
    private func kind(for tag: String) -> SlotBucketCard.Kind? {
        let t = tag.lowercased()
        if t.contains("medical")   { return .medical }
        if t.contains("radiolog")  { return .radiology }
        if t.contains("labor")     { return .lab }
        return .medical // default if needed
    }

    var body: some View {
        // Group input into the 3 known buckets
        let grouped: [SlotBucketCard.Kind: [Appt]] = {
            var d: [SlotBucketCard.Kind: [Appt]] = [:]
            for a in appts {
                let k = kind(for: a.tag) ?? .medical
                d[k, default: []].append(a)
            }
            for k in d.keys { d[k]?.sort { $0.patient < $1.patient } }
            return d
        }()

        // Show buckets that have data, in fixed order
        let visible: [SlotBucketCard.Kind] = [.medical, .radiology, .lab].filter { !(grouped[$0] ?? []).isEmpty }

        HStack(alignment: .top, spacing: 24) {
            ForEach(visible, id: \.self) { k in
                SlotBucketCard(kind: k, patients: grouped[k] ?? [])
                    .frame(maxWidth: .infinity, alignment: .leading) // equal-width columns
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
