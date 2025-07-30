import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatViewModel: ObservableObject {
    @Published var chats: [ChatModel] = []
    @Published var errorMessage = ""

    // 🧠 Load chats from Firestore
    func fetchChats() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "No logged in user"
            return
        }

        do {
            let snapshot = try await Firestore.firestore()
                .collection("chats")
                .whereField("participants", arrayContains: uid)
                .order(by: "timeStamp", descending: true)
                .getDocuments()

            // Map Firestore docs → ChatModel
            self.chats = snapshot.documents.compactMap { doc in
                ChatModel(id: doc.documentID, data: doc.data())
            }

            print("✅ Loaded \(chats.count) chats")

        } catch {
            errorMessage = "❌ Failed to load chats: \(error.localizedDescription)"
        }
    }
}
