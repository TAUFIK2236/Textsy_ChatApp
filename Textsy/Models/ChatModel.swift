//
//  ChatModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/25/25.
//


import Foundation
import FirebaseFirestore

// 💬 Each chat preview card in HomeView
struct ChatModel: Identifiable, Codable {
    var id: String // 📄 Firestore doc ID
    var userName: String
    var lastMessage: String?
    var timeStamp: Date
    var profileImageURL: String?
    var unreadCount: Int

    // ✅ Init from Firestore document
    init?(id: String, data: [String: Any]) {
        guard
            let userName = data["userName"] as? String,
            let timeStamp = data["timeStamp"] as? Timestamp,
            let unreadCount = data["unreadCount"] as? Int
        else {
            return nil // ❌ Fail if required fields are missing
        }

        self.id = id
        self.userName = userName
        self.lastMessage = data["lastMessage"] as? String
        self.timeStamp = timeStamp.dateValue() // 📆 Firebase timestamp to Swift Date
        self.profileImageURL = data["profileImageURL"] as? String
        self.unreadCount = unreadCount
    }

    // ✅ Convert to dictionary for Firestore upload
    var asDictionary: [String: Any] {
        return [
            "userName": userName,
            "lastMessage": lastMessage ?? "",
            "timeStamp": Timestamp(date: timeStamp),
            "profileImageURL": profileImageURL ?? "",
            "unreadCount": unreadCount
        ]
    }
}
