//
//  CalendarReminderPopup.swift
//  triage
//
//  Created by Hayya U on 08/09/25.
//

import SwiftUI

struct ReminderPopup: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CalendarViewModel.self) private var vm
    @Bindable var appt: Appointment
    @Binding var isPresented: Bool
    var onClose: () -> Void

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button { onClose() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }

            Text(reminderMessage(for: appt))
                .font(.body)
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

            HStack {
                Spacer()
                Button {
                    copyReminder(appt)
                    withAnimation(.easeInOut(duration: 0.15)) { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isPresented = false
                            appt.isReminded = true
                            do { try modelContext.save() } catch {
                                assertionFailure("Save failed: \(error)")
                                print("Save failed:", error)
                            }
                            vm.markReminded(appt)
                        }
                    }
                } label: {
                    Label(copied ? "Copied!" : "Copy Reminder", systemImage: "doc.on.doc")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray6)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 6, y: 2)
        )
    }

    // MARK: - Message Builders (Appointment-based)
    private func reminderMessage(for appt: Appointment) -> AttributedString {
        let patientName = appt.patient?.fullName ?? appt.name
        let kind = appt.inferredSlotKind.title
        guard let timeSlot = appt.timeSlot else {
            return AttributedString("Appointment time not available")
        }
        let timeText = time(timeSlot.startTime)

        var result = AttributedString("Hello ")

        var name = AttributedString(patientName)
        name.font = .body.bold()
        result.append(name)

        result.append(AttributedString(",\nThis is a friendly reminder for your "))

        var tag = AttributedString(kind)
        tag.font = .body.bold()
        result.append(tag)

        result.append(AttributedString(" appointment scheduled at "))

        var t = AttributedString(timeText)
        t.font = .body.bold()
        result.append(t)

        result.append(AttributedString(".\nPlease arrive 15 minutes earlier for registration."))

        return result
    }

    private func plainReminder(for appt: Appointment) -> String {
        let patientName = appt.patient?.fullName ?? appt.name
        let kind = appt.package?.name ?? appt.name
        guard let timeSlot = appt.timeSlot else {
            return "Hello \(patientName),\nAppointment time not available."
        }
        let timeText = time(timeSlot.startTime)
        return """
        Hello \(patientName),
        This is a friendly reminder for your \(kind) appointment scheduled at \(timeText).
        Please arrive 15 minutes earlier for registration.
        """
    }
    
    private func copyReminder(_ appt: Appointment) {
        let plain = plainReminder(for: appt)

        let attr = NSAttributedString(reminderMessage(for: appt))
        let rtf = try? attr.data(from: NSRange(location: 0, length: attr.length),
                                 documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])

        #if canImport(UIKit)
        if let rtf { UIPasteboard.general.setData(rtf, forPasteboardType: "public.rtf") }
        UIPasteboard.general.string = plain
        #elseif canImport(AppKit)
        let pb = NSPasteboard.general
        pb.clearContents()
        if let rtf { pb.setData(rtf, forType: .rtf) }
        pb.setString(plain, forType: .string)
        #endif
    }


    private func time(_ d: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        return f.string(from: d)
    }
}

