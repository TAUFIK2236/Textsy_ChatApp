// ChatViewModel.swift — Handles both chat list + individual chat messages

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatViewModel: ObservableObject {
    // 🔁 Realtime chat list
    @Published var chats: [ChatModel] = []
    @Published var errorMessage = ""

    // 💬 Realtime messages in one chat
    @Published var messages: [MessageModel] = []

    private var chatListListener: ListenerRegistration?
    private var messageListener: ListenerRegistration?

    private let db = Firestore.firestore()
    private let cacheKey = "cached_chats_v2"

    // MARK: - Realtime chat list (HomeView)
    func listenToChats(for userId: String, pageSize: Int = 30) {
        loadCache()
        chatListListener?.remove()

        chatListListener = db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "timeStamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = "❌ Chat list listener failed: \(error.localizedDescription)"
                    return
                }
                guard let docs = snapshot?.documents else { return }

                self.chats = docs.compactMap { ChatModel(id: $0.documentID, data: $0.data()) }
                self.saveCache(self.chats)
            }
    }

    // MARK: - Realtime message listener (ChatView)
    func listenToMessages(chatId: String) {
        messageListener?.remove()
        messages.removeAll()

        messageListener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = "❌ Message listener failed: \(error.localizedDescription)"
                    return
                }
                guard let docs = snapshot?.documents else { return }
                self.messages = docs.compactMap { MessageModel(id: $0.documentID, data: $0.data()) }
            }
    }

    // MARK: - Send message
    func sendMessage(chatId: String, text: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let chatRef = db.collection("chats").document(chatId)

        do {
            let chatData = try await chatRef.getDocument().data() ?? [:]
            let senderId = chatData["senderId"] as? String ?? uid
            let receiverId = chatData["receiverId"] as? String ?? ""
            let senderName = chatData["senderName"] as? String ?? ""
            let receiverName = chatData["receiverName"] as? String ?? ""

            let messageData: [String: Any] = [
                "senderId": uid,
                "receiverId": (uid == senderId) ? receiverId : senderId,
                "senderName": (uid == senderId) ? senderName : receiverName,
                "receiverName": (uid == senderId) ? receiverName : senderName,
                "text": trimmed,
                "timestamp": Timestamp(date: Date())
            ]

            try await chatRef.collection("messages").addDocument(data: messageData)

            try await chatRef.updateData([
                "lastMessage": trimmed,
                "timeStamp": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = "❌ Failed to send message: \(error.localizedDescription)"
        }
    }

    // MARK: - Create chat if not exists
    func createChatIfNotExists(
        chatId: String,
        senderId: String,
        receiverId: String,
        senderName: String,
        receiverName: String,
        senderImage: String?,
        receiverImage: String?
    ) async {
        let docRef = db.collection("chats").document(chatId)
        let exists = try? await docRef.getDocument().exists
        if exists == false {
            let data: [String: Any] = [
                "chatId": chatId,
                "participants": [senderId, receiverId],
                "senderId": senderId,
                "senderName": senderName,
                "receiverId": receiverId,
                "receiverName": receiverName,
                "profileImageURL": receiverImage ?? "",
                "lastMessage": "Hi, how are you?",
                "timeStamp": Timestamp(date: Date())
            ]
            try? await docRef.setData(data)
        }
    }

    // MARK: - Cache helpers
    private func saveCache(_ items: [ChatModel]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("⚠️ Chat cache save failed: \(error.localizedDescription)")
        }
    }

    private func loadCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return }
        do {
            let cached = try JSONDecoder().decode([ChatModel].self, from: data)
            self.chats = cached
        } catch {
            print("⚠️ Chat cache load failed: \(error.localizedDescription)")
        }
    }
    
    func computeChatId(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "_")
    }


    deinit {
        chatListListener?.remove()
        messageListener?.remove()
    }
}
