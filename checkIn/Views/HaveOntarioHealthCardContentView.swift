//
//  HaveOntarioHealthCardContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-10.
//

import AVFoundation
import SwiftUI

struct HaveOntarioHealthCardContentView: View {
    init() {
        AVCaptureDevice.requestAccess(for: .video) { _ in
        }
    }
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State var yesPressed = false
    @State var noPressed = false
    @State var patient = Patient()
    @State var scanCompleted = false
    @State var selectProviderId = false
    @State var loading = false
    @Environment(\.presentationMode) var presentationMode
    @State var loadingMessage = ""
    var body: some View {
        if loading {
            LoadingView(loadingText: $loadingMessage)
        } else {
            HStack {
                Spacer()
                Button {
                    selectProviderId = true
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: UIScreen.screenWidth/40, height: UIScreen.screenWidth/40)
                }
                .popover(isPresented: $selectProviderId) {
                    EditProviderContentView(isPresented: $selectProviderId)
                        .frame(width: UIScreen.screenWidth/3, height: UIScreen.screenHeight/3)
                }
                Spacer()
            }
            Spacer()
            VStack {
                Text("Do you have a green Ontario Health Card with you?").font(.largeTitle)
                Image("healthCard")
                HStack {
                    Spacer()
                    Button {
                        UIView.setAnimationsEnabled(false)
                        yesPressed = true
                    } label: {
                        Text("Yes").font(.largeTitle)
                    }
                    .fullScreenCover(isPresented: $yesPressed) {
                        CardScannerContentView(isPresent: $yesPressed, patient: $patient)
                            .onDisappear {
                                locationManager.requestLocation()
                                if patient.ohipID == "" {
                                    return
                                }
                                if patient.ohipID == "XXXX" {
                                    patient.status = .invalid
                                    scanCompleted = true
                                    return
                                }
                                if patient.healthCardExpired() {
                                    patient.status = .expOhip
                                    scanCompleted = true
                                    return
                                } else {
                                    patient.processScannedResults()
                                    let handler = AWSHandler()
                                    loadingMessage = "Finding your information"
                                    loading = true
                                    DispatchQueue.global().async {
                                        let result = handler.getDemo(hin: patient.hin) {
                                            loading = false
                                        }
                                        
                                        DispatchQueue.main.async {
                                            if result?.count ?? 0 == 15 {
                                                patient.dic = result!
                                                patient.processSearchResults()
                                                patient.status = .oldPatient
                                            } else {
                                                patient.status = .newPatient
                                            }
                                            scanCompleted = true
                                        }

                                    }
                                    
                                }
                            }
                    }.fullScreenCover(isPresented: $scanCompleted) {
                        if patient.status == .expOhip {
                            ExpiredOhipContentView(isPresented: $scanCompleted)
                                .onDisappear {
                                    patient = Patient()
                                }
                        } else {
                            if patient.status != .undetermined {
                                if patient.status == .oldPatient {
                                    EnterContactInfoContentView(newPatient: false, isPresented: $scanCompleted, patient: $patient)
                                        .environmentObject(locationManager)
                                        .onDisappear {
                                            patient = Patient()
                                        }
                                }
                                if patient.status == .newPatient {
                                    EnterSexContentView(newPatient: true, isPresented: $scanCompleted, patient: $patient)
                                       .onDisappear {
                                           patient = Patient()
                                       }
                                }
                                if patient.status == .invalid {
                                    NoOntarioHealthCardContentView(errorType: .scanningIssue, isPresented: $scanCompleted)
                                        .onDisappear {
                                            patient = Patient()
                                        }
                                }
                            }
                        }
                    }
                    Spacer()
                    Button {
                        UIView.setAnimationsEnabled(false)
                        noPressed = true
                    } label: {
                        Text("No").font(.largeTitle)
                    }
                    .fullScreenCover(isPresented: $noPressed) {
                        NoOntarioHealthCardContentView(errorType: .noOhip, isPresented: $noPressed)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
            

        
    }
}

struct HaveOntarioHealthCardContentView_Previews: PreviewProvider {
    static var previews: some View {
        HaveOntarioHealthCardContentView()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
    }
}
