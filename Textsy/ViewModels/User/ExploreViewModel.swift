


import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var users: [UserModel] = []
    @Published var errorMessage = ""

    func fetchOtherUsers(currentUserId: String) async {
        do {
            let snapshot = try await Firestore.firestore().collection("users").getDocuments()
            
            let allUsers = snapshot.documents.compactMap { doc in
                UserModel(id: doc.documentID, data: doc.data())
            }

            // 🧹 Remove current user
            self.users = allUsers.filter { $0.id != currentUserId }

        } catch {
            errorMessage = "❌ Failed to load users: \(error.localizedDescription)"
        }
    }
}
