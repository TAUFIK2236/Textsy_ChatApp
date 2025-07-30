


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
                .environmentObject(AppRouter())

        case .forgot:
            ForgotPasswordView()
                .environmentObject(router)
        }
    }
}
