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
  //  @StateObject var router = AppRouter.shared
      @StateObject var session = UserSession.shared
    @StateObject var appRouter = AppRouter()


    init() {
        FirebaseApp.configure()
        print("Configured FireBase")
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
          //  RootView()
                .environmentObject(appRouter)
                .environmentObject(session)
        }
    }
}
