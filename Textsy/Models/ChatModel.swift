

import Foundation
import FirebaseFirestore


struct ChatModel: Identifiable, Codable {
    let id: String
    let chatId: String
    let participants: [String]
    let senderId: String
    let receiverId: String
    let senderName: String
    let receiverName: String
    let profileImageURL: String
    let lastMessage: String
    let timeStamp: Date
    let hiddenFor: [String]

    init(id: String, data: [String: Any]) {
        self.id = id
        self.chatId = data["chatId"] as? String ?? ""
        self.participants = data["participants"] as? [String] ?? []
        self.senderId = data["senderId"] as? String ?? ""
        self.receiverId = data["receiverId"] as? String ?? ""
        self.senderName = data["senderName"] as? String ?? ""
        self.receiverName = data["receiverName"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
        self.lastMessage = data["lastMessage"] as? String ?? ""
        self.timeStamp = (data["timeStamp"] as? Timestamp)?.dateValue() ?? Date()
        self.hiddenFor = data["hiddenFor"] as? [String] ?? []
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
    var deletedFor: [String]

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
        self.deletedFor = data["deletedFor"] as? [String] ?? []

    }
    
//use this when saving/updating a message to Firestore
    var asDictionary: [String: Any] {
        return [
            "senderId": senderId,
            "receiverId": receiverId,
            "senderName": senderName,
            "receiverName": receiverName,
            "text": text,
            "timestamp": Timestamp(date: timestamp),
            "deletedFor": deletedFor
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
    var status: String? // ✅ added simply

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
        else {
            return nil
        }

        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.senderName = senderName
        self.receiverName = receiverName
        self.senderImageUrl = data["senderImageUrl"] as? String
        self.type = type
        self.message = message
        self.timestamp = timestamp.dateValue()
        self.status = data["status"] as? String // ✅ just added here
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
            "timestamp": Timestamp(date: timestamp),
            "status": status ?? "none" // ✅ always safe
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

struct ReportModel: Identifiable {
    var id: String
    var reporterId: String
    var reportedId: String
    var reason: String
    var otherReason: String?
    var action: Bool
    var feedback: String?
    var timestamp: Date

    init(id: String, data: [String: Any]) {
        self.id = id
        self.reporterId = data["reporterId"] as? String ?? ""
        self.reportedId = data["reportedId"] as? String ?? ""
        self.reason = data["reason"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.otherReason = data["otherReason"] as? String
        self.action = data["action"] as? Bool ?? false
        self.feedback = data["feedback"] as? String
       
    }
    func toDict() -> [String: Any] {
        return [
            "reporterId": reporterId,
            "reportedId": reportedId,
            "reason": reason,
            "otherReason": otherReason ?? "",
            "action": action,
            "feedback": feedback ?? "",
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}

