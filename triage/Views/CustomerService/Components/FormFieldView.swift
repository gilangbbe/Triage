//
//  FormFieldView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 04/09/25.
//

import SwiftUI

struct FormFieldView: View {
    let icon: String
    let label: String
    let placeholder: String
    let value: String?
    @Binding var text: String
    var isEditing: Bool = false
    
    init(icon: String, label: String, placeholder: String, text: Binding<String>, isEditing: Bool) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = nil
        self._text = text
        self.isEditing = isEditing
    }
    
    init(icon: String, label: String, placeholder: String, value: String, isEditing: Bool) {
        self.icon = icon
        self.label = label
        self.placeholder = placeholder
        self.value = value
        self._text = .constant("")
        self.isEditing = isEditing
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            Text(label)
                .foregroundColor(.gray)
        }
        .padding(.leading)
        if let displayValue = value {
            Text(displayValue)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.placeholder)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .foregroundColor(isEditing ? .accentColor : .gray)
                .padding(.bottom, 16)
        } else {
            TextField(placeholder, text: $text)
                .font(.headline)
                .padding()
                .background(Color.placeholder)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 16)
                .foregroundColor(isEditing ? .accentColor : .gray)
                .disabled(!isEditing)
        }
    }
}
