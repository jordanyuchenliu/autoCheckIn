//
//  CardScannerContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-10.
//

import SwiftUI

struct CardScannerContentView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var viewModel: ViewModel
    @Binding var isPresent: Bool
    @Binding var patient: Patient
    @State var remaining = 30.0
    var body: some View {
        VStack {
            HStack {
                Button {
                    isPresent = false
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundColor(.red)
                        .frame(width: UIScreen.screenWidth/40, height: UIScreen.screenWidth/40)
                }
                Spacer()
            }
            VStack {
                ZStack(alignment: .center) {
                    CardScanner(patient: patient)
                    VStack {
                        Text("Center your healthcard")
                        Text("+")
                    }
                }.foregroundColor(.white)
            }
        }
        .padding()
//        .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
//            self.remaining -= 0.01
//            if self.remaining <= 0 {
////                self.patient.status =
//                self.mode.wrappedValue.dismiss()
//            }
//        }
//        
    }
    

}

//struct CardScannerContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardScannerContentView()
//    }
//}
