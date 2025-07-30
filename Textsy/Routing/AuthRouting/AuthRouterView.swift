//
//  AuthRouterView.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/25/25.
//


import SwiftUI

struct AuthRouterView: View {
    @StateObject var router = AuthRouter()

    var body: some View {
        switch router.currentPage {
        case .login:
            LoginView()
                .environmentObject(router)
                .environmentObject(UserSession.shared)

        case .signup:
            SignupView()
                .environmentObject(router)
                .environmentObject(UserSession.shared)

        case .forgot:
            ForgotPasswordView()
                .environmentObject(router)
        }
    }
}
