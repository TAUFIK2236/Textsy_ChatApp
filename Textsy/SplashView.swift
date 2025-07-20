//
//  SplashView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import SwiftUI

struct SplashView: View {
    @State private var animate = false
    @State private var showMainApp = false

    var body: some View {
        ZStack {
            Color(.bgc)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("logo2") // Your app icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: animate ? 120 : 0, height: animate ? 120 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(radius: 20)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.6)
                    .animation(.easeOut(duration: 1), value: animate)

                Text("Textsy")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 40)
                    .animation(.easeOut(duration: 1.2).delay(0.3), value: animate)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                animate = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showMainApp = true
                }
            }
        }

    }
}
#Preview("SplashView - Dark") {
    SplashView()
        .preferredColorScheme(.light)
}
