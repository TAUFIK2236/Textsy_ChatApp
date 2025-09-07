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
    private let pageSize = 20
    private var newestTimeStemp: Timestamp?
    private var oldestDoc: DocumentSnapshot?
    private var newerListener: ListenerRegistration?
    @Published var hasMoreOlder = true
    @Published var isloadingMore = false

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
        newerListener?.remove()
        messageListener?.remove()
        messages.removeAll()
        newestTimeStemp = nil
        oldestDoc = nil
        hasMoreOlder = true

        messageListener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = "❌ Message listener failed: \(error.localizedDescription)"
                    return
                }
                guard let docs = snapshot?.documents,!docs.isEmpty
                else {
                    self.messages = []
                    self.hasMoreOlder = false
                    return
                }
                // Cursor bookkeeping
                        self.oldestDoc = docs.last                          // oldest in this page
                        self.newestTimeStemp = (docs.first?["timestamp"] as? Timestamp) // newest in this page

                let filtered = docs.reversed().compactMap {
                    MessageModel(id: $0.documentID, data: $0.data())
                }.filter {
                    !$0.deletedFor.contains(Auth.auth().currentUser?.uid ?? "")
                }

                self.messages = filtered

                        // 2) Start a second listener that ONLY listens to messages newer than the current newest
                        self.attachNewerListener(chatId: chatId)
                //self.messages = docs.compactMap { MessageModel(id: $0.documentID, data: $0.data()) }
            }
    }
    
    
    // MARK: - NEW: Only listen to messages with timestamp > newestTimeStemp (append only)
    private func attachNewerListener(chatId: String) {
        guard let after = newestTimeStemp else { return }

        newerListener?.remove()
        newerListener = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .whereField("timestamp", isGreaterThan: after)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    self.errorMessage = "❌ Newer-listener failed: \(err.localizedDescription)"
                    return
                }
                guard let docs = snap?.documents, !docs.isEmpty else { return }

                let newItems = docs.compactMap { MessageModel(id: $0.documentID, data: $0.data()) }

                // ✅ FILTER deleted messages
                let filtered = newItems.filter {
                    !$0.deletedFor.contains(Auth.auth().currentUser?.uid ?? "")
                }

                self.messages.append(contentsOf: filtered)

                if let lastTs = docs.last?["timestamp"] as? Timestamp {
                    self.newestTimeStemp = lastTs
                }
            }
    }

    
    // MARK: - NEW: Load older page (20 more), prepend to the top
    func loadOlder(chatId: String) async {
        guard hasMoreOlder, !isloadingMore else { return }
        isloadingMore = true
        defer { isloadingMore = false }

        var query = db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)

        if let cursor = oldestDoc {
            query = query.start(afterDocument: cursor) // continue further back in time
        }

        do {
            let snap = try await query.getDocuments()
            let docs = snap.documents
            if docs.isEmpty {
                hasMoreOlder = false
                return
            }

            // Update the "oldest" cursor to this page's last document
            oldestDoc = docs.last

            let uid = Auth.auth().currentUser?.uid ?? ""

            let filteredOlderAsc = docs.reversed().compactMap {
                MessageModel(id: $0.documentID, data: $0.data())
            }.filter {
                !$0.deletedFor.contains(uid)
            }

            self.messages.insert(contentsOf: filteredOlderAsc, at: 0)


            // If we got fewer than a page, we might be done
            if docs.count < pageSize { hasMoreOlder = false }
        } catch {
            self.errorMessage = "❌ Older page failed: \(error.localizedDescription)"
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
                "timestamp": Timestamp(date: Date()),
                "deletedFor":[]
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
    
    
    func deleteMessageForUser(chatId: String, messageId: String, userId: String) async {
        let ref = db.collection("chats").document(chatId).collection("messages").document(messageId)

        do {
            // 1️⃣ Get current deletedFor array
            let snapshot = try await ref.getDocument()
            guard var data = snapshot.data() else { return }
            var deletedFor = data["deletedFor"] as? [String] ?? []

            // 2️⃣ Add this user to the array (if not already)
            if !deletedFor.contains(userId) {
                deletedFor.append(userId)
            }

            // 3️⃣ Check if BOTH sender and receiver have deleted
            let sender = data["senderId"] as? String ?? ""
            let receiver = data["receiverId"] as? String ?? ""

            if deletedFor.contains(sender) && deletedFor.contains(receiver) {
                // 💥 Both deleted → PERMANENT DELETE
                try await ref.delete()
            } else {
                // 📝 Update deletedFor field + force snapshot refresh
                try await ref.updateData([
                    "deletedFor": deletedFor,
                    "updatedAt": Timestamp(date: Date()) // ✅ Add this to force listener to trigger
                ])
            }

        } catch {
            errorMessage = "❌ Failed to delete message: \(error.localizedDescription)"
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
