//
//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//
//@MainActor
//class ChatSessionViewModel: ObservableObject {
//    @Published var messages: [MessageModel] = []
//    @Published var isLoading = false
//    @Published var errorMessage = ""
//
//    private let db = Firestore.firestore()
//
//    func fetchMessages(chatId: String) async {
//        isLoading = true
//        do {
//            let snapshot = try await db.collection("chats")
//                .document(chatId)
//                .collection("messages")
//                .order(by: "timestamp", descending: false)
//                .getDocuments()
//            self.messages = snapshot.documents.compactMap { MessageModel(id: $0.documentID, data: $0.data()) }
//        } catch {
//            self.errorMessage = "Failed to load messages: \(error.localizedDescription)"
//        }
//        isLoading = false
//    }
//
//    func sendMessage(chatId: String, text: String) async {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        // Load chat info to get sender/receiver names and IDs
//        let chatRef = db.collection("chats").document(chatId)
//        guard let chatData = try? await chatRef.getDocument().data(),
//              let senderId = chatData["senderId"] as? String,
//              let receiverId = chatData["receiverId"] as? String,
//              let senderName = chatData["senderName"] as? String,
//              let receiverName = chatData["receiverName"] as? String
//        else { return }
//
//        let messageData: [String: Any] = [
//            "senderId": uid,
//            "receiverId": (uid == senderId) ? receiverId : senderId,
//            "senderName": (uid == senderId) ? senderName : receiverName,
//            "receiverName": (uid == senderId) ? receiverName : senderName,
//            "text": text,
//            "timestamp": Timestamp(date: Date())
//        ]
//
//        do {
//            try await chatRef.collection("messages").addDocument(data: messageData)
//            try await chatRef.updateData([
//                "lastMessage": text,
//                "timeStamp": Timestamp(date: Date())
//            ])
//        } catch {
//            errorMessage = "Failed to send message: \(error.localizedDescription)"
//        }
//    }
//
//
//    func createChatIfNotExists(chatId: String, senderId: String, receiverId: String, senderName: String, receiverName: String, senderImage: String?, receiverImage: String?) async {
//        let docRef = db.collection("chats").document(chatId)
//        let exists = try? await docRef.getDocument().exists
//        if exists == false {
//            let data: [String: Any] = [
//                "chatId": chatId,
//                "participants": [senderId, receiverId],
//                "senderId": senderId,
//                "senderName": senderName,
//                "receiverId": receiverId,
//                "receiverName": receiverName,
//                "profileImageURL": receiverImage ?? "",
//                "lastMessage": "Hi, how are you?",
//                "timeStamp": Timestamp(date: Date())
//            ]
//            try? await docRef.setData(data)
//        }
//    }
//}
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatSessionViewModel: ObservableObject {
    // ==== UI state ====
    @Published var messages: [MessageModel] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var hasMore = true              // 👈 do we have older messages to load?

    // ==== Firestore ====
    private let db = Firestore.firestore()

    // ==== Pagination bookmarks ====
    private let pageSize = 20                  // 👈 how many per page
    private var lastDoc: DocumentSnapshot?     // 👈 where the previous page ended

    // MARK: Single chatId helper (keeps one id for 2 users)
    // Not used by your other views unless you call it, but handy and safe.
    func computeChatId(_ a: String, _ b: String) -> String {
        [a, b].sorted().joined(separator: "_")
    }

    // MARK: 1) FIRST PAGE (keeps same function name)
    // Before: loaded ALL messages ascending. Now: loads newest page then flips to ascending for UI.
    func fetchMessages(chatId: String) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = ""
        hasMore = true
        lastDoc = nil
        messages.removeAll()

        do {
            // newest first for efficient paging
            let snap = try await db.collection("chats")
                .document(chatId)
                .collection("messages")
                .order(by: "timestamp", descending: true)
                .limit(to: pageSize)
                .getDocuments()

            // convert page → models
            let page = snap.documents.compactMap { MessageModel(id: $0.documentID, data: $0.data()) }

            // UI wants oldest→newest: reverse the page
            self.messages = page.reversed()
            // bookmark: the OLDEST doc in this page (because we sorted desc)
            self.lastDoc = snap.documents.last
            // if we got a full page, there may be more
            self.hasMore = snap.documents.count == pageSize
        } catch {
            self.errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: 2) NEXT PAGE (older messages) — new function, no existing names changed
    func loadMore(chatId: String) async {
        guard !isLoading, hasMore, let lastDoc else { return }
        isLoading = true
        errorMessage = ""

        do {
            let snap = try await db.collection("chats")
                .document(chatId)
                .collection("messages")
                .order(by: "timestamp", descending: true)
                .start(afterDocument: lastDoc)       // continue after previous oldest
                .limit(to: pageSize)
                .getDocuments()

            let page = snap.documents.compactMap { MessageModel(id: $0.documentID, data: $0.data()) }

            // insert OLDER messages at the top (keep ascending order in UI)
            self.messages.insert(contentsOf: page.reversed(), at: 0)

            // update bookmark + more flag
            self.lastDoc = snap.documents.last
            self.hasMore = snap.documents.count == pageSize
        } catch {
            self.errorMessage = "Failed to load older messages: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: 3) SEND (keeps same name/signature)
    func sendMessage(chatId: String, text: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let chatRef = db.collection("chats").document(chatId)

        do {
            // pull names/ids from chat doc (matches your existing structure)
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

            // 1) write message
            try await chatRef.collection("messages").addDocument(data: messageData)

            // 2) update chat summary
            try await chatRef.updateData([
                "lastMessage": trimmed,
                "timeStamp": Timestamp(date: Date())
            ])

            // 3) optimistic UI: show immediately at the bottom
            if let appended = MessageModel(id: UUID().uuidString, data: messageData) {
                self.messages.append(appended)
            }
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }

    // MARK: 4) CREATE-IF-NOT-EXISTS (keeps same name/signature)
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
}
