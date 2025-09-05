//
//  KeyboardInstructionView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

struct KeyboardInstructionView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Title
                Text("Setting Up the Keyboard Extension")
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#0F0E46"))

                // Steps Card
                VStack(alignment: .leading, spacing: 16) {
                    StepRow(
                        number: 1,
                        title: "Enable the Keyboard",
                        detail: "Go to Settings > General > Keyboards > Add New Keyboard > Select “Triage Keyboard Extension”."
                    )
                    StepRow(
                        number: 2,
                        title: "Allow Full Access",
                        detail: "In the keyboard settings, enable ‘Allow Full Access’ for the “Triage Keyboard Extension”."
                    )
                    StepRow(
                        number: 3,
                        title: "Using the Extension",
                        detail: "When typing in any app, switch to the “Triage Keyboard Extension” and paste customer messages to parse them automatically."
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.06), radius: 6, y: 2)
                )

                // Supported Format
                VStack(alignment: .leading, spacing: 8) {
                    Text("Supported Patient Format:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("NIK: 1234567890123456")
                        Text("Nama lengkap: Biru")
                        Text("Tgl lahir: 20 Juli 2002")
                        Text("No telp: 085868694465")
                        Text("Alamat lengkap: Jl. Sudirman No. 123, Jakarta Pusat")
                        Text("Jenis kelamin(P/L): L")
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .italic()
                }
                .padding(.top, 8)

                Spacer(minLength: 24)
            }
            .padding(24)
        }
    }
}

// MARK: - Components

private struct StepRow: View {
    let number: Int
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            NumberBadge(number: number)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline).bold()
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct NumberBadge: View {
    let number: Int
    var body: some View {
        Text("\(number)")
            .font(.footnote).bold()
            .frame(width: 26, height: 26)
            .background(
                Circle()
                    .fill(Color(.systemIndigo).opacity(0.12))
            )
            .overlay(
                Circle()
                    .stroke(Color(.systemIndigo).opacity(0.35), lineWidth: 1)
            )
            .foregroundStyle(Color(.systemIndigo))
            .accessibilityHidden(true)
    }
}

#Preview {
    KeyboardInstructionView()
}
