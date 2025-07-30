import Foundation
import FirebaseFirestore

// 💬 One chat bubble message
struct MessageModel: Identifiable, Codable {
    var id: String // 📄 Firestore doc ID
    var senderId: String // 👤 userID from Firebase Auth
    var text: String // 📝 message text
    var timestamp: Date // 🕒 when sent

    // ✅ Read from Firestore
    init?(id: String, data: [String: Any]) {
        guard
            let senderId = data["senderId"] as? String,
            let text = data["text"] as? String,
            let timestamp = data["timestamp"] as? Timestamp
        else {
            return nil
        }

        self.id = id
        self.senderId = senderId
        self.text = text
        self.timestamp = timestamp.dateValue()
    }

    // ✅ Save to Firestore
    var asDictionary: [String: Any] {
        return [
            "senderId": senderId,
            "text": text,
            "timestamp": Timestamp(date: timestamp)
        ]
    }

    // ✅ Use this to check if message is from current user
    func isFromCurrentUser(currentUserId: String) -> Bool {
        return senderId == currentUserId
    }
}
