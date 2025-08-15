import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var showMain = false
    @EnvironmentObject var session: UserSession
    @EnvironmentObject var appRouter: AppRouter
    @StateObject var network = NetworkMonitor()

    var body: some View {
        ZStack {
            if showMain {

                
                if session.uid.isEmpty {
                    AuthRouterView()
                        .environmentObject(network)
                } else if !session.isProfileLoaded {
                    LoadingCircleView() // 🌀 Clean loading view
                } else {
                    MainAppRouterView()
                        .environmentObject(appRouter)
                        .environmentObject(session)
                        .environmentObject(ChatViewModel())
                        


                }


            } else {
                // Splash screen animation (do NOT touch this part)
                Color(.bgc)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("logo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isActive ? 120 : 0, height: isActive ? 120 : 0)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(radius: 20)
                        .opacity(isActive ? 1 : 0)
                        .scaleEffect(isActive ? 1 : 0.6)
                        .animation(.easeOut(duration: 1), value: isActive)

                    Text("Textsy")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isActive ? 1 : 0)
                        .offset(y: isActive ? 0 : 40)
                        .animation(.easeOut(duration: 1.2).delay(0.3), value: isActive)
                }
            }
        }
        .onAppear {
            // Play logo animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.1)) {
                    self.isActive = true
                }
            }

            // Load profile data if logged in
            if !session.uid.isEmpty {
                Task {
                    await session.loadUserProfileFromFirestore()
                }
            }

            // Show app after splash finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.showMain = true
                }
            }
        }
    }
}

#Preview("SplashView - Dark") {
    SplashView()
        .preferredColorScheme(.light)
        .environmentObject(UserSession.shared)
}
