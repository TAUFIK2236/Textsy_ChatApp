//
//  TextsyApp.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/16/25.
//

import SwiftUI
import FirebaseCore

@main
struct TextsyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @StateObject var session = UserSession.shared
    @StateObject var appRouter = AppRouter()
    @StateObject var network = NetworkMonitor()



    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(isDarkMode ? .dark : . light)
                .environmentObject(appRouter)
                .environmentObject(session)
                .environmentObject(ChatViewModel())
                .environmentObject(network)
            
                .overlay(
                    ConnectivityBanner()
                        .environmentObject(network)
                        .transition(.move(edge: .top))
                        .zIndex(1)
                )

        }
    }
}
