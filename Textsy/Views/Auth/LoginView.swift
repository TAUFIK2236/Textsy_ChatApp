import SwiftUI

struct LoginView: View {
   // @State private var email = "mstanikatabasum786@gmail.com"
    @State private var email = "taufikalislam@gmail.com"
    @State private var password = "13134646"
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var router: AuthRouter
    @EnvironmentObject var appRouter: AppRouter


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Color
                Color(.bgc)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: geometry.size.height * 0.03) {
                        // Spacer for top space
                        Spacer().frame(height: geometry.size.width * 0.2)

                        // Logo
                        Image("logo2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width * 0.3,
                                   height: geometry.size.width * 0.3)
                            .shadow(color: .sdc, radius: 50)

                        // App Title
                        Text("Textsy")
                            .font(.system(size: geometry.size.width * 0.1, weight: .bold))
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
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)

                        // Log In Button
                        Button(action: {
                            Task {
                                await viewModel.login(email: email, password: password)

                                if viewModel.errorMessage.isEmpty {
                                    await session.loadUserProfileFromFirestore()

                                    // 👶 Check if profile is filled
                                    if session.hasCompletedProfile() {
                                        session.isProfileLoaded = true
                                        appRouter.goToHome()
                                    } else {
                                        session.isProfileLoaded = true
                                        appRouter.goToProfileEdit(isFromSignUp: true)
                                    }
                                }
                            }
                        }) {
                            Text("Log In")
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
                            Button("Forgot password?") {
                                router.goToForgot()
                                // navigation placeholder
                            }
                            .foregroundColor(.gray)
                            .font(.system(size: geometry.size.width * 0.035, weight: .bold))

                            Spacer()

                            Button("Sign Up") {
                                router.goToSignup()
                                // navigation placeholder
                            }
                            .font(.system(size: geometry.size.width * 0.035, weight: .bold))
                            .foregroundColor(.sdc)
                        }
                        .padding(.horizontal, geometry.size.width * 0.1)
                        .font(.subheadline)

                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading {
                    LoadingCircleView() // your original spinner
                }
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

            }//Zstack
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.light)
}



