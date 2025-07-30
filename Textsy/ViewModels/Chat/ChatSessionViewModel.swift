import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatSessionViewModel: ObservableObject {
    @Published var messages: [MessageModel] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    // 🧠 Load messages for a given chatId
    func fetchMessages(chatId: String) async {
        isLoading = true
        do {
            let snapshot = try await db.collection("chats")
                .document(chatId)
                .collection("messages")
                .order(by: "timestamp", descending: false)
                .getDocuments()

            self.messages = snapshot.documents.compactMap { doc in
                MessageModel(id: doc.documentID, data: doc.data())
            }

        } catch {
            self.errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // ✉️ Send a new message to the chat
    func sendMessage(chatId: String, text: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let messageData: [String: Any] = [
            "senderId": uid,
            "text": text,
            "timestamp": Timestamp(date: Date())
        ]

        do {
            try await db.collection("chats")
                .document(chatId)
                .collection("messages")
                .addDocument(data: messageData)
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }
}
