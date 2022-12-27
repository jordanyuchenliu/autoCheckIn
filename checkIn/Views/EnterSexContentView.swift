//
//  SelectSexContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-29.
//

import SwiftUI

struct EnterSexContentView: View {
    var newPatient: Bool
    @Binding var isPresented: Bool
    @Binding var patient: Patient
    @State var presentContactScreen = false
    @State var remaining = 30.0
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
            Text("Welcome! " + patient.firstName + " " + patient.lastName)
                .font(.largeTitle)
                .bold()
            Text("Please Select Your Biological Sex")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    remaining = 9999999
                    patient.sex = .male
                    presentContactScreen = true
                }) {
                    VStack {
//                        Image("male")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
                        Text("Male")
                            .font(.system(size: 30))
                            .bold()
                    }
                        .frame(width: UIScreen.screenWidth/4, height: UIScreen.screenWidth/4)
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.black, lineWidth: 10)
                        )
                }
                .background(Color.white) // If you have this
                .cornerRadius(25)
                Spacer()
                Button(action: {
                    remaining = 9999999
                    patient.sex = .female
                    presentContactScreen = true
                }) {
                    VStack {
//                        Image("female")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)

                        Text("Female")
                            .font(.system(size: 30))
                            .bold()
                    }
                        .frame(width: UIScreen.screenWidth/4, height: UIScreen.screenWidth/4)
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.black, lineWidth: 10)
                        )
                }
                .background(Color.white) // If you have this
                .cornerRadius(25)
                Spacer()

            }
            Spacer()
        }
        .fullScreenCover(isPresented: $presentContactScreen) {
            EnterContactInfoContentView(newPatient: newPatient, isPresented: $presentContactScreen, patient: $patient)
                .onDisappear {
                    isPresented = false
                }
        }
//        .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
//            self.remaining -= 0.01
//            if self.remaining <= 0 {
//                self.mode.wrappedValue.dismiss()
//            }
//        }
//        .onTapGesture {
//            remaining = 30.0
//        }
        
        
    }
    
}

//struct EnterSexContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        EnterSexContentView()
//            .previewInterfaceOrientation(.landscapeLeft)
//            .previewDevice("iPad (9th generation)")
//    }
//}
