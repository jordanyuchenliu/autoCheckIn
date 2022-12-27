//
//  EnterReasonForVisitContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-29.
//

import SwiftUI

struct EnterReasonForVisitContentView: View {
    @State var reasonForVisit = ""
    @Binding var patient: Patient
    @Binding var isPresented: Bool
    var newPatient: Bool
    @State var loading = false
    @State var loadingText = ""
    @State var invalidReasonForVisit = false
    @State var presentConfirmationScreen = false
    @State var errorOccurred = false
    @FocusState var editing: Bool
    
    @State var remaining = 30.0
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        if loading {
            LoadingView(loadingText: $loadingText)
        } else {
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
                Text("Please Enter Your Reason For Visit")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                HStack {
                    TextField(text: $reasonForVisit) {
                        Text("Reason for visit in 20 characters")
                    }
                    .onChange(of: reasonForVisit, perform: { newValue in
                        if newValue.count > 20 {
                            reasonForVisit = String(newValue.prefix(20))
                        }

                    })
                    .foregroundColor(reasonForVisit.count >= 20 ? .red : .black)
                    .background(.bar)
                    .textFieldStyle(OutlinedTextFieldStyle())
                    .frame(width: UIScreen.screenWidth/2)
                    .foregroundColor(.black)
                    .keyboardType(.decimalPad)
                    .disableAutocorrection(true)
                    .focused($editing)
                    
                    Text("Characters left: " + String(20 - reasonForVisit.count))
                        .foregroundColor(reasonForVisit.count >= 20 ? .red : .black)

                }

                HStack {
                    Spacer()
                    Button(action: {
                        editing = false
                        if reasonForVisit != "" {
                            remaining = 9999999
                            let handler = AWSHandler()
                            let info = patient.generateDict()
                            loadingText = "Uploading your information"
                            loading = true
                            DispatchQueue.global().async {
                                var result: Dictionary<String, AnyObject> = [:]
                                if newPatient {
                                    result = handler.postDemo(newDemo: info as Dictionary<String, AnyObject>) ?? [:]
                                } else {
                                    result = handler.putDemo(updatedDemo: info as Dictionary<String, AnyObject>) ?? [:]
                                }


                                if result["message"] as? String == "SUCCESS" {
                                    loadingText = "Booking an appointment for you"
                                    var provider = UserDefaults.standard.array(forKey: "providers") ?? [".default"]
                                    if provider.count == 0 {
                                        provider = [".default"]
                                    }
                                    let appointmentResult = handler.addAppointment(firstName: patient.firstName,
                                                                                   lastName: patient.lastName,
                                                                                   hin: patient.hin,
                                                                                   physicianId: provider[0] as! String,
                                                                                   appointmentNote: reasonForVisit,
                                                                                   completion: { loading = false })
                                    print("here")
                                    DispatchQueue.main.async {
                                        if appointmentResult {
                                            presentConfirmationScreen = true
                                        } else {
                                            errorOccurred = true
                                        }
                                    }
                                } else {
                                    loading = false
                                    errorOccurred = true
                                }
                            }
                        } else {
                            invalidReasonForVisit = true
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
            }.alert(isPresented: $invalidReasonForVisit) {
                Alert(title: Text("Please enter your reason for visit"))
            }
//            .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
//                self.remaining -= 0.01
//                if self.remaining <= 0 {
//                    print("leaving")
//                    self.mode.wrappedValue.dismiss()
//                }
//            }
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
    }
    
}

//struct EnterReasonForVisitContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        EnterReasonForVisitContentView()
//    }
//}
