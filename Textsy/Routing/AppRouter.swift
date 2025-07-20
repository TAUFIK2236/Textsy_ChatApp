//
//  AppRouter.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import SwiftUI
@MainActor
class AppRouter: ObservableObject {
    static let shared = AppRouter() 
    enum Screen {
        case splash
        case login
        case signup
        case forgotPassword
        case mainApp
    }

    @Published var currentScreen: Screen = .splash

    func goToMainApp() {
        currentScreen = .mainApp
    }

    func goToLogin() {
        currentScreen = .login
    }

    func goToSignup() {
        currentScreen = .signup
    }

    func goToForgotPassword() {
        currentScreen = .forgotPassword
    }

    func logout() {
        UserSession.shared.logout()
        currentScreen = .login
    }
}
