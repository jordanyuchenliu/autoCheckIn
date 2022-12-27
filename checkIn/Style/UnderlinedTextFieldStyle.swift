//
//  RoundedTextFieldStyle.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-08.
//

import SwiftUI

struct UnderlinedTextFieldStyle: TextFieldStyle {
    @State var icon: Image?
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            if icon != nil {
                icon
                    .foregroundColor(Color(UIColor.systemGray4))
            }
            configuration
        }
            .padding(.vertical, 8)
            .background(
                VStack {
                    Spacer()
                    Color(UIColor.systemGray4)
                        .frame(height: 2)
                }
            )
    }
}

struct OutlinedTextFieldStyle: TextFieldStyle {
    
    @State var icon: Image?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            if icon != nil {
                icon
                    .foregroundColor(Color(UIColor.systemGray4))
            }
            configuration
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(UIColor.systemGray4), lineWidth: 2)
        }
    }
}
