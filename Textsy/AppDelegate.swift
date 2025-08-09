//
//  AppDelegate.swift
//  Textsy
//
//  Created by Anika Tabasum on 8/8/25.
//


import UIKit
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // This method is called when the app launches
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase configured from AppDelegate")

        return true
    }

    // 🔔 You can add notification config here if needed
}
