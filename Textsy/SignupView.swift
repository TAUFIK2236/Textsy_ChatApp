import SwiftUI

struct SignupView: View {

    @StateObject private var authVM = AuthViewModel.shared
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.bgc)
                    .ignoresSafeArea()

                VStack(spacing: geometry.size.height * 0.03) {
                    Spacer().frame(height: geometry.size.width * 0.15)

                    // Logo
                    Image("logo2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width * 0.3,
                               height: geometry.size.width * 0.3)
                        .shadow(color:.sdc,radius: 50)

                    // Title
                    Text("Create Account")
                        .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                        .foregroundColor(.white)

                    // Input Fields
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


                        SecureField("Confirm Password", text: $authVM.confirmPassword)
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
                        Task{  await authVM.signup()
}                        // TODO: Handle sign up logic
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

                    // Switch to login
                    HStack {
                        Text("Have an account?")
                            .foregroundColor(.gray)

                        Button("Log In") {
                            AppRouter.shared.goToLogin()
                            // TODO: Navigate to LoginView
                        }
                        .foregroundColor(.sdc)
                    }
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
#Preview("Signup View - Light Mode") {
    SignupView()
        .preferredColorScheme(.dark)
}

