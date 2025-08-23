// UserSession.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class UserSession: ObservableObject {
    static let shared = UserSession()
    @Published var isProfileLoaded: Bool = false

    @Published var uid: String = ""
    @Published var email: String = ""
    @Published var displayName: String = ""
    @Published var token: String = ""

    @Published var name: String = ""
    @Published var age: Int = 0
    @Published var location: String = ""
    @Published var bio: String = ""
    @Published var profileImageUrl: String? = nil

    private init() {}

    func loadFromFirebaseUser(_ user: User) {
        uid = user.uid
        email = user.email ?? ""
        displayName = user.displayName ?? ""
        user.getIDToken { token, _ in
            if let token { Task { @MainActor in self.token = token } }
        }
    }

    func loadUserProfileFromFirestore() async {
        isProfileLoaded = false                        // ⬅️ start as “not ready”
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            guard let data = doc.data() else {
                isProfileLoaded = true                 // nothing to load; still “done”
                return
            }
            // ⬅️ we are already on main actor, assign directly (no DispatchQueue.main.async)
            name = data["name"] as? String ?? ""
            age = data["age"] as? Int ?? 0
            location = data["location"] as? String ?? ""
            bio = data["bio"] as? String ?? ""
            profileImageUrl = data["profileImageUrl"] as? String ?? nil

            isProfileLoaded = true                     // ⬅️ flip only after fields are set
        } catch {
            print("❌ Failed to load user profile: \(error.localizedDescription)")
            isProfileLoaded = true                     // avoid hanging the app
        }
    }

    func hasCompletedProfile() -> Bool {
        !name.isEmpty && age > 0 && !location.isEmpty && !bio.isEmpty
    }

    func clear() {
        uid = ""; email = ""; displayName = ""; token = ""
        name = ""; age = 0; location = ""; bio = ""; profileImageUrl = nil
        isProfileLoaded = false                        // ⬅️ reset the flag on logout
    }
}
