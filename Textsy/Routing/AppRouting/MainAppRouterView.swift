import SwiftUI

struct MainAppRouterView: View {
    @StateObject var appRouter = AppRouter()

    var body: some View {
        switch appRouter.currentPage {
        case .home:
            HomeView()
                .environmentObject(appRouter)

        case .explore:
            ExploreView()
                .environmentObject(appRouter)

        case .profileEdit:
            ProfileEditView()
                .environmentObject(appRouter)

        case .userProfile(let userId):
            Text("User Profile Page for \(userId)") // TODO: Replace with UserProfileView
        }
    }
}
