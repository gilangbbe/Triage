//
//  SignUpTextField.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 09/09/25.
//

import SwiftUI

struct SignUpTextField: View {
    let icon: String
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(label)
                    .foregroundColor(.gray)
            }
            TextField(placeholder, text: $text)
                .padding()
                .foregroundColor(.accentColor)
                .background(Color.formBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
        }
        .padding(.bottom, 16)
    }
}

//#Preview {
//    @State var text = ""
//    
//    SignUpTextField(icon: "person.text.rectangle.fill", label: "FULL NAME", placeholder: "Ex. Alvin Kita Bersama", text: $text)
//}

#Preview {
    SignUpTextField(
        icon: "person.text.rectangle.fill",
        label: "FULL NAME",
        placeholder: "Ex. Alvin Kita Bersama",
        text: .constant("Alvin Kita Bersama")
    )
}

