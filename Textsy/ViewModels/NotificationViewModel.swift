//import Foundation
//import FirebaseFirestore
//import FirebaseAuth
//
//@MainActor
//class NotificationViewModel: ObservableObject {
//    @Published var notifications: [NotificationModel] = []
//    @Published var isLoading = false
//    @Published var errorMessage = ""
//
//    private let db = Firestore.firestore()
//
//    func listenForNotifications(for userId: String) {
//        db.collection("notifications")
//            .whereField("receiverId", isEqualTo: userId)
//            .order(by: "timestamp", descending: true)
//            .addSnapshotListener { snapshot, _ in
//                self.notifications = snapshot?.documents.compactMap {
//                    NotificationModel(id: $0.documentID, data: $0.data())
//                } ?? []
//            }
//    }
//
//    func sendHiMessage(to userId: String, chatId: String, userName: String, userImage: String?) async {
//        guard let senderId = Auth.auth().currentUser?.uid else { return }
//
//        let message: [String: Any] = [
//            "senderId": senderId,
//            "text": "Hey, how have you been?",
//            "timestamp": Timestamp(date: Date())
//        ]
//
//        let chatRef = db.collection("chats").document(chatId)
//        let exists = try? await chatRef.getDocument().exists
//        if exists == false {
//            try? await chatRef.setData([
//                "chatId": chatId,
//                "participants": [senderId, userId],
//                "userId": userId,
//                "userName": userName,
//                "profileImageURL": userImage ?? "",
//                "lastMessage": "Hey, how have you been?",
//                "timeStamp": Timestamp(date: Date())
//            ])
//        }
//
//        try? await chatRef.collection("messages").addDocument(data: message)
//
//        if let sender = await fetchUserInfo(uid: senderId),
//           let receiver = await fetchUserInfo(uid: userId) {
//            let notification: [String: Any] = [
//                "senderId": senderId,
//                "receiverId": userId,
//                "senderName": sender.name,
//                "receiverName": receiver.name,
//                "senderImageUrl": sender.imageUrl ?? "",
//                "type": "request",
//                "message": "said hi to you",
//                "timestamp": Timestamp(date: Date())
//            ]
//            try? await db.collection("notifications").addDocument(data: notification)
//        }
//    }
//
//    func markAsResponded(notificationId: String) async {
//        try? await db.collection("notifications").document(notificationId).updateData(["status": "responded"])
//    }
//
//    func deleteNotification(notificationId: String) async {
//        try? await db.collection("notifications").document(notificationId).delete()
//    }
//
//    func fetchUserInfo(uid: String) async -> (name: String, imageUrl: String?)? {
//        do {
//            let doc = try await db.collection("users").document(uid).getDocument()
//            let data = doc.data()
//            let name = data?["name"] as? String ?? ""
//            let image = data?["profileImageUrl"] as? String
//            return (name, image)
//        } catch {
//            print("❌ Failed to fetch user info: \(error.localizedDescription)")
//            return nil
//        }
//    }
//}
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    func listenForNotifications(for userId: String) {
        db.collection("notifications")
            .whereFilter(Filter.orFilter([
                Filter.whereField("receiverId", isEqualTo: userId),
                Filter.whereField("senderId", isEqualTo: userId)
            ]))
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, _ in
                self.notifications = snapshot?.documents.compactMap {
                    NotificationModel(id: $0.documentID, data: $0.data())
                } ?? []
            }
    }


    func sendHiMessage(to userId: String, chatId: String, notificationId: String) async {
        guard let senderId = Auth.auth().currentUser?.uid else { return }

        let message: [String: Any] = [
            "senderId": senderId,
            "text": "Hey, how have you been?",
            "timestamp": Timestamp(date: Date())
        ]

        let chatRef = db.collection("chats").document(chatId)
        let exists = try? await chatRef.getDocument().exists

        if let sender = await fetchUserInfo(uid: senderId),
           let receiver = await fetchUserInfo(uid: userId) {

            if exists == false {
                try? await chatRef.setData([
                    "chatId": chatId,
                    "participants": [senderId, userId],
                    "senderId": senderId,
                    "senderName": sender.name,
                    "receiverId": userId,
                    "receiverName": receiver.name,
                    "profileImageURL": receiver.imageUrl ?? "",
                    "lastMessage": "Hey, how have you been?",
                    "timeStamp": Timestamp(date: Date())
                ])
            }

            try? await chatRef.collection("messages").addDocument(data: message)

            try? await db.collection("notifications")
                .document(notificationId)
                .updateData(["status": "accepted"])
        }
    }

    func markAsResponded(notificationId: String, status: String) async {
        try? await db.collection("notifications")
            .document(notificationId)
            .updateData(["status": status])
    }

    func deleteNotification(notificationId: String) async {
        try? await db.collection("notifications").document(notificationId).delete()
    }

    func fetchUserInfo(uid: String) async -> (name: String, imageUrl: String?)? {
        do {
            let doc = try await db.collection("users").document(uid).getDocument()
            let data = doc.data()
            let name = data?["name"] as? String ?? ""
            let image = data?["profileImageUrl"] as? String
            return (name, image)
        } catch {
            print("❌ Failed to fetch user info: \(error.localizedDescription)")
            return nil
        }
    }
}
//------notification is not working properly
