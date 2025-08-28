//
//  NotificationSheetView.swift
//  triage
//
//  Created by Jason Miracle Gunawan on 28/08/25.
//

import SwiftUI

struct NotificationSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Notification")
                        .font(.headline)
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                }
                .padding()
                ScrollView {
                    Divider()
                        .frame(height:1)
                        .background(Color.gray)
                        .padding(.horizontal)
                    VStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { i in
                            HStack {
                                Image(systemName: "square.and.pencil.circle.fill")
                                    .font(.system(size: 32))
                                Text("Okta changed Jane Doe's service choice for her August Appointment.")
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Divider()
                                .frame(height:1)
                                .background(Color.gray)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    NotificationSheetView()
}
