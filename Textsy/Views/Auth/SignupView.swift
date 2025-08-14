//import SwiftUI
//
//struct SignupView: View {
//    @State private var email = ""
//    @State private var password = ""
//    @State private var confirmPassword = ""
//
//    @StateObject private var viewModel = AuthViewModel()
//    @EnvironmentObject var session: UserSession
//    @EnvironmentObject var router: AuthRouter
//    @EnvironmentObject var appRouter: AppRouter
//
//
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                // Background color
//                Color(.bgc)
//                    .ignoresSafeArea()
//
//                ScrollView {
//                    VStack(spacing: geometry.size.height * 0.03) {
//                        Spacer().frame(height: geometry.size.width * 0.15)
//
//                        // Logo
//                        Image("logo2")
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: geometry.size.width * 0.3,
//                                   height: geometry.size.width * 0.3)
//                            .shadow(color: .sdc, radius: 50)
//
//                        // Title
//                        Text("Create Account")
//                            .font(.system(size: geometry.size.width * 0.08, weight: .bold))
//                            .foregroundColor(.white)
//
//                        // Input Fields
//                        VStack(spacing: geometry.size.height * 0.02) {
//                            TextField("Email Address", text: $email)
//                                .padding()
//                                .font(.title3.bold())
//                                .frame(height: geometry.size.height * 0.075)
//                                .background(Color.gray)
//                                .cornerRadius(10)
//                                .foregroundColor(.white)
//
//                            SecureField("Password", text: $password)
//                                .padding()
//                                .font(.title3.bold())
//                                .frame(height: geometry.size.height * 0.075)
//                                .background(Color.gray)
//                                .cornerRadius(10)
//                                .foregroundColor(.white)
//
//                            SecureField("Confirm Password", text: $confirmPassword)
//                                .padding()
//                                .font(.title3.bold())
//                                .frame(height: geometry.size.height * 0.075)
//                                .background(Color.gray)
//                                .cornerRadius(10)
//                                .foregroundColor(.white)
//                        }
//                        .padding(.horizontal, geometry.size.width * 0.1)
//
//                        // Sign Up Button
//                        Button(action: {
//                            if password != confirmPassword {
//                                viewModel.errorMessage = "Password do not match"
//                                return
//                            }
//                            Task {
//                                await viewModel.signup(email: email, password: password)
//                                //if sign-up succeed, go to profile edit page
//                                if viewModel.errorMessage.isEmpty {
//                                    session.isProfileLoaded = true
//                                    appRouter.goToProfileEdit(isFromSignUp: true)
//                                }
//                            }
//                        }) {
//                            Text("Sign Up")
//                                .font(.title3.bold())
//                                .frame(maxWidth: .infinity)
//                                .frame(height: geometry.size.height * 0.075)
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(20)
//                        }
//                        .padding(.horizontal, geometry.size.width * 0.1)
//
//                        // Switch to Login
//                        HStack {
//                            Text("Have an account?")
//                                .foregroundColor(.gray)
//
//                            Button("Log In") {
//                                router.goToLogin()
//                                // Navigation placeholder
//                            }
//                            .foregroundColor(.sdc)
//                        }
//                        .font(.subheadline)
//
//                        Spacer()
//                    }
//                    .padding(.vertical)
//                }
//                
//                if !viewModel.errorMessage.isEmpty {
//                    AlertCardView(
//                        title: "Oops!",
//                        message: viewModel.errorMessage,
//                        dismissAction: {
//                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
//                                viewModel.errorMessage = ""
//                            }
//                        }
//                    )
//                    .padding(.top, 20)
//                    .zIndex(1) // keep it on top of content
//                    // parent drives insertion/removal animation, matching the card's transition
//                    .animation(.spring(response: 0.35, dampingFraction: 0.85),
//                               value: viewModel.errorMessage.isEmpty)
//                }
//                if viewModel.isLoading {
//                    LoadingCircleView()
//                }
//
//
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
//
//#Preview("Signup View - Light Mode") {
//    SignupView()
//        .preferredColorScheme(.dark)
//}
//

import SwiftUI

struct SignupView: View {
    //  user typing states
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // view models / shared app state
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var router: AuthRouter
    @EnvironmentObject var appRouter: AppRouter

    var body: some View {
        GeometryReader { geometry in
            //  read screen width/height once
            let w = geometry.size.width
            let h = geometry.size.height

            //  NEW: keep the form not-too-wide on iPads & big phones
            //         (max 560pt feels like native forms)
            let formWidth = min(w * 0.9, 560)

            // 🪄 NEW: field height stays comfy on tiny/huge screens
            //         never smaller than 44 (Apple min), never bigger than 64
            let fieldHeight = max(44, min(h * 0.075, 64))

            ZStack {
                // 🎨 background
                Color(.bgc)
                    .ignoresSafeArea()

                // scroll so layout works in landscape + with keyboard
                ScrollView {
                    VStack(spacing: h * 0.03) {
                        // 🌬️ top breathing space (use width so it scales in landscape too)
                        Spacer().frame(height: w * 0.15)

                        //  logo (kept same look, just follows width)
                        Image("logo2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: w * 0.3, height: w * 0.3)
                            .shadow(color: .sdc, radius: 50)

                        //  title
                        Text("Create Account")
                            .font(.system(size: w * 0.08, weight: .bold))
                            .foregroundColor(.white)

                        //  inputs — wrapped in a centered, max‑width box
                        VStack(spacing: h * 0.02) {
                            // email
                            TextField("Email Address", text: $email)
                                .padding()
                                .font(.title3.bold())
                                .frame(height: fieldHeight)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .textInputAutocapitalization(.never) // keep emails lowercase
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)

                            //  password
                            SecureField("Password", text: $password)
                                .padding()
                                .font(.title3.bold())
                                .frame(height: fieldHeight)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .textContentType(.newPassword)

                            //  confirm password
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .font(.title3.bold())
                                .frame(height: fieldHeight)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray)
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .textContentType(.newPassword)
                        }
                        //   instead of % padding, we cap real width & center
                        .frame(width: formWidth)

                        //  sign up button (same style, adaptive height)
                        Button(action: {
                            //  simple check
                            if password != confirmPassword {
                                viewModel.errorMessage = "Password do not match"
                                return
                            }
                            Task {
                                await viewModel.signup(email: email, password: password)
                                //  on success go to profile edit
                                if viewModel.errorMessage.isEmpty {
                                    session.isProfileLoaded = true
                                    appRouter.goToProfileEdit(isFromSignUp: true)
                                }
                            }
                        }) {
                            Text("Sign Up")
                                .font(.title3.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: fieldHeight)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .frame(width: formWidth) // 🪄 keep same max width as fields

                        //  switch to login (small text row)
                        HStack {
                            Text("Have an account?")
                                .foregroundColor(.gray)

                            Button("Log In") {
                                router.goToLogin()
                            }
                            .foregroundColor(.sdc)
                        }
                        .font(.subheadline)

                        Spacer(minLength: 12) // tiny bottom space
                    }
                    //  keep vertical padding but let width be controlled by formWidth
                    .padding(.vertical)
                    //  NEW: center the whole stack on big screens
                    .frame(maxWidth: .infinity)
                }
                //  nice keyboard behavior (iOS 16+ safe to use; ignored on older)
                .scrollDismissesKeyboard(.interactively)

                //  error card on top
                if !viewModel.errorMessage.isEmpty {
                    AlertCardView(
                        title: "Oops!",
                        message: viewModel.errorMessage,
                        dismissAction: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                viewModel.errorMessage = ""
                            }
                        }
                    )
                    .padding(.top, 20)
                    .zIndex(1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85),
                               value: viewModel.errorMessage.isEmpty)
                }

                //  loading spinner
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
