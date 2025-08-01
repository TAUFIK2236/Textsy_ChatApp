import Foundation
import FirebaseFirestore

struct NotificationModel: Identifiable, Codable {
    var id: String
    var senderId: String
    var receiverId: String
    var senderName: String
    var senderImageUrl: String?
    var type: NotificationType
    var message: String
    var timestamp: Date

    enum NotificationType: String, Codable {
        case request
        case accepted
        case declined
    }

    init?(id: String, data: [String: Any]) {
        guard
            let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let senderName = data["senderName"] as? String,
            let typeRaw = data["type"] as? String,
            let type = NotificationType(rawValue: typeRaw),
            let message = data["message"] as? String,
            let timestamp = data["timestamp"] as? Timestamp
        else { return nil }

        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.senderName = senderName
        self.senderImageUrl = data["senderImageUrl"] as? String
        self.type = type
        self.message = message
        self.timestamp = timestamp.dateValue()
    }

    var asDictionary: [String: Any] {
        return [
            "senderId": senderId,
            "receiverId": receiverId,
            "senderName": senderName,
            "senderImageUrl": senderImageUrl ?? "",
            "type": type.rawValue,
            "message": message,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}

