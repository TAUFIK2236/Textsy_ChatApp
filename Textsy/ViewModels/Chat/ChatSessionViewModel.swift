////
////  ChatSessionViewModel.swift
////  Textsy
////
////  Created by Anika Tabasum on 7/26/25.
////
//
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
//    // 🧠 Load messages for a given chatId
//    func fetchMessages(chatId: String) async {
//        isLoading = true
//        do {
//            let snapshot = try await db.collection("chats")
//                .document(chatId)
//                .collection("messages")
//                .order(by: "timestamp", descending: false)
//                .getDocuments()
//
//            self.messages = snapshot.documents.compactMap { doc in
//                MessageModel(id: doc.documentID, data: doc.data())
//            }
//
//        } catch {
//            self.errorMessage = "Failed to load messages: \(error.localizedDescription)"
//        }
//        isLoading = false
//    }
//
//    // ✉️ Send a new message to the chat
//    func sendMessage(chatId: String, text: String) async {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        let messageData: [String: Any] = [
//            "senderId": uid,
//            "text": text,
//            "timestamp": Timestamp(date: Date())
//        ]
//
//        do {
//            try await db.collection("chats")
//                .document(chatId)
//                .collection("messages")
//                .addDocument(data: messageData)
//            
//            //  UPDATE chat document's lastMessage
//            try await db.collection("chats").document(chatId).updateData([
//                "lastMessage": text,
//                "timeStamp": Timestamp(date: Date())
//            ])
//
//        } catch {
//            errorMessage = "Failed to send message: \(error.localizedDescription)"
//        }
//    }
//
//    
//    
//    func createChatIfNotExists(chatId: String, user1Id: String, user2Id: String, user2Name: String, user2Image: String) async {
//        let docRef = db.collection("chats").document(chatId)
//
//        let exists = try? await docRef.getDocument().exists
//        if exists == false {
//            try? await docRef.setData([
//                "chatId": chatId,
//                "participants": [user1Id, user2Id],
//                "userId": user2Id,
//                "userName": user2Name,
//                "profileImageURL": user2Image,
//                "lastMessage": "Hi, how are you?",
//                "timeStamp": Timestamp(date: Date())
//            ])
//        }
//    }
//
//
//}
import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class ChatSessionViewModel: ObservableObject {
    @Published var messages: [MessageModel] = []
    @Published var isLoading = false
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    func fetchMessages(chatId: String) async {
        isLoading = true
        do {
            let snapshot = try await db.collection("chats")
                .document(chatId)
                .collection("messages")
                .order(by: "timestamp", descending: false)
                .getDocuments()
            self.messages = snapshot.documents.compactMap { MessageModel(id: $0.documentID, data: $0.data()) }
        } catch {
            self.errorMessage = "Failed to load messages: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func sendMessage(chatId: String, text: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // Load chat info to get sender/receiver names and IDs
        let chatRef = db.collection("chats").document(chatId)
        guard let chatData = try? await chatRef.getDocument().data(),
              let senderId = chatData["senderId"] as? String,
              let receiverId = chatData["receiverId"] as? String,
              let senderName = chatData["senderName"] as? String,
              let receiverName = chatData["receiverName"] as? String
        else { return }

        let messageData: [String: Any] = [
            "senderId": uid,
            "receiverId": (uid == senderId) ? receiverId : senderId,
            "senderName": (uid == senderId) ? senderName : receiverName,
            "receiverName": (uid == senderId) ? receiverName : senderName,
            "text": text,
            "timestamp": Timestamp(date: Date())
        ]

        do {
            try await chatRef.collection("messages").addDocument(data: messageData)
            try await chatRef.updateData([
                "lastMessage": text,
                "timeStamp": Timestamp(date: Date())
            ])
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }


    func createChatIfNotExists(chatId: String, senderId: String, receiverId: String, senderName: String, receiverName: String, senderImage: String?, receiverImage: String?) async {
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
