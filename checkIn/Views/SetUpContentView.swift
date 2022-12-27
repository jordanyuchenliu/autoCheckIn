//
//  SetUpContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-10-02.
//


// Pass in hashed key, stores id into userdefaults, reopens app. 
import SwiftUI
import AVFoundation

struct SetUpContentView: View {
    @State var clinicID = ""
    @State var shouldPromptReopenAlert = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(alignment: .center) {
            Text("Setup with the Unique Clinic Identifier").font(.largeTitle)
            TextField("Clinic ID", text: $clinicID)
                .autocorrectionDisabled()
                .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "magnifyingglass")))
        
            HStack {
                Spacer()
                Button {
                    UserDefaults.standard.set(clinicID, forKey: "clinic_id")
                    UserDefaults.standard.set([], forKey: "providers")
                    shouldPromptReopenAlert = true
                } label: {
                    Text("Connect")
                }
                .buttonStyle(.bordered)
            }.alert("Restarting the app", isPresented: $shouldPromptReopenAlert) {
                Button {
                    shouldPromptReopenAlert = false
                    exit(0)
                } label: {
                    Text("OK")
                }

            }
        }.padding()
    }
}

struct SetUpContentView_Previews: PreviewProvider {
    static var previews: some View {
        SetUpContentView()
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
    }
}
