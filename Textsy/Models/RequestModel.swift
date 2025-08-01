//
//  RequestModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/25/25.
//


import Foundation
import FirebaseFirestore

// 🛎️ A request to chat from one user to another
struct RequestModel: Identifiable, Codable {
    var id: String
    var senderId: String
    var receiverId: String
    var name: String
    var age: Int
    var location: String
    var bio: String
    var profileImageUrl: String?
    var timestamp: Date

    // ✅ From Firestore
    init?(id: String, data: [String: Any]) {
        guard
            let senderId = data["senderId"] as? String,
            let receiverId = data["receiverId"] as? String,
            let name = data["name"] as? String,
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
        self.name = name
        self.age = age
        self.location = location
        self.bio = bio
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.timestamp = timestamp.dateValue()
    }

    // ✅ Save to Firestore
    var asDictionary: [String: Any] {
        return [
            "senderId": senderId,
            "receiverId": receiverId,
            "name": name,
            "age": age,
            "location": location,
            "bio": bio,
            "profileImageUrl": profileImageUrl ?? "",
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}

