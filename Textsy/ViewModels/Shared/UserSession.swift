//
//  remembers.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/25/25.
//


import Foundation
import FirebaseAuth

// 👤 This class remembers the currently logged-in user
class UserSession: ObservableObject {
    // 🧠 Singleton - only one shared session for the whole app
    static let shared = UserSession()

    // 📦 Published properties - any change updates the UI automatically
    @Published var uid: String = ""
    @Published var email: String = ""
    @Published var displayName: String = ""
    @Published var token: String = "" // 🔐 Firebase ID token

    // 👶 Private init means no one else can make another copy
    private init() {}

    // ✅ When a user logs in, we load their info from Firebase
    func loadFromFirebaseUser(_ user: User) {
        self.uid = user.uid                       // Set userID
        self.email = user.email ?? ""             // Set email (or empty string)
        self.displayName = user.displayName ?? "" // Set display name (optional)

        // 🔁 Get the secure ID token from Firebase
        user.getIDToken { token, error in
            if let token = token {
                DispatchQueue.main.async {
                    self.token = token
                    print("✅ ID Token loaded: \(token.prefix(20))...") // (shortened print)
                }
            } else if let error = error {
                print("❌ Token error: \(error.localizedDescription)")
            }
        }
    }

    // ❌ Use this to log out or clear session
    func clear() {
        uid = ""
        email = ""
        displayName = ""
        token = ""
    }
}
