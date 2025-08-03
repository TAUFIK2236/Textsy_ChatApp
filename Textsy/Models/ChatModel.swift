

import Foundation
import FirebaseFirestore


struct ChatModel: Identifiable, Codable {
    var id: String
    var userId: String
    var userName: String
    var lastMessage: String
    var timeStamp: Date
    var profileImageURL: String
    var unreadCount: Int

    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? ""
        self.userName = data["userName"] as? String ?? "Unknown"
        self.lastMessage = data["lastMessage"] as? String ?? ""
        if let ts = data["timeStamp"] as? Timestamp {
            self.timeStamp = ts.dateValue()
        } else {
            self.timeStamp = .distantPast
        }
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
        self.unreadCount = data["unreadCount"] as? Int ?? 0
    }

    var asDictionary: [String: Any] {
        return [
            "chatId": id,
            "userId": userId,
            "userName": userName,
            "lastMessage": lastMessage,
            "timeStamp": Timestamp(date: timeStamp),
            "profileImageURL": profileImageURL,
            "unreadCount": unreadCount
        ]
    }
}

// 💬 MessageModel: one message in chat
struct MessageModel: Identifiable, Codable {
    var id: String
    var senderId: String
    var receiverId: String
    var senderName: String
    var receiverName: String
    var text: String
    var timestamp: Date

    init?(id: String, data: [String: Any]) {
        guard
            let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let senderName = data["senderName"] as? String,
            let receiverName = data["receiverName"] as? String,
            let text = data["text"] as? String,
            let timestamp = data["timestamp"] as? Timestamp
        else {
            return nil
        }

        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.senderName = senderName
        self.receiverName = receiverName
        self.text = text
        self.timestamp = timestamp.dateValue()
    }

    var asDictionary: [String: Any] {
        return [
            "senderId": senderId,
            "receiverId": receiverId,
            "senderName": senderName,
            "receiverName": receiverName,
            "text": text,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}

// 🔔 NotificationModel: alert between users
struct NotificationModel: Identifiable, Codable {
    var id: String
    var senderId: String
    var receiverId: String
    var senderName: String
    var receiverName: String
    var senderImageUrl: String?
    var type: NotificationType
    var message: String
    var timestamp: Date

    enum NotificationType: String, Codable {
        case request, accepted, declined
    }

    init?(id: String, data: [String: Any]) {
        guard
            let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let senderName = data["senderName"] as? String,
            let receiverName = data["receiverName"] as? String,
            let typeRaw = data["type"] as? String,
            let type = NotificationType(rawValue: typeRaw),
            let message = data["message"] as? String,
            let timestamp = data["timestamp"] as? Timestamp
        else { return nil }

        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.senderName = senderName
        self.receiverName = receiverName
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
            "receiverName": receiverName,
            "senderImageUrl": senderImageUrl ?? "",
            "type": type.rawValue,
            "message": message,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}

// 🛎️ RequestModel: chat requests between users
struct RequestModel: Identifiable, Codable {
    var id: String
    var senderId: String
    var receiverId: String
    var senderName: String
    var receiverName: String
    var age: Int
    var location: String
    var bio: String
    var profileImageUrl: String?
    var timestamp: Date

    init?(id: String, data: [String: Any]) {
        guard
            let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let senderName = data["senderName"] as? String,
            let receiverName = data["receiverName"] as? String,
            let age = data["age"] as? Int,
            let location = data["location"] as? String,
            let bio = data["bio"] as? String,
            let timestamp = data["timestamp"] as? Timestamp
        else {
            return nil
        }

        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.senderName = senderName
        self.receiverName = receiverName
        self.age = age
        self.location = location
        self.bio = bio
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.timestamp = timestamp.dateValue()
    }

    var asDictionary: [String: Any] {
        return [
            "senderId": senderId,
            "receiverId": receiverId,
            "senderName": senderName,
            "receiverName": receiverName,
            "age": age,
            "location": location,
            "bio": bio,
            "profileImageUrl": profileImageUrl ?? "",
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}
