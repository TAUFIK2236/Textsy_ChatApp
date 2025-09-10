


import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var isSaving = false
    @Published var errorMessage = ""

    // 🚨 Only save profile — image is optional
    func saveUserProfile(name: String, age: Int, location: String, bio: String, image: UIImage?) async {
        isSaving = true
        errorMessage = ""

        // 🧠 Step 1: Get current user ID
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user"
            isSaving = false
            return
        }

        // 🌄 Step 2: This will hold the image link (if any)
        var profileImageUrl: String = ""

        // 📤 Step 3: Upload photo if image is NOT nil
        if let image = image {
            do {
                let data = image.jpegData(compressionQuality: 0.4) // compress
                let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")
                _ = try await storageRef.putDataAsync(data!, metadata: nil)
                profileImageUrl = try await storageRef.downloadURL().absoluteString
            } catch {
                errorMessage = "⚠️ Image upload failed: \(error.localizedDescription)"
                isSaving = false
                return
            }
        }

        // 📦 Step 4: Create dictionary for Firestore
        let userData: [String: Any] = [
            "name": name,
            "age": age,
            "location": location,
            "bio": bio,
            "profileImageUrl": profileImageUrl // empty if no image
        ]

        // 🔥 Step 5: Save to Firestore
        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(userData)

            print("✅ Profile saved for \(name)")

        } catch {
            errorMessage = "❌ Firestore save failed: \(error.localizedDescription)"
        }

        isSaving = false
    }
    
    func blockUser(targetId: String) async {
        guard let myId = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("users").document(myId)
        do {
            try await ref.updateData([
                "blocked": FieldValue.arrayUnion([targetId])
            ])
        } catch {
            errorMessage = "❌ Failed to block: \(error.localizedDescription)"
        }
    }

    func unblockUser(targetId: String) async {
        guard let myId = Auth.auth().currentUser?.uid else { return }
        let ref = Firestore.firestore().collection("users").document(myId)
        do {
            try await ref.updateData([
                "blocked": FieldValue.arrayRemove([targetId])
            ])
        } catch {
            errorMessage = "❌ Failed to unblock: \(error.localizedDescription)"
        }
    }
    
    func isBlockedBetween(currentId: String, targetId: String) async -> Bool {
        let db = Firestore.firestore()
        do {
            let meDoc = try await db.collection("users").document(currentId).getDocument()
            let themDoc = try await db.collection("users").document(targetId).getDocument()

            let myBlocked = meDoc["blocked"] as? [String] ?? []
            let theirBlocked = themDoc["blocked"] as? [String] ?? []

            return myBlocked.contains(targetId) || theirBlocked.contains(currentId)
        } catch {
            return true // Safe default: blocked if error
        }
    }

    
}
