//
//  Patient.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-02.
//

import Foundation
import SwiftUI

class Patient {
    
    var hasCovidSymptoms = true
    var hasOhip = false
    var status = Status.undetermined
    var ohipID = ""
    var name = ""
    var dateOfBirth = ""
    var ohipExp = ""
    // AWS fields
    var firstName = ""
    var lastName = ""
    var sex = Sex.male
    var year = ""
    var month = ""
    var day = ""
    var demographicNo = ""
    var hcEffectiveDate = ""
    var hcRenewDate = ""
    var hin = ""
    var hcVersion = ""
    var hcType = "ON"
    var primaryPhone = ""
    var secondaryPhone = ""
    var email = ""
    var unitNumber = ""
    var address = ""
    var city = ""
    var state = ""
    var zip = ""
    var country = ""
    var dic: Dictionary<String, AnyObject> = [:]
    
    
    func processScannedResults() {
        let arr = name.components(separatedBy: " ")
        lastName = arr[arr.count-1]
        firstName = arr[0..<arr.count-1].joined(separator: " ")
        
        
        // Hc expirary and effective
        let processedExp = ohipExp.replacingOccurrences(of: " ", with: "")
        hcEffectiveDate = processedExp[0...9]
        hcRenewDate = processedExp[10...19]
        
        // ohip -> hin + VC
        let processedOhip = ohipID.replacingOccurrences(of: " - ", with: "")
        hin = processedOhip[0...9]
        hcVersion = processedOhip[10...11]
        
        // remove spaces in dob
        dateOfBirth = dateOfBirth.replacingOccurrences(of: " ", with: "")
    }
    
    func processSearchResults() {
        // name
        firstName = dic["firstName"] as? String ?? ""
        lastName = dic["lastName"] as? String ?? ""
        
        // email
        email = dic["email"] as? String ?? ""
        // address -> street adr + unit
        let adrString = dic["address"] as? String ?? ""
        let adrArray = adrString.components(separatedBy: ", #")
        if adrArray.count == 2 {
            unitNumber = adrArray[1]
            address = adrArray[0]
        } else {
            address = adrArray[0]
        }

        
        // city, province, country, zip
        city = dic["city"] as? String ?? ""
        state = dic["province"] as? String ?? ""
        zip = dic["postal"] as? String ?? ""
        
        // primaryPhone
        primaryPhone = dic["primaryPhone"] as? String ?? ""
        secondaryPhone = dic["secondaryPhone"] as? String ?? ""
        
        // Sex
        let sexStr = dic["sex"]
        if sexStr as? String ?? "" == "M" {
            sex = .male
        } else {
            sex = .female
        }
        
        // demoNo
        demographicNo = String(dic["demographicNo"] as! Int)
    }
    
    
    func generateDict() -> Dictionary<String, String> {
        var result: Dictionary<String, String>  = [:]
        
        result["firstName"] = firstName.uppercased()
        result["lastName"] = lastName.uppercased()

        if sex == .male {
            result["sex"] = "M"
        } else {
            result["sex"] = "F"
        }
        
        result["hin"] = hin
        result["dateOfBirth"] = dateOfBirth
        result["email"] = email
        if unitNumber == "" {
            result["address"] = address
        } else {
            result["address"] = address + ", #" + unitNumber
        }
        result["city"] = city
        result["postal"] = zip
        result["province"] = state
        result["primaryPhone"] = primaryPhone
        result["hcType"] = hcType
        result["newsletter"] = nil
        result["hcVersion"] = hcVersion
        
        
        if demographicNo != "" {
            result["demographicNo"] = demographicNo
        }
        
        
        result["hcEffectiveDate"] = hcEffectiveDate
        result["hcRenewDate"] = hcRenewDate
        result["secondaryPhone"] = secondaryPhone
        
        return result
        
    }
    func healthCardExpired() -> Bool {
        print(self.ohipExp)
        print(self.ohipID)
        if self.ohipID == "" { return false }
        if self.ohipExp == "" { return true }
        let year = Int(self.ohipExp[15...18])!
        let month = Int(self.ohipExp[22...23])!
        let day = Int(self.ohipExp[27...28])!
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        let curYear =  components.year!
        let curMonth = components.month!
        let curDay = components.day!
        
        if year < curYear {
            return true
        }
        
        if year == curYear && month < curMonth {
            return true
        }
        
        if year == curYear && month == curMonth && day < curDay {
            return true
        }
        
        return false
    }
    
    enum Status {
        case invalid
        case undetermined
        case expOhip
        case newPatient
        case oldPatient
    }
    
    enum Sex: String, Equatable, CaseIterable {
        case male = "Male"
        case female = "Female"
        
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }
}





//import SwiftUI
//import Combine
//import CoreLocation
//import MapKit
//
//struct ContentView: View {
//    @StateObject private var mapSearch = MapSearch()
//
//    func reverseGeo(location: MKLocalSearchCompletion) {
//        let searchRequest = MKLocalSearch.Request(completion: location)
//        let search = MKLocalSearch(request: searchRequest)
//        var coordinateK : CLLocationCoordinate2D?
//        search.start { (response, error) in
//        if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
//            coordinateK = coordinate
//        }
//
//        if let c = coordinateK {
//            let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
//            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//
//            guard let placemark = placemarks?.first else {
//                let errorString = error?.localizedDescription ?? "Unexpected Error"
//                print("Unable to reverse geocode the given location. Error: \(errorString)")
//                return
//            }
//
//            let reversedGeoLocation = ReversedGeoLocation(with: placemark)
//
//            address = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName)"
//            city = "\(reversedGeoLocation.city)"
//            state = "\(reversedGeoLocation.state)"
//            zip = "\(reversedGeoLocation.zipCode)"
//            mapSearch.searchTerm = address
//            isFocused = false
//
//                }
//            }
//        }
//    }
//
//    // Form Variables
//
//    @FocusState private var isFocused: Bool
//
//    private var address = ""
//    private var city = ""
//    private var state = ""
//    private var zip = ""
//
//// Main UI
//
//    var body: some View {
//
//            VStack {
//                List {
//                    Section {
//                        Text("Start typing your street address and you will see a list of possible matches.")
//                    } // End Section
//                    
//                    Section {
//                        TextField("Address", text: $mapSearch.searchTerm)
//
//// Show auto-complete results
//                        if address != mapSearch.searchTerm && isFocused == false {
//                        ForEach(mapSearch.locationResults, id: \.self) { location in
//                            Button {
//                                reverseGeo(location: location)
//                            } label: {
//                                VStack(alignment: .leading) {
//                                    Text(location.title)
//                                        .foregroundColor(Color.black)
//                                    Text(location.subtitle)
//                                        .font(.system(.caption))
//                                        .foregroundColor(Color.black)
//                                }
//                        } // End Label
//                        } // End ForEach
//                        } // End if
//// End show auto-complete results
//
//                        TextField("City", text: $city)
//                        TextField("State", text: $state)
//                        TextField("Zip", text: $zip)
//
//                    } // End Section
//                    .listRowSeparator(.visible)
//
//            } // End List
//
//            } // End Main VStack
//
//    } // End Var Body
//
//} // End Struct
