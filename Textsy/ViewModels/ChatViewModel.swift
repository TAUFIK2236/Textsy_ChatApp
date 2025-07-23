//
//  ChatViewModel.swift
//  Textsy
//
//  Created by Anika Tabasum on 7/16/25.
//


// ViewModels/ChatViewModel.swift

import Foundation
import FirebaseCore

class ChatViewModel: ObservableObject {
    @Published var chats: [ChatModel] = []

    init() {
        loadMockChats()
    }

    private func loadMockChats() {
        let mockData: [[String: Any]] = [
            [
                "userName": "Jane Williams",
                "lastMessage": "Hi! How are you?",
                "timeStamp": Timestamp(date: Date()),
                "profileImageURL": "https://randomuser.me/api/portraits/women/1.jpg",
                "unreadCount": 1
            ],
            [
                "userName": "Albert Johnson",
                "lastMessage": "Are you coming today?",
                "timeStamp": Timestamp(date: Date().addingTimeInterval(-3600)),
                "profileImageURL": "https://randomuser.me/api/portraits/men/2.jpg",
                "unreadCount": 0
            ],
            [
                "userName": "Kathryn Murphy",
                "lastMessage": "Sure, that sounds good!",
                "timeStamp": Timestamp(date: Date().addingTimeInterval(-86400)),
                "profileImageURL": "https://randomuser.me/api/portraits/women/3.jpg",
                "unreadCount": 2
            ]
        ]

        self.chats = mockData.enumerated().compactMap { index, dict in
            ChatModel(id: "\(index + 1)", data: dict)
        }
    }

}
