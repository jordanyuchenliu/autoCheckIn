//
//  OntarioBookingConfirmationContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-11.
//

import SwiftUI

struct OntarioBookingConfirmationContentView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.presentationMode) var mode
    @Binding var isPresented: Bool
    @State var remaining = 10.0
    var body: some View {
        
        VStack {
            Text("Booking confirmed, please wait for your turn.").font(.largeTitle)
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Text("Done")
                }.buttonStyle(.bordered)

            }
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

struct OntarioBookingConfirmationContentView_Previews: PreviewProvider {
    static var previews: some View {
        OntarioBookingConfirmationContentView(isPresented: .constant(true))
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
    }
}
