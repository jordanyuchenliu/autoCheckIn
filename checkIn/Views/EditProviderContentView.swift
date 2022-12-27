//
//  EditProviderContentView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-20.
//

import SwiftUI

struct EditProviderContentView: View {
    @Environment(\.presentationMode) var mode
    @EnvironmentObject var viewModel: ViewModel
    var clinicID = UserDefaults.standard.string(forKey: "clinic_id") ?? ""
    @Binding var isPresented: Bool
    @State var remaining = 30.0
    @State var passedCheck = false
    @State var enteredID = ""
    @State var providers: [Provider] = []
    @State var loading = false
    
    var body: some View {
        VStack {
            if loading {
                LoadingView(loadingText: .constant("Loading physicians"))
            } else {
                if !passedCheck {
                    TextField("Clinic ID", text: $enteredID)
                        .textFieldStyle(OutlinedTextFieldStyle())
                    Button {
                        if enteredID == clinicID {
                            let handler = AWSHandler()
                            self.loading = true
                            DispatchQueue.global().async {
                                providers = handler.getProvider(completion: {
                                    self.loading = false
                                })
                                passedCheck = true
                            }

                        }
                    } label: {
                        Text("Ok")
                    }
                } else {
                    ScrollView {
                        Text("Update the doctors on shift")
                        ForEach($providers) { provider in
                            Toggle(isOn: provider.onShift) {
                                Text(provider.id)
                            }
                        }
                        Button {
                            var onShift: [String] = []
                            for provider in providers {
                                if provider.onShift {
                                    onShift.append(provider.id)
                                }
                            }
                            UserDefaults.standard.set(onShift, forKey: "providers")
                            isPresented = false
                        } label: {
                            Text("Update")
                        }
                    }
                }
            }


        }
        .padding()
        .onReceive(Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()) { _ in
            self.remaining -= 0.01
            if self.remaining <= 0 {
                self.mode.wrappedValue.dismiss()
            }
        }.onTapGesture {
            remaining = 30.0
        }

    }
    
}

//struct EditProviderContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProviderContentView()
//    }
//}
