//
//  CheckInAppModel.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-02.
//

import SwiftUI
import Foundation

class CheckInAppModel {
    
    var patient  = Patient()
    
    //  ohip -> get demographic
    func getPatientWithOHIP(ohip: String) -> Patient {
        return Patient()
    }
    
    //  name + dob -> get demographic
    func getPatientWithName(name: String, dateOfBirth: String) -> Patient {
        return Patient()
    }
    
    
    func updatePatient(old: Patient, new: Patient) -> Bool {
        return true
    }
    
    func bookAppointment(patient: Patient, date: String, time: String) -> Bool {
        return true
    }
    
    func resetPatient() {
        self.patient = Patient()
    }
}

