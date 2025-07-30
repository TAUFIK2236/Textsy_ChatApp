


import Foundation
import FirebaseFirestore

// 🧍‍♀️ A single user's info (from Firestore)
struct UserModel: Identifiable, Codable, Hashable {
    var id: String // 📄 Firestore doc ID
    var name: String
    var age: Int
    var location: String
    var bio: String
    var profileImageUrl: String? // 🌄 May be nil

    // ✅ Init from Firestore document
    init?(id: String, data: [String: Any]) {
        guard
            let name = data["name"] as? String,
            let age = data["age"] as? Int,
            let location = data["location"] as? String,
            let bio = data["bio"] as? String
        else {
            return nil // ❌ If anything is missing, fail
        }

        self.id = id
        self.name = name
        self.age = age
        self.location = location
        self.bio = bio
        self.profileImageUrl = data["profileImageUrl"] as? String // optional
    }
    
    // ✅ Manual init so we can create UserModel directly (not from Firestore)
    init(id: String, name: String, age: Int, location: String, bio: String, profileImageUrl: String?) {
        self.id = id
        self.name = name
        self.age = age
        self.location = location
        self.bio = bio
        self.profileImageUrl = profileImageUrl
    }


    // ✅ Convert this model to a dictionary for saving to Firestore
    var asDictionary: [String: Any] {
        return [
            "name": name,
            "age": age,
            "location": location,
            "bio": bio,
            "profileImageUrl": profileImageUrl ?? ""
        ]
    }
}
