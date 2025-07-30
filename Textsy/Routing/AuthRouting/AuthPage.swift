

import Foundation

enum AuthPage {
    case login
    case signup
    case forgot
}

class AuthRouter: ObservableObject {
    @Published var currentPage: AuthPage = .login

    //  Clean helpers
    func goToLogin()  { currentPage = .login }
    func goToSignup() { currentPage = .signup }
    func goToForgot() { currentPage = .forgot }
}
