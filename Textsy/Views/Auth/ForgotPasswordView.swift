import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @EnvironmentObject var router: AuthRouter


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
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
                        Text("Reset Password")
                            .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                            .foregroundColor(.white)

                        // Instructions
                        Text("Enter your email address and we’ll send you a link to reset your password.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, geometry.size.width * 0.1)
                            .font(.subheadline)

                        // Email Field
                        TextField("Email Address", text: $email)
                            .padding()
                            .font(.title3.bold())
                            .frame(height: geometry.size.height * 0.075)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .padding(.horizontal, geometry.size.width * 0.1)

                        // Reset Button
                        Button(action: {
                            Task{
                                await viewModel.resetPassword(email: email)
                            }
                        }) {
                            Text("Send Reset Link")
                                .font(.title3.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.075)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)

                        Spacer()

                        // Log In Button
                        Button(action: {
                            router.goToLogin()
                            // Navigation placeholder
                        }) {
                            Text("Remember your password? Log In")
                                .foregroundColor(.sdc)
                                .font(.subheadline)
                        }
                        .padding(.bottom, geometry.size.height * 0.03)
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading {
                    LoadingCircleView()
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .padding(.horizontal)
                }

            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview("Forgot Password View - Light Mode") {
    ForgotPasswordView()
        .preferredColorScheme(.dark)
}
