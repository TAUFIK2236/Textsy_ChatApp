import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var router: AuthRouter
    @EnvironmentObject var appRouter: AppRouter



    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color(.bgc)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        Spacer().frame(height: geometry.size.width * 0.15)

                        // Logo
                        Image("logo2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width * 0.3,
                                   height: geometry.size.width * 0.3)
                            .shadow(color: .sdc, radius: 50)

                        // Title
                        Text("Create Account")
                            .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                            .foregroundColor(.white)

                        // Input Fields
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

                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .font(.title3.bold())
                                .frame(height: geometry.size.height * 0.075)
                                .background(Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)

                        // Sign Up Button
                        Button(action: {
                            if password != confirmPassword {
                                viewModel.errorMessage = "Password do not match"
                                return
                            }
                            Task {
                                await viewModel.signup(email: email, password: password)
                                //if sign-up succeed, go to profile edit page
                                if viewModel.errorMessage.isEmpty {
                                    session.isProfileLoaded = true
                                    appRouter.goToProfileEdit(isFromSignUp: true)
                                }
                            }
                        }) {
                            Text("Sign Up")
                                .font(.title3.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.075)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)

                        // Switch to Login
                        HStack {
                            Text("Have an account?")
                                .foregroundColor(.gray)

                            Button("Log In") {
                                router.goToLogin()
                                // Navigation placeholder
                            }
                            .foregroundColor(.sdc)
                        }
                        .font(.subheadline)

                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                }
                if viewModel.isLoading {
                    LoadingCircleView()
                }


            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("Signup View - Light Mode") {
    SignupView()
        .preferredColorScheme(.dark)
}

