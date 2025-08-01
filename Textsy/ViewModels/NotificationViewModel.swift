//
//  NotificationViewModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/30/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class NotificationViewModel: ObservableObject {
    
    // 👀 These will update the UI when changed
    @Published var notifications: [NotificationModel] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()
    
    // 📡 Start listening to all notifications for THIS user


    // ✅ When we tap "Say Hi" to send a message
    func sendHiMessage(to userId: String, chatId: String, userName: String, userImage: String?) async {
        guard let senderId = Auth.auth().currentUser?.uid else { return }

        let message: [String: Any] = [
            "senderId": senderId,
            "text": "Hey, how have you been?",
            "timestamp": Timestamp(date: Date())
        ]

        let chatRef = db.collection("chats").document(chatId)

        // 🔧 Create chat if it doesn't exist
        let exists = try? await chatRef.getDocument().exists
        if exists == false {
            try? await chatRef.setData([
                "chatId": chatId,
                "participants": [senderId, userId],
                "userId": userId,
                "userName": userName,
                "profileImageURL": userImage ?? "",
                "lastMessage": "Hey, how have you been?",
                "timeStamp": Timestamp(date: Date())
            ])
        }

        // 💬 Send the "Hey, how have you been?" message
        try? await chatRef.collection("messages").addDocument(data: message)
    }

    // ✏️ Mark the notification as “responded”
    func markAsResponded(notificationId: String) async {
        do {
            try await db.collection("notifications")
                .document(notificationId)
                .updateData(["status": "responded"])
        } catch {
            errorMessage = "Failed to update: \(error.localizedDescription)"
        }
    }

    // ❌ Delete the notification (if user wants)
    func deleteNotification(notificationId: String) async {
        do {
            try await db.collection("notifications")
                .document(notificationId)
                .delete()
        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
        }
    }
    
    
    func listenForNotifications(for userId: String) {
        db.collection("notifications")
            .whereField("receiverId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                self.notifications = docs.compactMap { doc in
                    NotificationModel(id: doc.documentID, data: doc.data())
                }
            }
    }

}
