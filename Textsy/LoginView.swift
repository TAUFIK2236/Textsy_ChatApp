//
//  LoginView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/17/25.
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.bgc)
                    .ignoresSafeArea()

                VStack(spacing: geometry.size.height * 0.03) {
                    Spacer().frame(height:geometry.size.width * 0.2 )

                    // Logo
                    Image("logo2")
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width * 0.3,height:geometry.size.width * 0.3 )
                        .foregroundColor(.blue)
                        .shadow(color:.sdc,radius: 50)

                    // Title
                    Text("Textsy")
                        .font(.system(size: geometry.size.width * 0.1, weight: .bold))
                        .foregroundColor(.white)

                    // Fields
                    VStack(spacing: geometry.size.height * 0.02) {
                        TextField("Email Address", text: $email)
                            .padding()
                            .font(.title3.bold())
                            .frame(height: geometry.size.height * 0.075)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        SecureField("Password", text: $password)
                            .padding()
                            .font(.title3.bold())
                            .frame(height: geometry.size.height * 0.075)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)

                    // Login Button
                    Button(action: {
                        // Handle login
                    }) {
                        Text("Log In")
                            .font(.headline)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.075)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)

                    // Forgot + Sign Up
                    HStack {
                        Button("Forgot password?"){}
                            .foregroundColor(.gray)

                        Spacer()

                        Button("Sign Up") {
                            // Handle sign up
                        }
                        .foregroundColor(.sdc)
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .font(.subheadline)

                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

#Preview("Home View - Light Mode") {
    LoginView()
        .preferredColorScheme(.light)
}
