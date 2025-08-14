


import SwiftUI

struct AuthRouterView: View {
    @StateObject var router = AuthRouter()
    @StateObject var appRouter = AppRouter()

    var body: some View {
        switch router.currentPage {
        case .login:
            LoginView()
                .environmentObject(router)
                .environmentObject(UserSession.shared)
                .environmentObject(appRouter)

        case .signup:
            SignupView()
                .environmentObject(router)
                .environmentObject(UserSession.shared)
                .environmentObject(appRouter)

        case .forgot:
            ForgotPasswordView()
                .environmentObject(router)
                .environmentObject(appRouter)
        }
    }
}
