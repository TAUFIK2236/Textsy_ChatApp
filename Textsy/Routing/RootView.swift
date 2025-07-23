//
//  RootView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/18/25.
//


import SwiftUI

struct RootView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var session : UserSession
    var body: some View {
        switch router.currentScreen {
        case .splash:
            SplashView()
                .onAppear{
                    checkToken()
                }
        case .login:
            LoginView()
        case .signup:
            SignupView()
        case .forgotPassword:
            ForgotPasswordView()
        case .mainApp:
            if session.currentUser?.displayName == nil {
                ProfileView()
            }else{
                HomeView()
            }
        }
    }
    
    
    
    private func checkToken(){
        if let _ = UserDefaults.standard.string(forKey: "userUID"){
            router.goToMainApp()
        }else{
            router.goToLogin()
        }
    }
}
