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
    @StateObject private var authVM = AuthViewModel.shared

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
                        TextField("Email Address", text: $authVM.email)
                            .padding()
                            .font(.title3.bold())
                            .frame(height: geometry.size.height * 0.075)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)

                        SecureField("Password", text: $authVM.password)
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
                        Task{
                            await authVM.login()
                        }
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
                        Button("Forgot password?"){
                            AppRouter.shared.goToForgotPassword()
                        }
                            .foregroundColor(.gray)

                        Spacer()

                        Button("Sign Up") {
                            AppRouter.shared.goToSignup() //Navigate to signUp page
                        }
                        .foregroundColor(.sdc)
                    }
                    .padding(.horizontal, geometry.size.width * 0.1)
                    .font(.subheadline)

                    Spacer()
                }
                .padding(.vertical)
                
                if authVM.isLoading {
                    LoadingCircleView()
                }
                if authVM.showAlert,let msg = authVM.alertMessage {
                    AlertCardView(title:"Notice" , message:msg){authVM.showAlert = false}
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.light)
}
