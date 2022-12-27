//
//  ExpiredOhipContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-11.
//

import SwiftUI

struct ExpiredOhipContentView: View {
    @Environment(\.presentationMode) var mode
    @Binding var isPresented: Bool
    @State var remaining = 10.0
    var body: some View {
        VStack {
            Text("Your Ontario health card has expired, please see the receptionist.").font(.largeTitle)
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Text("Done")
                }
                .buttonStyle(.bordered)
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

struct ExpiredOhipContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExpiredOhipContentView(isPresented: .constant(true))
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
    }
}
