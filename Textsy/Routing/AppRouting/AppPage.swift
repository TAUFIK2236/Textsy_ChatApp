import Foundation

enum AppPage {
    case home
    case profileEdit
    case explore
    case userProfile(userId: String) // future if you want
}

class AppRouter: ObservableObject {
    @Published var currentPage: AppPage = .home

    // ✅ Routing helpers
    func goToHome() { currentPage = .home }
    func goToExplore() { currentPage = .explore }
    func goToProfileEdit() { currentPage = .profileEdit }

    func goToUserProfile(id: String) {
        currentPage = .userProfile(userId: id)
    }
}
