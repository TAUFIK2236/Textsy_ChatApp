


import SwiftUI

struct MainAppRouterView: View {

    @EnvironmentObject var appRouter: AppRouter // ✅ Use the shared one

    @EnvironmentObject var session: UserSession



    
    var body: some View {
        
        

        
        Color.clear
            .onAppear {
                if session.hasCompletedProfile() {
                    appRouter.currentPage = .home
                } else {
                    appRouter.currentPage = .profileEdit(isFromSignUp: true)
                }
            }

            .onChange(of: session.isProfileLoaded, initial: false) { _, _ in
                routeBasedOnProfile()
            }
            .hidden()



        
        switch appRouter.currentPage {
        case .home:
            HomeView()
                .environmentObject(appRouter)
                .environmentObject(session)

        case .explore:
            ExploreView(isFirstTime:false)
            .environmentObject(appRouter)
            .environmentObject(session)
            
        case .exploraFirstTime:
            ExploreView(isFirstTime:true)
                .environmentObject(appRouter)
                .environmentObject(session)

        case .profileEdit(let isFromSignUp):
            ProfileEditView(isFromSignUp: isFromSignUp)
                .environmentObject(appRouter)

        case .userProfile(let userId):
            UserProfileWrapperView(userId: userId)
                .environmentObject(appRouter)
                .environmentObject(session)


            
        case .chat(let userId):
            ChatView(userId: userId)
                .environmentObject(appRouter)
                .environmentObject(session)
            
            
        case .settingss:
            SettingView()
                .environmentObject(appRouter)
                .environmentObject(session)
            


        case .notifications:
            NotificationView()
                .environmentObject(appRouter)
                .environmentObject(session)
        }
    }
    private func routeBasedOnProfile() {
        if session.hasCompletedProfile() {
            appRouter.currentPage = .home
        } else {
            appRouter.currentPage = .profileEdit(isFromSignUp: true)
        }
    }
}
