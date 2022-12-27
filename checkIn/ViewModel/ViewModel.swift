//
//  ViewModel.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-02.
//

import Foundation
import SwiftUI

class ViewModel: ObservableObject {

    var model = CheckInAppModel()
    
    func getPatientWithOHIP(ohip: String) -> Patient? {
        return model.getPatientWithOHIP(ohip: ohip)
    }
    
    func getPatientWithName(name: String, dateOfBirth: String) -> Patient? {
        return model.getPatientWithName(name: name, dateOfBirth: dateOfBirth)
    }
    
    func updatePatient(old: Patient, new: Patient) -> Bool {
        return model.updatePatient(old: old, new: new)
    }
    
    func bookAppointment(patient: Patient, date: String, time: String) -> Bool {
        return model.bookAppointment(patient: patient, date: date, time: time)
    }
    
    func updateCovidSymptom(to hasSymptoms: Bool) {
        model.patient.hasCovidSymptoms = hasSymptoms
    }
    
    func resetPatient() {
        model.resetPatient()
    }
}
