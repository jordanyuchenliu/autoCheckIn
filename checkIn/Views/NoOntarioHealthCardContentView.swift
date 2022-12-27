//
//  NoOntarioHealthCardContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-10.
//

import SwiftUI

struct NoOntarioHealthCardContentView: View {
    var errorType: SeeReceptionistCase
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var viewModel: ViewModel
    @Binding var isPresented: Bool
    @State var remaining = 10.0
    var body: some View {
        VStack {
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
                switch errorType {
                case .bookingIssue:
                    Text("We are having server issues with our appointment booking system, please see the receptionist.").font(.largeTitle)
                case .noOhip:
                    Text("Since you don't have a green Ontario Health Card, please see the receptionist.").font(.largeTitle)
                case .scanningIssue:
                    Text("We are having problems scanning your health card, please see the receptionist to be registered.").font(.largeTitle)
                }
                
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Text("Ok").font(.largeTitle)
                    }
                    Spacer()
                }
            }
            Spacer()

        }
        .padding()
        .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
            self.remaining -= 0.01
            if self.remaining <= 0 {
                self.mode.wrappedValue.dismiss()
            }
        }

        
        
    }
}

enum SeeReceptionistCase {
    case bookingIssue
    case noOhip
    case scanningIssue
}

//struct NoOntarioHealthCardContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoOntarioHealthCardContentView(viewModel: ViewModel(hashKey: "ASD"), isPresented: .constant(true))
//            .previewInterfaceOrientation(.landscapeLeft)
//            .previewDevice("iPad (9th generation)")
//    }
//}
