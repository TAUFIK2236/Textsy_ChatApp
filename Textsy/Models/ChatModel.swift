
import Foundation
import FirebaseFirestore

struct ChatModel: Identifiable {
    let id: String
    let userName: String
    let lastMessage: String?
    let timeStamp: Date
    let profileImageURL: String?
    let unreadCount: Int

    // MARK: - Firestore Initializer
    init?(id: String, data: [String: Any]) {
        self.id = id
        self.userName = data["userName"] as? String ?? "Unknown"
        self.lastMessage = data["lastMessage"] as? String
        self.profileImageURL = data["profileImageURL"] as? String
        self.unreadCount = data["unreadCount"] as? Int ?? 0

        // Convert Firestore Timestamp → Date
        if let timestamp = data["timeStamp"] as? Timestamp {
            self.timeStamp = timestamp.dateValue()
        } else {
            self.timeStamp = Date() // fallback
        }
    }

    // MARK: - Display Formatter
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timeStamp)
    }
}

