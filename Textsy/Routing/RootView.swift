//
//  RootView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: AppRouter

    var body: some View {
        switch router.currentScreen {
        case .splash:
            SplashView()
        case .login:
            LoginView()
        case .signup:
            SignupView()
        case .forgotPassword:
            ForgotPasswordView()
        case .mainApp:
            HomeView()
        }
    }
}
