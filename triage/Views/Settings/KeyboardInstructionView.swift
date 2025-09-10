//
//  KeyboardInstructionView.swift
//  triage
//
//  Created by Gilang Banyu Biru Erassunu on 05/09/25.
//

import SwiftUI

// MARK: - Keyboard Instruction
struct KeyboardInstructionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Setting Up the Keyboard Extension")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color(hex: "#0F0E46"))
                .padding(.top, 20)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AppCard {
                        VStack(alignment: .leading, spacing: 16) {
                            StepRow(1, "Enable the Keyboard", "Go to Settings > General > Keyboards > Add New Keyboard > Select 'Triage Keyboard Extension'.")
                            StepRow(2, "Allow Full Access", "In the keyboard settings, enable ‘Allow Full Access’ for the 'Triage Keyboard Extension'")
                            StepRow(3, "Using the Extension", "When typing in any app, switch to the 'Triage Keyboard Extension' and paste customer messages to parse them automatically")
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Supported Patient Format:")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 3) {
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
                }
            }
        }
        .padding([.leading, .trailing], 16)
        .background(Color(.systemBackground))
    }
}

// MARK: - Components
private struct StepRow: View {
    let number: Int
    let title: String
    let detail: String
    let boldWords: [String] = ["Settings", "General", "Keyboards", "Add New Keyboard", "Allow Full Access", "Triage Keyboard Extension"]
    
    init(_ number: Int, _ title: String, _ detail: String) {
        self.number = number; self.title = title; self.detail = detail
    }
    
    // Convert detail string to AttributedString with bold words
    private var attributedDetail: AttributedString {
        var str = AttributedString(detail)
        for word in boldWords {
            if let range = str.range(of: word) {
                str[range].font = .callout.bold()
            }
        }
        return str
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                NumberBadge(number: number)
                Text(title).font(.title3).bold().foregroundColor(Color(hex: "0F0E46"))
            }
            Text(attributedDetail).font(.callout).foregroundColor(Color(hex: "0F0E46"))
        }
    }
}

private struct NumberBadge: View {
    let number: Int
    var body: some View {
        Text("\(number)")
            .font(.caption)
            .frame(width: 19, height: 19)
            .background(Circle().fill(Color(hex: "#0F0E46")))
            .foregroundStyle(Color(hex: "#F9F9F9"))
    }
}
private struct AppCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "#F7F7F7"))
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

}

#Preview {
    KeyboardInstructionView()
}
