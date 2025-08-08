


import SwiftUI

struct MainAppRouterView: View {

    @EnvironmentObject var appRouter: AppRouter // ✅ Use the shared one
    @StateObject var notificationVM = NotificationViewModel()
    @StateObject var chatMV = ChatViewModel()
    @EnvironmentObject var session: UserSession
  //  @EnvironmentObject var chatMV : ChatViewModel


    
    var body: some View {
        
        

        
        Color.clear
            .onAppear {
                if session.hasCompletedProfile() {
                    appRouter.currentPage = .home
                } else {
                    appRouter.currentPage = .profileEdit(isFromSignUp: true)
                }
                print("👤 Logged in as: \(session.uid)")

                // ✅ Start listening no matter which page we're on!
                notificationVM.listenForNotifications(for: session.uid)
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
                .environmentObject(notificationVM)
                .environmentObject(chatMV)
                .onAppear {
                    notificationVM.listenForNotifications(for: session.uid)
                }


        case .explore:
            ExploreView(isFirstTime:false)
            .environmentObject(appRouter)
            .environmentObject(session)
            .environmentObject(notificationVM)
            .environmentObject(chatMV)
            
        case .exploraFirstTime:
            ExploreView(isFirstTime:true)
                .environmentObject(appRouter)
                .environmentObject(session)
                .environmentObject(notificationVM)
                .environmentObject(chatMV)
            
        case .profileEdit(let isFromSignUp):
            ProfileEditView(isFromSignUp: isFromSignUp)
                .environmentObject(appRouter)

        case .userProfile(let userId):
            UserProfileWrapperView(userId: userId)
                .environmentObject(appRouter)
                .environmentObject(session)
                .environmentObject(chatMV)

            
        case .chat(let chatId):
            ChatView(chatId: chatId)
                .environmentObject(appRouter)
                .environmentObject(session)
                .environmentObject(notificationVM)
                .environmentObject(chatMV)
            
            
        case .settingss:
            SettingView()
                .environmentObject(appRouter)
                .environmentObject(session)
            


        case .notifications:
            NotificationView()
                .environmentObject(appRouter)
                .environmentObject(session)
                .environmentObject(notificationVM)
                .environmentObject(chatMV)
            
            
//        case .myOnwProfile:
//            UserProfileWrapperView(userId: session.uid)
//                .environmentObject(appRouter)
//                .environmentObject(session)
//                .environmentObject(notificationVM)
//                .environmentObject(chatMV)
            
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
