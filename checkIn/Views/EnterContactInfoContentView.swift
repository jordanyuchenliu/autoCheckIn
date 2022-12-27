//
//  EnterContactInfoContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-29.
//

import SwiftUI
import CoreLocation

struct EnterContactInfoContentView: View {
    
    var newPatient: Bool
    @Binding var isPresented: Bool
    @Binding var patient: Patient
    @EnvironmentObject var viewModel: ViewModel
    @EnvironmentObject var locationManager: LocationManager
    @State var presentAddressView = false
    @State var incompleteFields = false
    
    @State var remaining = 30.0
    @Environment(\.presentationMode) var mode
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
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
            Text(newPatient ? "Please Enter Your Contact Information" : "Please Update Your Contact Information If Needed")
                .font(.largeTitle)
                .bold()
            Spacer()
            HStack {
                Text("Phone Number: ")
                TextField(text: $patient.primaryPhone) {
                    HStack {
                        Text("Enter your phone number: ")
                    }
                }
                .background(.bar)
                .textFieldStyle(OutlinedTextFieldStyle())
                .frame(width: UIScreen.screenWidth/2)
                .foregroundColor(.black)
                .keyboardType(.decimalPad)
                .disableAutocorrection(true)
            }
            Spacer()
            HStack {
                Text("Emergency Contact: ")
                TextField(text: $patient.secondaryPhone) {
                    HStack {
                        Text("Enter a emergency contact number: ")
                    }
                }
                .background(.bar)
                .textFieldStyle(OutlinedTextFieldStyle())
                .frame(width: UIScreen.screenWidth/2)
                .foregroundColor(.black)
                .keyboardType(.decimalPad)
                .disableAutocorrection(true)
            }
            Spacer()
            HStack {
                Text("Email(Optional): ")
                TextField(text: $patient.email) {
                    HStack {
                        Text("Enter your email: ")
                    }
                }
                .background(.bar)
                .textFieldStyle(OutlinedTextFieldStyle())
                .frame(width: UIScreen.screenWidth/2)
                .foregroundColor(.black)
                .keyboardType(.decimalPad)
                .disableAutocorrection(true)
            }
            HStack {
                Spacer()
                Button(action: {
                    if patient.primaryPhone != "" && patient.secondaryPhone != "" {
                        remaining = 9999999
                        presentAddressView = true
                    } else {
                        incompleteFields = true
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
                .fullScreenCover(isPresented: $presentAddressView, content: {
                    EnterAddressContentView(newPatient: newPatient, mapSearch: AddressAutoComplete(address: patient.address, location: locationManager.location ?? CLLocationCoordinate2D(latitude: 43.6, longitude: -79.3)), isPresented: $presentAddressView, patient: $patient)
                        .onDisappear {
                            isPresented = false
                        }
                })
            }
        }
        .alert(isPresented: $incompleteFields) {
            Alert(title: Text("Phone number and emergency contact are required fields."))
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
        Spacer()
        
    }
}

struct EnterContactInfoContentView_Previews: PreviewProvider {
    static var previews: some View {
        EnterContactInfoContentView(newPatient: false, isPresented: .constant(true), patient: .constant(Patient()))
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
        

    }
}
