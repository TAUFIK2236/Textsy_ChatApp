
import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserSession: ObservableObject {
    static let shared = UserSession()
    @Published var isProfileLoaded: Bool = false


    @Published var uid: String = ""
    @Published var email: String = ""
    @Published var displayName: String = ""
    @Published var token: String = ""
  

    // ✅ Add user profile info
    @Published var name: String = ""
    @Published var age: Int = 0
    @Published var location: String = ""
    @Published var bio: String = ""
    @Published var profileImageUrl: String? = nil

    private init() {}

    func loadFromFirebaseUser(_ user: User) {
        self.uid = user.uid
        self.email = user.email ?? ""
        self.displayName = user.displayName ?? ""

        // 🔐 load token
        user.getIDToken { token, error in
            if let token = token {
                DispatchQueue.main.async {
                    self.token = token
                    print("✅ ID Token loaded: \(token.prefix(15))...")
                }
            }
        }
    }

    // ✅ Add this
    func hasCompletedProfile() -> Bool {
        return !name.isEmpty && age > 0 && !location.isEmpty && !bio.isEmpty
    }

    // ✅ Load profile data from Firestore
    func loadUserProfileFromFirestore() async {
        let db = Firestore.firestore()
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            guard let data = doc.data() else { return }

            DispatchQueue.main.async {
                self.name = data["name"] as? String ?? ""
                self.age = data["age"] as? Int ?? 0
                self.location = data["location"] as? String ?? ""
                self.bio = data["bio"] as? String ?? ""
                self.profileImageUrl = data["profileImageUrl"] as? String
                self.isProfileLoaded = true
              
            }

        } catch {
            print("❌ Failed to load user profile: \(error.localizedDescription)")
        }
    }

    func clear() {
        uid = ""
        email = ""
        displayName = ""
        token = ""

        name = ""
        age = 0
        location = ""
        bio = ""
        profileImageUrl = nil
    }
    
//    func toUserModel() -> UserModel {
//        return UserModel(
//            id: uid,
//            name: name,
//            age: age,
//            location: location,
//            bio: bio,
//            profileImageUrl: nil
//        )
//    }


}
