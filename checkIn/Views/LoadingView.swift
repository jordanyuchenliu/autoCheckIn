//
//  LoadingView.swift
//  checkIn
//
//  Created by Alex Yeh on 2022-11-26.
//

import SwiftUI

struct LoadingView: View {
    
    @Binding var loadingText: String
    @State var isAnimated = false
    
    var body: some View {
        VStack {
            HStack {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)
                    .scaleEffect(isAnimated ? 1.0 :0.5)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever())
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)
                    .scaleEffect(isAnimated ? 1.0 :0.5)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3))
                Circle()
                    .fill(Color.gray)
                    .frame(width: 20, height: 20)
                    .scaleEffect(isAnimated ? 1.0 :0.5)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6))
            }
            Text(loadingText)
        }

        .onAppear {
            self.isAnimated = true
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(loadingText: .constant("Loading"))
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad (9th generation)")
    }
}
