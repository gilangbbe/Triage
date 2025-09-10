//
//  Appointment.swift
//  triage
//
//  Created by Hayya U on 09/09/25.
//

import SwiftUI
import Foundation

extension Appointment {
    var inferredSlotKind: SlotKind {
        let basis = (package?.department?.name ?? name).lowercased()
        if basis.contains("medical")        { return .medical }
        if basis.contains("radio")          { return .radiology }
        if basis.contains("lab")            { return .laboratory }
        if basis.contains("doctor")        { return .doctor }
        return .medical
    }

    var displayPatientName: String { patient?.fullName ?? name }
}
