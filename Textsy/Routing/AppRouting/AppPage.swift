


import Foundation

enum AppPage: Equatable {
    case home
    case profileEdit(isFromSignUp: Bool)
    case explore
    case exploraFirstTime
    
    case chat(userId: String)
    case userProfile(userId: String) // future if you want
}

class AppRouter: ObservableObject {
    @Published var currentPage: AppPage = .home

    // ✅ Routing helpers
    func goToHome() { currentPage = .home }
    func goToExplore() { currentPage = .explore }
    func goToProfileEdit(isFromSignUp: Bool = false) {
        currentPage = .profileEdit(isFromSignUp: isFromSignUp)
    }

    func goToChat(with userId: String) {
        currentPage = .chat(userId: userId)
    }
    func goToUserProfile(id: String) {
        currentPage = .userProfile(userId: id)
    }


}
extension AppPage {// I have to keep it and keep eyes on it
    static func == (lhs: AppPage, rhs: AppPage) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home): return true
        case let (.profileEdit(a), .profileEdit(b)): return a == b
        case (.explore, .explore): return true
        case (.exploraFirstTime, .exploraFirstTime):return true
        case let (.chat(a), .chat(b)): return a == b
        case let (.userProfile(userId:a), .userProfile(userId: b)): return a == b
        default: return false
        }
    }
}
