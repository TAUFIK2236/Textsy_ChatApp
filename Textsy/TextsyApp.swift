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
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @StateObject var session = UserSession.shared
    @StateObject var appRouter = AppRouter()


    init() {
        FirebaseApp.configure()
        print("Configured FireBase")
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(isDarkMode ? .dark : . light)
                .environmentObject(appRouter)
                .environmentObject(session)
                .environmentObject(ChatViewModel())

        }
    }
}
