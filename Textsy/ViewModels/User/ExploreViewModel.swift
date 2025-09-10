


import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var users: [UserModel] = []
    @Published var errorMessage = ""

    func fetchOtherUsers(currentUserId: String) async {
        do {
            let db = Firestore.firestore()

            // 1️⃣ Get my blocked list
            let meDoc = try await db.collection("users").document(currentUserId).getDocument()
            let myBlocked = meDoc["blocked"] as? [String] ?? []

            // 2️⃣ Get all users
            let snapshot = try await db.collection("users").getDocuments()
            let allUsers = snapshot.documents.compactMap { doc -> UserModel? in
                UserModel(id: doc.documentID, data: doc.data())
            }

            // 3️⃣ Filter: remove myself, remove those I blocked, and those who blocked me
            self.users = allUsers.filter { user in
                let theirBlocked = snapshot.documents.first(where: { $0.documentID == user.id })?["blocked"] as? [String] ?? []
                return user.id != currentUserId &&
                       !myBlocked.contains(user.id) &&
                       !theirBlocked.contains(currentUserId)
            }

        } catch {
            errorMessage = "❌ Failed to load users: \(error.localizedDescription)"
        }
    }

}
