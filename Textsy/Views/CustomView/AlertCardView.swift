//
//  AlertCardView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/21/25.
//


import SwiftUI

struct AlertCardView: View {
    let title: String
    let message: String
    let dismissAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)

            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Button(action: dismissAction) {
                Text("OK")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.fieldT))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#Preview("Alert Preview - Textsy Style") {
    ZStack {
        Color(.bgc)
            .ignoresSafeArea()

        AlertCardView(
            title: "Oops!",
            message: "Something went wrong while signing in. Please check your email and password.",
            dismissAction: {}
        )
    }
    .preferredColorScheme(.light)
}

