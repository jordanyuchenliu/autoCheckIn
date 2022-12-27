//
//  checkInApp.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-01.
//

import SwiftUI

@main
struct checkInApp: App {
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var viewModel = ViewModel()
    var body: some Scene {
        WindowGroup {
//            EnterContactInfoContentView(newPatient: false, isPresented: .constant(true), patient: .constant(Patient()))
//                .environmentObject(locationManager)
//                .onAppear {
//                    locationManager.requestWhenInUseAuthorization()
//                }
//            EnterReasonForVisitContentView()
//            EnterAddressContentView()
//                .environmentObject(locationManager)
//
//                .onAppear {
//                    locationManager.requestWhenInUseAuthorization()
//                }
            if UserDefaults.standard.string(forKey: "clinic_id") != nil {
                HaveOntarioHealthCardContentView()
                    .environmentObject(locationManager)
                    .environmentObject(viewModel)
                    .preferredColorScheme(.light)
                    .onAppear {
                        locationManager.requestWhenInUseAuthorization()
                    }
            } else {
                SetUpContentView()
                    .preferredColorScheme(.light)
            }

        }
    }
}

struct Previews_checkInApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
