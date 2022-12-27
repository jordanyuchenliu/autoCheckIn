//
//  UpdateRetrievedPatientContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-11.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit

struct UpdateRetrievedPatientContentView: View {
    
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var viewModel: ViewModel
    var newPatient: Bool
    @Binding var isPresented: Bool
    @Binding var patient: Patient
    @State var remaining = 100.0
    @State var reasonForVisit = ""
    @State var loading = false
    @State var incompleteFields = false
    @State var loadingText = ""
    
    var cityBinding: Binding<String> {
        Binding(get: { self.patient.city }, set: { self.patient.city = $0 })
    }
    
    var provBinding: Binding<String> {
        Binding(get: { self.patient.state }, set: { self.patient.state = $0 })
    }
    
    var zipBinding: Binding<String> {
        Binding(get: { self.patient.zip }, set: { self.patient.zip = $0 })
    }
    
    @State var presentConfirmationScreen = false
    @State var errorOccurred = false
    @StateObject var mapSearch: AddressAutoComplete
    @FocusState var isFocused: Bool
    @State var presentPopover = false
    var body: some View {
        if loading {
            LoadingView(loadingText: $loadingText)
        } else {
            Spacer()
            VStack {
                Spacer()
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .foregroundColor(.red)
                            .frame(width: UIScreen.screenWidth/40, height: UIScreen.screenWidth/40)
                    }
                    Spacer()
                }
                Spacer()
                VStack {
                    if !newPatient {
                        Text("Please update your information if needed.").font(.largeTitle)
                    } else {
                        Text("Welcome, please enter the following information").font(.largeTitle)
                    }
                    HStack {
                        Spacer()
                        Text("Name: ").font(.title)
                        TextField("First name", text: $patient.firstName)
                            .textFieldStyle(OutlinedTextFieldStyle())
                            
                        TextField("Last name", text: $patient.lastName)
                            .textFieldStyle(OutlinedTextFieldStyle())
                        Spacer()
                        if newPatient {
                            Spacer()
                            Text("Sex: ").font(.largeTitle)
                            Picker("", selection: $patient.sex) {
                                ForEach(Patient.Sex.allCases, id: \.self) { value in
                                    Text(value.localizedName)
                                        .tag(value)
                                        .font(.largeTitle)
                                        
                                }
                            }.border(.gray)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("Contact: ").font(.title)
                        TextField("Phone Number", text: $patient.primaryPhone)
                            .textFieldStyle(OutlinedTextFieldStyle())
                        TextField("Email(Optional)", text: $patient.email)
                            .textFieldStyle(OutlinedTextFieldStyle())
                        Text("Emergency Contact: ").font(.title3)
                        TextField("Emergency Contact", text: $patient.secondaryPhone)
                            .textFieldStyle(OutlinedTextFieldStyle())
                    }
                    HStack {
                        Spacer()
                        Text("Address: ").font(.title)
                        VStack(alignment: .leading) {
                            Section {
                                TextField("Street Address", text: $mapSearch.searchTerm)
                                    .textFieldStyle(OutlinedTextFieldStyle())
                                    .modifier(TextFieldClearButton(text: $mapSearch.searchTerm))
                                    .onChange(of: mapSearch.searchTerm) { value in
                                        DispatchQueue.main.async {
                                            if value == "" {
                                                presentPopover = false
                                            } else {
                                                presentPopover = true
                                            }
                                        }
                                        
                                    }.popover(isPresented: $presentPopover) {
                                        if patient.address != mapSearch.searchTerm && isFocused == false {
                                            ScrollView(.vertical) {
                                                VStack(alignment: .leading) {
                                                    ForEach(mapSearch.locationResults, id: \.self) { location in
                                                        Text("====================================================")
                                                        Button {
                                                            reverseGeo(location: location)
                                                            presentPopover = false
                                                        } label: {
                                                            VStack(alignment: .leading) {
                                                                Text(location.title)
                                                                    .foregroundColor(Color.black)
                                                                Text(location.subtitle)
                                                                    .font(.system(.caption))
                                                                    .foregroundColor(Color.black)
                                                            }
                                                        }
                                                        
                                                    }
                                                }.frame(maxWidth: .infinity)
                                            }.frame(width: UIScreen.screenWidth/2, height: UIScreen.screenHeight/3)
                                                .padding()
                                        }
                                    }
                            }
                        }.padding()
                        
                        Text("Unit(Optional)").font(.title)
                        TextField("Unit", text: $patient.unitNumber)
                            .textFieldStyle(OutlinedTextFieldStyle())
                            .frame(width: UIScreen.screenWidth/6)
                    }
                    HStack {
                        Spacer()
                        TextField("City", text: cityBinding)
                            .textFieldStyle(OutlinedTextFieldStyle())
                            .disabled(true)
                        TextField("Province/Territory", text: provBinding)
                            .textFieldStyle(OutlinedTextFieldStyle())
                            .disabled(true)
                        TextField("Postal Code", text: zipBinding)
                            .textFieldStyle(OutlinedTextFieldStyle())
                    }
                    HStack {
                        Spacer()
                        Text("Please enter the reason for visit(in 20 characters).").font(.title)
                        TextField("Reason for visit", text: $reasonForVisit)
                            .onChange(of: reasonForVisit, perform: { newValue in
                                if newValue.count > 20 {
                                    reasonForVisit = String(newValue.prefix(20))
                                }
                                
                            })
                            .textFieldStyle(OutlinedTextFieldStyle())
                            .foregroundColor(reasonForVisit.count >= 20 ? .red : .black)

                    }
                    HStack {
                        Spacer()
                        Button {
                            if reasonForVisit != "" {
                                let handler = AWSHandler()
                                let info = patient.generateDict()
                                loading = true
                                if newPatient {
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        let result: Dictionary<String, AnyObject> = handler.postDemo(newDemo: info as Dictionary<String, AnyObject>) ?? [:]
                                        if result["message"] as? String == "SUCCESS" {
                                            var provider = UserDefaults.standard.array(forKey: "providers") ?? [".default"]
                                            if provider.count == 0 {
                                                provider = [".default"]
                                            }
                                            if handler.addAppointment(firstName: patient.firstName,
                                                                          lastName: patient.lastName,
                                                                          hin: patient.hin,
                                                                          physicianId: provider[0] as! String,
                                                                          appointmentNote: reasonForVisit,
                                                                          completion: { loading = false }) {
                                                presentConfirmationScreen = true
                                            } else {
                                                errorOccurred = true
                                            }
                                        } else {
                                            errorOccurred = true
                                        }
                                    }
                                } else {
                                    DispatchQueue.global().async {
                                        let result: Dictionary<String, AnyObject> = handler.putDemo(updatedDemo: info as Dictionary<String, AnyObject>) ?? [:]
                                        if result["message"] as? String == "SUCCESS" {
                                            var provider = UserDefaults.standard.array(forKey: "providers") ?? [".default"]
                                            if provider.count == 0 {
                                                provider = [".default"]
                                            }
                                            if handler.addAppointment(firstName: patient.firstName,
                                                                          lastName: patient.lastName,
                                                                          hin: patient.hin,
                                                                          physicianId: provider[0] as! String,
                                                                          appointmentNote: reasonForVisit,
                                                                          completion: { loading = false }) {
                                                presentConfirmationScreen = true
                                            } else {
                                                errorOccurred = true
                                            }
                                        } else {
                                            errorOccurred = true
                                        }
                                    }
                                }
                            } else {
                                incompleteFields = true
                            }
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(.bordered)
                        .fullScreenCover(isPresented: $presentConfirmationScreen) {
                            OntarioBookingConfirmationContentView(isPresented: $presentConfirmationScreen)
                                .onDisappear {
                                    isPresented = false
                                }
                        }
                        .fullScreenCover(isPresented: $errorOccurred) {
                            NoOntarioHealthCardContentView(errorType: .bookingIssue, isPresented: $errorOccurred)
                                .onDisappear {
                                    isPresented = false
                                }
                        }

                    }
                    Spacer()
                }
            }
            .padding()
            .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
                self.remaining -= 0.01
                if self.remaining <= 0 {
                    self.mode.wrappedValue.dismiss()
                }
            }
            .onTapGesture {
                if presentPopover {
                    presentPopover = false
                }
                remaining = 100.0
            }
            .alert(isPresented: $incompleteFields) {
                Alert(title: Text("Name, phone number, address and reason for visit are required fields."))
            }
        }
        
    }
    func reverseGeo(location: MKLocalSearchCompletion) {
        patient.address = location.title
        let subtitleArr = location.subtitle.components(separatedBy: ", ")
        patient.city = subtitleArr[0]
        patient.state = subtitleArr[1]
        patient.country = subtitleArr[2]
        mapSearch.searchTerm = patient.address
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK : CLLocationCoordinate2D?
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                coordinateK = coordinate
            }

            if let c = coordinateK {
                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }

                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    patient.zip = "\(reversedGeoLocation.zipCode)"

                    
                    isFocused = false

                }
            }
        }
    }

}


extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

//struct UpdateRetrievedPatientContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        UpdateRetrievedPatientContentView(isPresented: .constant(true), patient: .constant(Patient()), mapSearch: AdressAutoComplete(address: "ASd"))
//            .previewInterfaceOrientation(.landscapeLeft)
//            .previewDevice("iPad (9th generation)")
//    }
//}
