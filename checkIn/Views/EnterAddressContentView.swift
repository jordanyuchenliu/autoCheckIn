//
//  EnterAddressContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-29.
//

import CoreLocation
import SwiftUI
import MapKit

struct EnterAddressContentView: View {

    var newPatient: Bool
    @StateObject var mapSearch: AddressAutoComplete
    @FocusState var isFocused: Bool
    @State var presentPopover = false
    @EnvironmentObject var locationManager: LocationManager
    @Binding var isPresented: Bool
    @Binding var patient: Patient
    @State var presentReasonScreen = false
    @State var invalidAddress = false
    
    @State var remaining = 30.0
    @State var popoverRemaining = 3
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "arrow.backward")
                        .resizable()
                        .frame(width: UIScreen.screenWidth/25, height: UIScreen.screenWidth/25)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding()
            
            Text(newPatient ? "Please Enter Your Address" : "Please Update Your Address If Needed")
                .font(.largeTitle)
                .bold()
            Spacer()
            HStack {
                Text("Unit #").font(.title)
                TextField("Optional", text: $patient.unitNumber)
                    .textFieldStyle(OutlinedTextFieldStyle())
                    .frame(width: UIScreen.screenWidth/6)
                Spacer()
                Text("Address:").font(.title)
                VStack(alignment: .leading) {
                    Section {
                        TextField("Street Address", text: $mapSearch.searchTerm)
                            .textFieldStyle(OutlinedTextFieldStyle())
                            .modifier(TextFieldClearButton(text: $mapSearch.searchTerm))
                            .onChange(of: mapSearch.searchTerm) { value in
                                self.popoverRemaining = 3
                                mapSearch.deviceLocation = locationManager.location ?? CLLocationCoordinate2D(latitude: 43.6, longitude: -79.3)
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
                                                Button {
                                                    reverseGeo(location: location)
                                                    presentPopover = false
                                                } label: {
                                                    VStack(alignment: .leading) {
                                                        Text("-----------------------------------------")
                                                            .foregroundColor(.black)
                                                        HStack(alignment: .center) {
                                                            Image(systemName: "mappin.circle.fill")
                                                                .foregroundColor(.gray)
                                                            VStack(alignment: .leading) {
                                                                Text(location.title)
                                                                    .foregroundColor(Color.black)
                                                                    .font(.title2)
                                                                Text(location.subtitle)
                                                                    .font(.system(.caption))
                                                                    .foregroundColor(Color.black)
                                                            }
                                                        }
                                                    }
                                                    .frame(maxWidth: .infinity)
                                                }
                                                
                                            }
                                        }.frame(maxWidth: .infinity)
                                    }.frame(width: UIScreen.screenWidth/3, height: UIScreen.screenHeight/3)
                                        .padding()
                                }
                            }
                    }
                }.padding()
            }
            HStack {
                Spacer()
                Button(action: {
                    presentPopover = false
                    if patient.address != "" {
                        remaining = 9999999
                        presentReasonScreen = true
                    } else {
                        if patient.address == "" && mapSearch.searchTerm != "" {
                            remaining = 9999999
                            patient.address = mapSearch.searchTerm
                            presentReasonScreen = true
                        } else {
                            invalidAddress = true
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 15))
                        .bold()
                        .frame(width: UIScreen.screenWidth/10, height: UIScreen.screenWidth/20)
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.black, lineWidth: 10)
                        )
                }
                .background(Color.gray) // If you have this
                .cornerRadius(25)
            }
            Spacer()
        }
        .padding()
        .alert(isPresented: $invalidAddress) {
            Alert(title: Text("Please enter a valid address."))
        }
//        .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
//            self.remaining -= 0.01
//            if self.remaining <= 0 {
//                print("leaving")
//                self.mode.wrappedValue.dismiss()
//            }
//        }
//        .onTapGesture {
//            remaining = 30.0
//        }
        .fullScreenCover(isPresented: $presentReasonScreen, content: {
            EnterReasonForVisitContentView(patient: $patient, isPresented: $presentReasonScreen, newPatient: newPatient)
                .onDisappear {
                    isPresented = false
                }
        })
    }
    
    func reverseGeo(location: MKLocalSearchCompletion) {
        patient.address = location.title
        let subtitleArr = location.subtitle.components(separatedBy: ", ")
        patient.city = subtitleArr[0]
        patient.state = subtitleArr[1]
        patient.country = subtitleArr[2]
        mapSearch.searchTerm = patient.address + ", " + subtitleArr[0] + ", " + subtitleArr[1] + ", " + subtitleArr[2]
        let searchRequest = MKLocalSearch.Request(completion: location)
        let location = locationManager.location ?? CLLocationCoordinate2D(latitude: 43.6, longitude: -79.3)
        searchRequest.region = MKCoordinateRegion(center: location, latitudinalMeters: 100000, longitudinalMeters: 100000)
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

struct EnterAddressContentView_Previews: PreviewProvider {
    static var previews: some View {
        EnterAddressContentView(newPatient: false, mapSearch: AddressAutoComplete(address: "", location: CLLocationCoordinate2D(latitude: 43.6, longitude: -79.3)), isPresented: .constant(true), patient: .constant(Patient()))
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
    }
}
